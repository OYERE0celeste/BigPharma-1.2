import 'dart:ui';
import 'package:client_app/pages/home_page.dart';
import 'package:client_app/pages/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'constants/strings.dart';
import 'widgets/bp_theme.dart';
import 'services/cart_provider.dart';
import 'services/auth_provider.dart';
import 'services/profile_provider.dart';
import 'services/order_provider.dart';
import 'services/wishlist_provider.dart';
import 'services/support_provider.dart';
import 'services/notification_provider.dart';
import 'services/invoice_provider.dart';
import 'services/review_provider.dart';
import 'services/complaint_provider.dart';
import 'widgets/app_notification.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Fix: A message on the flutter/lifecycle channel was discarded before it could be handled.
  // This happens on web when the framework is initializing.
  ServicesBinding.instance.channelBuffers.resize('flutter/lifecycle', 100);

  // Catch Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // Log to Sentry or similar here
  };

  // Catch async errors outside of Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform error: $error');
    return true;
  };

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => SupportProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (context) => NotificationProvider(),
          update: (context, auth, previous) =>
              (previous ?? NotificationProvider())..update(auth),
        ),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNotificationService.navigatorKey,
      builder: (context, child) => AppNotificationHost(
        child: BpDecoratedBackground(child: child ?? const SizedBox.shrink()),
      ),
      theme: BpTheme.materialTheme(),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isInitialized) {
            return const BpAuthLoadingScreen();
          }
          return auth.isAuthenticated ? const HomePage() : const LandingPage();
        },
      ),
    );
  }
}
