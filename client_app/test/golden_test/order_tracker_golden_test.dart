import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:client_app/widgets/order_tracker.dart';

void main() {
  testGoldens('OrderTracker states goldens', (tester) async {
    final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1)
      ..addScenario('Pending', const OrderTracker(status: 'en_attente'))
      ..addScenario('Preparing', const OrderTracker(status: 'en_preparation'))
      ..addScenario('Ready', const OrderTracker(status: 'pret_pour_recuperation'))
      ..addScenario('Validated', const OrderTracker(status: 'validee'))
      ..addScenario('Cancelled', const OrderTracker(status: 'annulee'));

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'order_tracker_states');
  });
}
