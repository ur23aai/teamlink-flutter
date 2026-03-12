import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/team_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/notification_provider.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      body: Column(
        children: [
          // Gradient header with avatar, name, email
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                child: Column(
                  children: [
                    // Back button row
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: Container(
                          color: const Color(0xFFEDE9FE),
                          child: Center(
                            child: Text(
                              user?.name.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'User',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4A4A6A),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          // White card menu area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Menu card
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      transform: Matrix4.translationValues(0, -20, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _MenuItem(
                            icon: Icons.edit_outlined,
                            title: 'Edit Profile',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const EditProfileScreen()),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 56),
                          _MenuItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            onTap: () {
                              Navigator.pushNamed(context, '/notifications');
                            },
                          ),
                          const Divider(height: 1, indent: 56),
                          _MenuItem(
                            icon: Icons.lock_outlined,
                            title: 'Privacy & Security',
                            onTap: () {},
                          ),
                          const Divider(height: 1, indent: 56),
                          _MenuItem(
                            icon: Icons.help_outline,
                            title: 'Help & Support',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    // Logout Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEC4899),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final authProvider = Provider.of<AuthProvider>(
                                  context,
                                  listen: false);
                              final teamProvider = Provider.of<TeamProvider>(
                                  context,
                                  listen: false);
                              final taskProvider = Provider.of<TaskProvider>(
                                  context,
                                  listen: false);
                              final chatProvider = Provider.of<ChatProvider>(
                                  context,
                                  listen: false);
                              final notificationProvider =
                                  Provider.of<NotificationProvider>(context,
                                      listen: false);

                              chatProvider.clearChats();

                              await authProvider.logout();
                              teamProvider.clearTeams();
                              taskProvider.clearTasks();
                              chatProvider.clearChats();
                              notificationProvider.clearNotifications();

                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen()),
                                  (route) => false,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.power_settings_new,
                                color: Colors.white),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF7C3AED), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
