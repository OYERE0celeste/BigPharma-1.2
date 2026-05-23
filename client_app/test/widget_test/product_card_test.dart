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
    category: 'Analgesique',
    description: 'Une description de test',
    stockQuantity: 50,
    apiStockStatus: ProductStockStatus.inStock,
  );

  const lowStockProduct = Product(
    id: '456',
    name: 'Test Stock Faible',
    sellingPrice: 900,
    category: 'Test',
    description: 'Faible stock',
    stockQuantity: 3,
    apiStockStatus: ProductStockStatus.lowStock,
  );

  const outOfStockProduct = Product(
    id: '789',
    name: 'Test Rupture',
    sellingPrice: 1200,
    category: 'Test',
    description: 'Rupture',
    stockQuantity: 12,
    apiStockStatus: ProductStockStatus.outOfStock,
  );

  Widget buildCard(
    Product product, {
    VoidCallback? onAddTap,
    VoidCallback? onDetailsTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 240,
            height: 420,
            child: ProductCard(
              product: product,
              onAddTap: onAddTap,
              onDetailsTap: onDetailsTap,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('ProductCard displays product information correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildCard(testProduct, onAddTap: () {}, onDetailsTap: () {}),
    );

    expect(find.text('Test Aspirine'), findsOneWidget);
    expect(find.text('1500 FCFA'), findsOneWidget);
    expect(find.text('Analgesique'), findsOneWidget);
    expect(find.text('En stock'), findsOneWidget);
    expect(find.byIcon(Icons.add_shopping_cart), findsOneWidget);
  });

  testWidgets('ProductCard displays low stock status', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildCard(lowStockProduct, onAddTap: () {}));

    expect(find.text('Stock faible'), findsOneWidget);
  });

  testWidgets('ProductCard disables add to cart when product is out of stock', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildCard(outOfStockProduct, onAddTap: () {}));

    expect(find.text('Rupture'), findsWidgets);
    final iconButton = tester.widget<IconButton>(find.byType(IconButton));
    expect(iconButton.onPressed, isNull);
  });

  testWidgets('ProductCard calls onDetailsTap when tapped', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      buildCard(testProduct, onDetailsTap: () => tapped = true),
    );

    await tester.tap(find.byType(ProductCard));
    expect(tapped, isTrue);
  });
}
