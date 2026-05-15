import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'main_layout.dart';
import 'providers/product_provider.dart';
import 'providers/sales_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/finance_provider.dart';
import 'providers/client_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/review_provider.dart';
import 'providers/support_provider.dart';
import 'screens/auth/login_page.dart';
import 'providers/notification_provider.dart';
import 'widgets/app_notification.dart';

// Note: Client services and pages removed as they are currently missing in this module

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fix: A message on the flutter/lifecycle channel was discarded before it could be handled.
  // This happens on web when the framework is initializing.
  ServicesBinding.instance.channelBuffers.resize('flutter/lifecycle', 100);
  // Custom Error Widget for production
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Oups ! Une erreur est survenue.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              details.exception.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkAuthStatus(),
        ),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => SupportProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (context) => NotificationProvider(),
          update: (context, auth, previous) =>
              (previous ?? NotificationProvider())..update(auth),
        ),
      ],

      child: MaterialApp(
        title: 'BigPharma SaaS',
        navigatorKey: AppNotificationService.navigatorKey,
        builder: (context, child) =>
            AppNotificationHost(child: child ?? const SizedBox.shrink()),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1), // Indigo premium
            brightness: Brightness.light,
          ),
          fontFamily: 'sans-serif',
          // fontFamily: 'Inter', // Standardized to system font as Inter assets are missing
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.isAuthenticated) {
      // Direct all authenticated users to MainLayout for now,
      // as HomePage for clients is missing in this module.
      return const MainLayout();
    } else {
      return const LoginPage();
    }
  }
}
