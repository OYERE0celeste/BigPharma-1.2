
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:client_app/pages/login_page.dart';
import 'package:client_app/services/auth_provider.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    when(() => mockAuthProvider.isLoading).thenReturn(false);
  });

  group('LoginPage Golden Tests', () {
    testGoldens('LoginPage visual regression test', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [
          Device.phone,
          Device.iphone11,
          Device.tabletPortrait,
        ])
        ..addScenario(
          widget: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const LoginPage(),
          ),
          name: 'default_state',
        );

      await tester.pumpDeviceBuilder(builder);
      
      // Note: First run requires `flutter test --update-goldens` to generate the golden files
      await screenMatchesGolden(tester, 'login_page_multiple_devices');
    });
  });
}
