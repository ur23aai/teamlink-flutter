import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/team.dart';
import '../../services/team_service.dart';
import '../../models/announcement.dart';
import '../../services/announcement_service.dart';
import 'package:intl/intl.dart';
import '../../providers/chat_provider.dart';
import 'package:provider/provider.dart';

class TeamDetailsScreen extends StatefulWidget {
  final Team team;

  const TeamDetailsScreen({Key? key, required this.team}) : super(key: key);

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  final _teamService = TeamService();
  final _announcementService = AnnouncementService();

  List<TeamMember> _members = [];
  List<Announcement> _announcements = [];

  bool _loadingMembers = false;
  bool _loadingAnnouncements = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() => _loadingAnnouncements = true);
    final announcements =
        await _announcementService.getTeamAnnouncements(widget.team.id);
    setState(() {
      _announcements = announcements;
      _loadingAnnouncements = false;
    });
  }

  Future<void> _createAnnouncement() async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter announcement title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Enter announcement message',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Post'),
          ),
        ],
      ),
    );

    if (result == true) {
      final title = titleController.text.trim();
      final message = messageController.text.trim();

      if (title.isEmpty || message.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter title and message'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await _announcementService.createAnnouncement(
        teamId: widget.team.id,
        title: title,
        message: message,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: response['success'] ? Colors.green : Colors.red,
          ),
        );

        if (response['success']) {
          _loadAnnouncements();
        }
      }
    }
  }

  Future<void> _loadMembers() async {
    setState(() => _loadingMembers = true); // Keep this
    final members = await _teamService.getTeamMembers(widget.team.id);
    setState(() {
      _members = members;
      _loadingMembers = false;
    });
  }

  void _copyJoinCode() {
    Clipboard.setData(ClipboardData(text: widget.team.joinCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Join code copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAddMemberDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Enter member email',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;

              Navigator.pop(context);

              final result = await _teamService.addMember(
                teamId: widget.team.id,
                email: email,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Member added'),
                    backgroundColor:
                        result['success'] ? Colors.green : Colors.red,
                  ),
                );

                if (result['success']) {
                  _loadMembers();
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeMember(TeamMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove ${member.name} from this team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final result = await _teamService.removeMember(
                teamId: widget.team.id,
                userId: member.userId,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Member removed'),
                    backgroundColor:
                        result['success'] ? Colors.green : Colors.red,
                  ),
                );

                if (result['success']) {
                  _loadMembers();
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () async {
              final chatProvider =
                  Provider.of<ChatProvider>(context, listen: false);
              final chat =
                  await chatProvider.getOrCreateTeamChat(widget.team.teamId);

              if (chat != null && mounted) {
                Navigator.pushNamed(
                  context,
                  '/chat-room',
                  arguments: chat,
                );
              }
            },
            tooltip: 'Team Chat',
          ),
        ],
      ),
      body: _loadingMembers && _members.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMembers,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Team Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF8B5CF6).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.groups,
                                  size: 32,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.team.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: widget.team.role == 'Admin'
                                            ? const Color(0xFFEC4899)
                                                .withOpacity(0.1)
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        widget.team.role,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: widget.team.role == 'Admin'
                                              ? const Color(0xFFEC4899)
                                              : Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (widget.team.description != null &&
                              widget.team.description!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              widget.team.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          // Join Code
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.vpn_key,
                                  color: Color(0xFF8B5CF6),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Join Code',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        widget.team.joinCode,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF8B5CF6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: _copyJoinCode,
                                  icon: const Icon(Icons.copy),
                                  color: const Color(0xFF8B5CF6),
                                  tooltip: 'Copy code',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Members Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Members (${_members.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.team.role == 'Admin')
                        TextButton.icon(
                          onPressed: _showAddMemberDialog,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Members List
                  ..._members.map((member) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF8B5CF6),
                            child: Text(
                              member.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(member.name),
                          subtitle: Text(member.email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: member.role == 'Admin'
                                      ? const Color(0xFFEC4899).withOpacity(0.1)
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  member.role,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: member.role == 'Admin'
                                        ? const Color(0xFFEC4899)
                                        : Colors.grey[700],
                                  ),
                                ),
                              ),
                              if (widget.team.role == 'Admin' &&
                                  member.role != 'Admin')
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.red,
                                  onPressed: () => _removeMember(member),
                                ),
                            ],
                          ),
                        ),
                      )),

                  // Add this AFTER the members section
                  const SizedBox(height: 24),

// Announcements Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Announcements (${_announcements.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.team.role == 'Admin')
                        TextButton.icon(
                          onPressed: _createAnnouncement,
                          icon: const Icon(Icons.add),
                          label: const Text('Post'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

// Announcements List
                  if (_loadingAnnouncements)
                    const Center(child: CircularProgressIndicator())
                  else if (_announcements.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.campaign_outlined,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'No announcements yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._announcements.map((announcement) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.campaign,
                                      color: Color(0xFFEC4899),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        announcement.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  announcement.message,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'By ${announcement.createdBy.name}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '• ${DateFormat('MMM dd, yyyy').format(announcement.createdAt)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}
