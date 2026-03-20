import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/team_provider.dart';
import '../../services/team_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({Key? key}) : super(key: key);

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  final _teamService = TeamService();

  // Step 1 = fill team info, Step 2 = add members
  int _step = 1;
  String _createdTeamId = '';

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _selectedMembers = [];
  bool _searching = false;
  bool _addingMembers = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createTeam() async {
    if (!_formKey.currentState!.validate()) return;

    final teamProvider = Provider.of<TeamProvider>(context, listen: false);

    final result = await teamProvider.createTeamAndGetId(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    if (result != null) {
      setState(() {
        _createdTeamId = result;
        _step = 2;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(teamProvider.errorMessage ?? 'Failed to create team'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searching = true);
    final results = await _teamService.searchUsers(query.trim());
    setState(() {
      _searchResults = results
          .where((u) => !_selectedMembers.any((s) => s['userId'] == u['userId']))
          .toList();
      _searching = false;
    });
  }

  void _selectUser(Map<String, dynamic> user) {
    setState(() {
      _selectedMembers.add(user);
      _searchResults.remove(user);
      _searchController.clear();
      _searchResults = [];
    });
  }

  void _removeSelected(Map<String, dynamic> user) {
    setState(() => _selectedMembers.remove(user));
  }

  Future<void> _addMembersAndFinish() async {
    if (_selectedMembers.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _addingMembers = true);

    int failed = 0;
    for (final member in _selectedMembers) {
      final result = await _teamService.addMember(
        teamId: _createdTeamId,
        email: member['email'],
      );
      if (!result['success']) failed++;
    }

    setState(() => _addingMembers = false);

    if (mounted) {
      final msg = failed == 0
          ? 'Team created and members added!'
          : 'Team created. $failed member(s) could not be added.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: failed == 0 ? Colors.green : Colors.orange,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 1 ? 'Create Team' : 'Add Members'),
      ),
      body: _step == 1 ? _buildStep1() : _buildStep2(),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.groups, size: 64, color: Color(0xFF8B5CF6)),
            const SizedBox(height: 16),
            const Text(
              'Create a New Team',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Build your team and start collaborating',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Team Name',
              hintText: 'e.g., Development Team',
              controller: _nameController,
              prefixIcon: const Icon(Icons.people),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a team name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Description (Optional)',
              hintText: 'What is this team about?',
              controller: _descriptionController,
              prefixIcon: const Icon(Icons.description),
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 32),
            Consumer<TeamProvider>(
              builder: (context, teamProvider, _) {
                return CustomButton(
                  text: 'Create Team',
                  onPressed: _createTeam,
                  isLoading: teamProvider.isLoading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Team Members',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Search by name or email. You can skip this.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _searchUsers,
              ),
            ],
          ),
        ),

        // Search results
        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: _searchResults.map((user) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF8B5CF6),
                    child: Text(
                      (user['name'] as String).substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(user['name']),
                  subtitle: Text(user['email']),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFF8B5CF6)),
                    onPressed: () => _selectUser(user),
                  ),
                );
              }).toList(),
            ),
          ),

        // Selected members
        if (_selectedMembers.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              'Selected (${_selectedMembers.length})',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          ..._selectedMembers.map((member) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF8B5CF6),
                        child: Text(
                          (member['name'] as String).substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(member['name'],
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(member['email'],
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.red, size: 20),
                        onPressed: () => _removeSelected(member),
                      ),
                    ],
                  ),
                ),
              )),
        ],

        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addingMembers ? null : _addMembersAndFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _addingMembers
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _selectedMembers.isEmpty ? 'Skip' : 'Add Members & Finish',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
