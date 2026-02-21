class ApiConfig {
  // Change this to your computer's IP address
  // Find it: Windows (ipconfig), Mac/Linux (ifconfig)
  static const String baseUrl = 'http://localhost:5000';
  
  // For Android Emulator, use: 'http://10.0.2.2:5000'
  // For iOS Simulator, use: 'http://localhost:5000'
  // For Physical Device, use your computer's IP: 'http://192.168.1.X:5000'
  
  static const String apiUrl = '$baseUrl/api';
  static const String socketUrl = baseUrl;
  
  // Endpoints
  static const String login = '$apiUrl/auth/login';
  static const String register = '$apiUrl/auth/register';
  static const String profile = '$apiUrl/auth/me';
  static const String updateProfile = '$apiUrl/auth/profile';
}