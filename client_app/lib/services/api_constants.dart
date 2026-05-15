import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;

    if (kIsWeb) {
      if (Uri.base.host == 'localhost' || Uri.base.host == '127.0.0.1') {
        return 'http://localhost:5000/api';
      }
      return '${Uri.base.origin}/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    }

    return 'http://localhost:5000/api';
  }

  // Auth
  static String get authLogin => '$baseUrl/auth/login';
  static String get authRegister => '$baseUrl/auth/register-client';
  static String get authMe => '$baseUrl/auth/me';
  static String get authChangePassword => '$baseUrl/auth/change-password';
  static String get authForgotPassword => '$baseUrl/auth/forgot-password';
  static String get authResetPassword => '$baseUrl/auth/reset-password';
  // Products
  static String get products => '$baseUrl/products';

  // Clients
  static String get clients => '$baseUrl/clients';
  static String get clientMe => '$baseUrl/clients/me';

  // Orders
  static String get orders => '$baseUrl/orders';
  static String get myOrders => '$baseUrl/orders/my';
  static String get invoices => '$baseUrl/invoices';
  static String get invoicesMy => '$baseUrl/invoices/my';

  // Reviews
  static String get reviews => '$baseUrl/reviews';
  static String get reviewsMy => '$baseUrl/reviews/my';
  static String get reviewsProduct => '$baseUrl/reviews/product';

  // Complaints
  static String get complaints => '$baseUrl/complaints';
  static String get complaintsMy => '$baseUrl/complaints/my';

  // Support
  static String get questionsClients => '$baseUrl/QuestionsClients';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';
}
