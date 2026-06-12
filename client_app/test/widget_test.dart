// This is a basic Flutter widget test for BigPharma.
//
// It validates the unauthenticated landing page state and the app initialization
// without requiring a logged-in user.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client_app/main.dart';
import 'package:client_app/core/theme/theme_provider.dart';
import 'package:client_app/services/auth_provider.dart';
import 'package:client_app/services/cart_provider.dart';
import 'package:client_app/services/profile_provider.dart';
import 'package:client_app/services/order_provider.dart';
import 'package:client_app/services/wishlist_provider.dart';
import 'package:client_app/services/support_provider.dart';
import 'package:client_app/services/notification_provider.dart';
import 'package:client_app/services/invoice_provider.dart';
import 'package:client_app/services/review_provider.dart';
import 'package:client_app/services/complaint_provider.dart';

Widget wrapWithProviders(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()..init()),
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
    child: child,
  );
}

void main() {
  testWidgets('LandingPage loads correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final binding = tester.binding;
    binding.window.physicalSizeTestValue = const Size(360, 640);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(wrapWithProviders(const MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('BigPharma'), findsWidgets);
    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Inscription'), findsOneWidget);
  });

  testWidgets('LandingPage displays hero content and actions', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final binding = tester.binding;
    binding.window.physicalSizeTestValue = const Size(360, 640);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(wrapWithProviders(const MyApp()));
    await tester.pumpAndSettle();

    expect(
      find.textContaining(
        'BigPharma rend vos commandes pharmaceutiques simples et intuitives.',
      ),
      findsOneWidget,
    );
    expect(find.text('Connexion'), findsOneWidget);
  });

  testWidgets('LandingPage has login and register buttons', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final binding = tester.binding;
    binding.window.physicalSizeTestValue = const Size(360, 640);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(wrapWithProviders(const MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Inscription'), findsOneWidget);
  });
}
