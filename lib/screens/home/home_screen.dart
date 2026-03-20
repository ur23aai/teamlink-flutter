import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/team_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/team.dart';
import '../../models/task.dart';
import '../auth/profile_screen.dart';
import '../../providers/notification_provider.dart';
import '../../models/announcement.dart';
import '../../services/announcement_service.dart';
import 'package:intl/intl.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const TeamsTab(),
    const TasksTab(),
    const ChatsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TeamLink',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
            ),
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  if (provider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${provider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF8B5CF6),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Teams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            activeIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Chats',
          ),
        ],
      ),
    );
  }
}

// Dashboard Tab
class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final _announcementService = AnnouncementService();
  List<Announcement> _recentAnnouncements = [];
  bool _loadingAnnouncements = false;

  @override
  void initState() {
    super.initState();

    // Load data when dashboard opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecentAnnouncements();

      // 🆕 Load tasks
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      if (taskProvider.tasks.isEmpty) {
        taskProvider.loadMyTasks();
      }

      // 🆕 Load teams
      final teamProvider = Provider.of<TeamProvider>(context, listen: false);
      if (teamProvider.teams.isEmpty) {
        teamProvider.loadTeams();
      }
    });
  }

  Future<void> _loadRecentAnnouncements() async {
    setState(() => _loadingAnnouncements = true);

    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // Load teams if not already loaded
    if (teamProvider.teams.isEmpty) {
      await teamProvider.loadTeams();
    }

    // 🆕 Load tasks if not already loaded
    if (taskProvider.tasks.isEmpty) {
      await taskProvider.loadMyTasks();
    }

    // Get announcements from all teams
    final allAnnouncements = <Announcement>[];
    for (var team in teamProvider.teams) {
      final announcements =
          await _announcementService.getTeamAnnouncements(team.id);
      allAnnouncements.addAll(announcements);
    }

    // Sort by date and take latest 5
    allAnnouncements.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _recentAnnouncements = allAnnouncements.take(5).toList();
      _loadingAnnouncements = false;
    });
  }

  Future<void> _refreshDashboard() async {
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // Reload all data
    await Future.wait([
      teamProvider.loadTeams(),
      taskProvider.loadMyTasks(),
      _loadRecentAnnouncements(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: Container(
        color: const Color(0xFFF5F5F5),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Greeting card
              const _GreetingCard(),
              const SizedBox(height: 20),

              // My Tasks Section
              const Text(
                'My Tasks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Consumer<TaskProvider>(
                builder: (context, taskProvider, _) {
                  final myTasks = taskProvider.tasks.take(3).toList();

                  if (myTasks.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.task_outlined,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'No tasks assigned yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: myTasks
                        .map((task) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(
                                  Icons.check_circle_outline,
                                  color: task.status == 'Completed'
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                title: Text(task.title),
                                subtitle: Text(task.teamName),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: task.priority == 'High'
                                        ? Colors.red.withOpacity(0.1)
                                        : task.priority == 'Medium'
                                            ? Colors.orange.withOpacity(0.1)
                                            : Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    task.priority,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: task.priority == 'High'
                                          ? Colors.red
                                          : task.priority == 'Medium'
                                              ? Colors.orange
                                              : Colors.blue,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  final teams = Provider.of<TeamProvider>(
                                          context,
                                          listen: false)
                                      .teams;
                                  final isAdmin = teams.any((t) =>
                                      t.teamId == task.teamId &&
                                      t.role == 'Admin');
                                  Navigator.pushNamed(
                                    context,
                                    '/task-details',
                                    arguments: {
                                      'task': task,
                                      'isAdmin': isAdmin,
                                    },
                                  );
                                },
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Recent Announcements
              const Text(
                'Recent Announcements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (_loadingAnnouncements)
                const Center(child: CircularProgressIndicator())
              else if (_recentAnnouncements.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
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
                Column(
                  children: _recentAnnouncements
                      .map((announcement) => Card(
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
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        announcement.teamName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '• ${DateFormat('MMM dd').format(announcement.createdAt)}',
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
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String count;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard();

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final firstName = (user?.name ?? 'there').split(' ').first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_greeting()}, $firstName!',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Here's what's happening with your teams today.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// Teams Tab
class TeamsTab extends StatefulWidget {
  const TeamsTab({Key? key}) : super(key: key);

  @override
  State<TeamsTab> createState() => _TeamsTabState();
}

class _TeamsTabState extends State<TeamsTab>
    with AutomaticKeepAliveClientMixin {
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      Provider.of<TeamProvider>(context, listen: false).loadTeams();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<TeamProvider>(
      builder: (context, teamProvider, _) {
        return Column(
          children: [
            // Gradient header with action buttons
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  _PillButton(
                    label: 'Create Team',
                    onTap: () => Navigator.pushNamed(context, '/create-team'),
                  ),
                  const SizedBox(height: 12),
                  _PillButton(
                    label: 'Join via Code',
                    onTap: () => Navigator.pushNamed(context, '/join-team'),
                  ),
                ],
              ),
            ),
            // Team list
            Expanded(
              child: Container(
                color: const Color(0xFFF5F5F5),
                child: teamProvider.isLoading && teamProvider.teams.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : teamProvider.teams.isEmpty
                        ? _buildEmptyTeams()
                        : RefreshIndicator(
                            onRefresh: () => teamProvider.refreshTeams(),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Your Teams',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.9,
                                    ),
                                    itemCount: teamProvider.teams.length,
                                    itemBuilder: (context, index) {
                                      return _TeamGridCard(
                                          team: teamProvider.teams[index]);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyTeams() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No Teams Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the buttons above to create or join a team',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PillButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.25),
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _TeamGridCard extends StatelessWidget {
  final Team team;

  const _TeamGridCard({required this.team});

  // Get next task due date for this team
  String _getNextTaskDue(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final teamTasks = taskProvider.tasks
        .where((task) => task.teamId == team.teamId && task.dueDate != null)
        .toList();

    if (teamTasks.isEmpty) return 'No tasks';

    // Sort by due date
    teamTasks.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    final nextTask = teamTasks.first;

    return DateFormat('MMM dd').format(nextTask.dueDate!);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/team-details',
            arguments: team,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team name
              Text(
                team.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Member count
              Text(
                '${team.memberCount} members',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              // Role badge
              Text(
                team.role,
                style: TextStyle(
                  fontSize: 13,
                  color: team.role == 'Admin'
                      ? const Color(0xFFEC4899)
                      : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Next task due
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next task due',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getNextTaskDue(context),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tasks Tab
class TasksTab extends StatefulWidget {
  const TasksTab({Key? key}) : super(key: key);

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  bool _hasLoadedTasks = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load tasks AFTER the build phase
    if (!_hasLoadedTasks) {
      _hasLoadedTasks = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<TaskProvider>(context, listen: false).loadMyTasks();
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'To Do'),
              Tab(text: 'In Progress'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        Expanded(
          child: Consumer<TaskProvider>(
            builder: (context, taskProvider, _) {
              if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final todoTasks = taskProvider.getTasksByStatus('To Do');
              final inProgressTasks =
                  taskProvider.getTasksByStatus('In Progress');
              final completedTasks = taskProvider.getTasksByStatus('Completed');

              return TabBarView(
                controller: _tabController,
                children: [
                  _TaskListView(
                    tasks: todoTasks,
                    status: 'To Do',
                    onRefresh: () => taskProvider.loadMyTasks(),
                  ),
                  _TaskListView(
                    tasks: inProgressTasks,
                    status: 'In Progress',
                    onRefresh: () => taskProvider.loadMyTasks(),
                  ),
                  _TaskListView(
                    tasks: completedTasks,
                    status: 'Completed',
                    onRefresh: () => taskProvider.loadMyTasks(),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TaskListView extends StatelessWidget {
  final List<Task> tasks;
  final String status;
  final Future<void> Function() onRefresh;

  const _TaskListView({
    required this.tasks,
    required this.status,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeader(context);
          }
          final t = tasks[index - 1];
          final teams =
              Provider.of<TeamProvider>(context, listen: false).teams;
          final isAdmin = teams
              .any((tm) => tm.teamId == t.teamId && tm.role == 'Admin');
          return _TaskCard(task: t, isAdmin: isAdmin);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/create-task');
        },
        icon: const Icon(Icons.add),
        label: const Text('Create New Task'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  size: 50,
                  color: Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No tasks to display',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You haven't been assigned to a task just yet",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 180,
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/create-task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Create Task',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final bool isAdmin;

  const _TaskCard({required this.task, this.isAdmin = false});

  Color _getPriorityColor() {
    switch (task.priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon() {
    switch (task.priority) {
      case 'High':
        return Icons.arrow_upward;
      case 'Medium':
        return Icons.remove;
      case 'Low':
        return Icons.arrow_downward;
      default:
        return Icons.remove;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/task-details',
            arguments: {'task': task, 'isAdmin': isAdmin},
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPriorityIcon(),
                          size: 12,
                          color: _getPriorityColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.priority,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getPriorityColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.group, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    task.teamName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (task.assignedTo.isNotEmpty) ...[
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFF8B5CF6),
                      child: Text(
                        task.assignedTo.first.name
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      task.assignedTo.length == 1
                          ? task.assignedTo.first.name
                          : '${task.assignedTo.first.name} +${task.assignedTo.length - 1}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              if (task.dueDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Chats Tab
class ChatsTab extends StatefulWidget {
  const ChatsTab({Key? key}) : super(key: key);

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.initSocket();
      chatProvider.loadChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        if (chatProvider.isLoading && chatProvider.chats.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // New Message button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'New Message',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Chat list
            Expanded(
              child: chatProvider.chats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_outlined,
                              size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text(
                            'No Chats Yet',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a conversation from your teams',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: chatProvider.refresh,
                      child: ListView.separated(
                        itemCount: chatProvider.chats.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          return _ChatCard(chat: chatProvider.chats[index]);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ChatCard extends StatelessWidget {
  final Chat chat;

  const _ChatCard({required this.chat});

  String _getChatName() {
    if (chat.chatType == 'team') {
      return chat.teamName ?? 'Team Chat';
    } else {
      return chat.participants.isNotEmpty
          ? chat.participants.first.name
          : 'Direct Chat';
    }
  }

  String _getInitial() {
    final name = _getChatName();
    return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/chat-room', arguments: chat),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFEDE9FE),
              child: chat.chatType == 'team'
                  ? const Icon(Icons.chat_bubble,
                      color: Color(0xFF7C3AED), size: 26)
                  : Text(
                      _getInitial(),
                      style: const TextStyle(
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getChatName(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      if (chat.lastMessage != null)
                        Text(
                          DateFormat('h:mm a')
                              .format(chat.lastMessage!.createdAt),
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                    ],
                  ),
                  if (chat.lastMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      chat.lastMessage!.sender.name,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF1A1A2E)),
                    ),
                    Text(
                      chat.lastMessage!.content,
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Unread badge
            if (chat.unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF7C3AED),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${chat.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
