# TeamLink Flutter

A cross-platform team collaboration mobile/web application built with Flutter, featuring real-time chat, task management, and team coordination.

## 📋 Overview

TeamLink Flutter is a comprehensive frontend application that connects to the TeamLink Backend API, providing a seamless user interface for team collaboration, task tracking, real-time messaging, and notifications.

## 🚀 Features

- **User Authentication**: Register, login, profile management
- **Team Management**: Create teams, join via code, manage members with role badges
- **Task Management**: Create, assign, track tasks with status (To Do, In Progress, Completed) and priority levels
- **Real-time Chat**: Team chats and direct messaging with WebSocket
- **Live Notifications**: Instant notifications with unread badges and swipe-to-delete
- **Announcements**: Team-wide announcements from admins
- **Dashboard**: Overview of teams, tasks, and recent activities
- **Responsive Design**: Works on web, mobile, and desktop

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider pattern
- **HTTP Client**: Dio
- **Real-time**: Socket.IO Client
- **Local Storage**: SharedPreferences
- **UI**: Material Design 3

## 📁 Project Structure

```
teamlink_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── config/
│   │   ├── api_config.dart          # API & WebSocket URLs
│   │   └── theme_config.dart        # App theme
│   ├── models/
│   │   ├── user.dart                # User model
│   │   ├── team.dart                # Team & TeamMember models
│   │   ├── task.dart                # Task model
│   │   ├── chat.dart                # Chat & ChatParticipant models
│   │   ├── message.dart             # Message model
│   │   ├── notification.dart        # Notification model
│   │   └── announcement.dart        # Announcement model
│   ├── services/
│   │   ├── api_service.dart         # Base HTTP client
│   │   ├── auth_service.dart        # Authentication APIs
│   │   ├── team_service.dart        # Team management APIs
│   │   ├── task_service.dart        # Task APIs
│   │   ├── chat_service.dart        # Chat & messaging APIs
│   │   ├── notification_service.dart
│   │   ├── announcement_service.dart
│   │   ├── socket_service.dart      # WebSocket connection
│   │   └── storage_service.dart     # Local storage
│   ├── providers/
│   │   ├── auth_provider.dart       # Auth state management
│   │   ├── team_provider.dart       # Team state management
│   │   ├── task_provider.dart       # Task state management
│   │   ├── chat_provider.dart       # Chat state management
│   │   └── notification_provider.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   └── edit_profile_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart     # Main screen with tabs
│   │   ├── teams/
│   │   │   ├── create_team_screen.dart
│   │   │   ├── join_team_screen.dart
│   │   │   └── team_details_screen.dart
│   │   ├── tasks/
│   │   │   ├── create_task_screen.dart
│   │   │   └── task_details_screen.dart
│   │   ├── chats/
│   │   │   └── chat_room_screen.dart
│   │   └── notifications/
│   │       └── notifications_screen.dart
│   └── widgets/
│       └── custom_button.dart
├── pubspec.yaml
└── README.md
```

## ⚙️ Installation

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- TeamLink Backend running on `http://localhost:5000`

### Setup

1. **Clone the repository**
```bash
git clone https://github.com/ur23aai/teamlink-flutter.git
cd teamlink-flutter
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure API endpoint**

Edit `lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:5000';
  static const String socketUrl = 'http://localhost:5000';
}
```

For production, update to your deployed backend URL.

4. **Run the app**

Web (Chrome):
```bash
flutter run -d chrome
```

Android:
```bash
flutter run -d android
```

iOS:
```bash
flutter run -d ios
```

Desktop (Windows):
```bash
flutter run -d windows
```

## 📱 Features Breakdown

### Authentication
- User registration with validation
- Login with JWT token storage
- Profile viewing and editing
- Secure logout

### Dashboard
- Welcome message with user name
- Team and task statistics
- Recent tasks list
- Recent announcements
- Pull-to-refresh

### Teams
- Beautiful grid layout with gradient header
- Create new teams
- Join teams via code
- View team details with member list
- Add/remove members (Admin only)
- Team announcements section
- Copy join code functionality

### Tasks
- Tab-based filtering (To Do, In Progress, Completed)
- Create tasks with team selection
- Assign to team members
- Set priority (Low, Medium, High)
- Set due dates
- Update task status
- Delete tasks
- Color-coded priority badges

### Chat
- Real-time messaging with WebSocket
- Team chat rooms
- Direct messages
- Message bubbles with sender identification
- Auto-scroll to latest message
- Typing indicators
- Online/offline status

### Notifications
- Real-time notification delivery
- Unread count badge in app bar
- Swipe-to-delete individual notifications
- Mark all as read
- Clear read notifications
- Auto-mark as read on tap

### Announcements
- Admin-only creation
- Display in dashboard
- Display in team details
- Integrated with notifications

## 🎨 UI/UX Features

- **Material Design 3** with custom purple/pink gradient theme
- **Responsive layouts** for all screen sizes
- **Pull-to-refresh** on major screens
- **Loading indicators** during API calls
- **Error handling** with user-friendly messages
- **Form validation** on all input fields
- **Smooth animations** and transitions

## 🔌 State Management

Uses **Provider pattern** for centralized state management:

- **AuthProvider**: User authentication state
- **TeamProvider**: Team data and operations
- **TaskProvider**: Task data and CRUD operations
- **ChatProvider**: Chat state and WebSocket management
- **NotificationProvider**: Notification state

## 🌐 API Integration

All API calls use **Dio** HTTP client with:
- Base URL configuration
- JWT token interceptors
- Error handling
- Request/response logging (debug mode)

## 🔐 Security

- JWT tokens stored in SharedPreferences
- Automatic token attachment to API requests
- WebSocket authentication with JWT
- Secure logout clears all local data
- Role-based UI rendering (Admin vs Member)

## 📊 Development Stages

- ✅ **Stage 6**: Authentication & UI Foundation
- ✅ **Stage 7**: Complete App Integration
  - Teams screens and functionality
  - Tasks screens and CRUD operations
  - Real-time chat with WebSocket
  - Notifications with live updates
  - Announcements integration
  - Dashboard with statistics

## 🐛 Known Issues & Solutions

### Fixed Issues:
- ✅ Tasks appearing empty after status update → Fixed with provider reload
- ✅ Chat messages showing wrong sender → Fixed with proper user ID tracking
- ✅ State not clearing on logout → Fixed with provider cleanup methods
- ✅ Navigation issues → Fixed with proper route handling

## 🧪 Testing

Manual testing performed on:
- Chrome (Web)
- Android Emulator
- Windows Desktop

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1              # State management
  dio: ^5.4.0                   # HTTP client
  shared_preferences: ^2.2.2    # Local storage
  socket_io_client: ^2.0.3+1    # WebSocket
  intl: ^0.19.0                 # Date formatting
```

## 🚀 Deployment

### Web Deployment (Firebase Hosting)
```bash
flutter build web
firebase deploy
```

### Android APK
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 📝 License

This project is part of an academic final year project.

## 👤 Author

**Urvil Rathod**  
Student ID: 
BSc (Hons) Computer Science  
University of Hertfordshire  
Email: Ur23aai@herts.ac.uk

## 🔗 Related Repository

Backend: [teamlink-backend](https://github.com/ur23aai/teamlink-backend)


---

**Built with Flutter 💙 for seamless team collaboration**
