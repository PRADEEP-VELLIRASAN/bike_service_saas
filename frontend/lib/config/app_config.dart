/// Application configuration constants
class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:8000/api/v1';
  
  // App Info
  static const String appName = 'Bike Service Station';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
