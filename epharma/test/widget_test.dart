import 'package:epharma/main.dart';
import 'package:epharma/providers/auth_provider.dart';
import 'package:epharma/providers/settings_provider.dart';
import 'package:epharma/screens/auth/login_page.dart';
import 'package:epharma/settings/profil_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeAuthProvider extends AuthProvider {
  _FakeAuthProvider({required this.loading, required this.authenticated});

  final bool loading;
  final bool authenticated;

  @override
  bool get isLoading => loading;

  @override
  bool get isAuthenticated => authenticated;
}

class _InteractiveAuthProvider extends AuthProvider {
  _InteractiveAuthProvider({required this.loginResult});

  final bool loginResult;
  int loginCalls = 0;

  @override
  bool get isLoading => false;

  @override
  Future<bool> login(String email, String password) async {
    loginCalls += 1;
    return loginResult;
  }
}

void main() {
  testWidgets('Login page renders core auth UI', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1200));
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => _FakeAuthProvider(loading: false, authenticated: false),
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    expect(find.text('BigPharma SaaS'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Mot de passe oublié ?'), findsOneWidget);
    await tester.binding.setSurfaceSize(null);
  });

  test('SettingsProvider exposes expected defaults', () {
    final provider = SettingsProvider();

    expect(provider.isLoading, isFalse);
    expect(provider.availableRoles, contains('admin'));
    expect(provider.settings.twoFactorEnabled, isFalse);
  });

  testWidgets('AuthWrapper shows login when unauthenticated', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1200));
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => _FakeAuthProvider(loading: false, authenticated: false),
        child: const MaterialApp(home: AuthWrapper()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('AuthWrapper shows loader while auth state is loading', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1200));
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => _FakeAuthProvider(loading: true, authenticated: false),
        child: const MaterialApp(home: AuthWrapper()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Login page does not require a named route after successful login', (
    WidgetTester tester,
  ) async {
    final provider = _InteractiveAuthProvider(loginResult: true);

    await tester.binding.setSurfaceSize(const Size(1600, 1200));
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: provider,
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    await tester.enterText(
      find.byType(TextField).at(0),
      'admin@pharmacie.com',
    );
    await tester.enterText(find.byType(TextField).at(1), 'Password123');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(provider.loginCalls, 1);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('ProfilDialog renders without asset dependencies', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(),
        child: const MaterialApp(
          home: Scaffold(body: ProfilDialog()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text('Fermer'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });
}
