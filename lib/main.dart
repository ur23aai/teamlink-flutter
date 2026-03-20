import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'models/team.dart';
import 'providers/auth_provider.dart';
import 'providers/team_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/teams/create_team_screen.dart';
import 'screens/teams/join_team_screen.dart';
import 'screens/teams/team_details_screen.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'providers/task_provider.dart';
import 'screens/tasks/create_task_screen.dart';
import 'screens/tasks/task_details_screen.dart';
import 'screens/tasks/edit_task_screen.dart';
import 'models/task.dart';
import 'providers/notification_provider.dart';
import 'screens/notifications/notifications_screen.dart';
import 'providers/chat_provider.dart'; // 🆕 ADD THIS
import 'models/chat.dart'; // 🆕 ADD THIS
import 'screens/chats/chat_room_screen.dart'; // 🆕 ADD THIS

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService().init();
  ApiService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'TeamLink',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/create-team': (context) => const CreateTeamScreen(),
          '/join-team': (context) => const JoinTeamScreen(),
          '/create-task': (context) => const CreateTaskScreen(),
          '/notifications': (context) => const NotificationsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/team-details') {
            final team = settings.arguments as Team;
            return MaterialPageRoute(
              builder: (context) => TeamDetailsScreen(team: team),
            );
          }
          if (settings.name == '/edit-task') {
            final task = settings.arguments as Task;
            return MaterialPageRoute(
              builder: (context) => EditTaskScreen(task: task),
            );
          }
          if (settings.name == '/task-details') {
            final args = settings.arguments as Map<String, dynamic>;
            final task = args['task'] as Task;
            final isAdmin = args['isAdmin'] as bool? ?? false;
            return MaterialPageRoute(
              builder: (context) =>
                  TaskDetailsScreen(task: task, isAdmin: isAdmin),
            );
          }
          if (settings.name == '/chat-room') {
            // 🆕 ADD THIS
            final chat = settings.arguments as Chat;
            return MaterialPageRoute(
              builder: (context) => ChatRoomScreen(chat: chat),
            );
          }
          return null;
        },
      ),
    );
  }
}
