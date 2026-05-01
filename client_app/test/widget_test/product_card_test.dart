import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:client_app/models/product.dart';
import 'package:client_app/widgets/product_card.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  const testProduct = Product(
    id: '123',
    name: 'Test Aspirine',
    sellingPrice: 1500,
    category: 'Analgésique',
    description: 'Une description de test',
    stockQuantity: 50,
  );

  testWidgets('ProductCard displays product information correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 300,
            child: ProductCard(
              product: testProduct,
              onAddTap: () {},
              onDetailsTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Test Aspirine'), findsOneWidget);
    expect(find.text('1500 FCFA'), findsOneWidget);
    expect(find.text('Analgésique'), findsOneWidget);
    expect(find.byIcon(Icons.add_shopping_cart), findsOneWidget);
  });

  testWidgets('ProductCard calls onDetailsTap when tapped', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(
            product: testProduct,
            onDetailsTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ProductCard));
    expect(tapped, isTrue);
  });
}
