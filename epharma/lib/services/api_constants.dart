class ApiConstants {
  static const String baseUrl = "http://localhost:5000/api";
  
  // Auth endpoints
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  static const String me = "$baseUrl/auth/me";
  
  // Storage keys
  static const String tokenKey = "auth_token";
}
