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
import 'scanner/providers/scanner_provider.dart';
import 'screens/auth/login_page.dart';
import 'providers/notification_provider.dart';
import 'widgets/app_notification.dart';
import 'widgets/bp_theme.dart';
import 'scanner/widgets/global_scanner_listener.dart';
// Scanner status overlay import removed (overlay disabled in production UI)

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
        color: BpColors.scaffold,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: BpColors.error, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Oups ! Une erreur est survenue.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: BpColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              details.exception.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: BpColors.textSecondary),
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
        ChangeNotifierProvider(create: (_) => ScannerProvider()),
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
        title: 'BigPharma',
        navigatorKey: AppNotificationService.navigatorKey,
        builder: (context, child) => GlobalScannerListener(
          child: Stack(
            children: [
              AppNotificationHost(
                child: BpDecoratedBackground(
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
              // Scanner status overlay removed for production UI (was showing
              // as a small dark square in the corner). If you need the overlay
              // for debugging, re-enable it here or toggle via a settings flag.
            ],
          ),
        ),
        theme: BpTheme.materialTheme(),
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          physics: BouncingScrollPhysics(),
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
      return const BpAuthLoadingScreen();
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
