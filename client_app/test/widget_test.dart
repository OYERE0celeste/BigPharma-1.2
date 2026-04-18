// This is a basic Flutter widget test for BigPharma HomePage.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/main.dart';

void main() {
  testWidgets('BigPharma HomePage loads correctly', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that BigPharma title is present in the AppBar
    expect(find.text('BigPharma'), findsWidgets);

    // Verify that the search bar is present
    expect(find.text('Rechercher un medicament...'), findsOneWidget);

    // Verify that Categories section is present
    expect(find.text('Categories'), findsOneWidget);

    // Verify that popular products section is visible
    expect(find.text('Produits populaires'), findsOneWidget);

    // Verify that the pharmacy icon is present
    expect(find.byIcon(Icons.local_pharmacy_rounded), findsOneWidget);

    // Verify that the shopping cart FAB is present
    expect(find.byIcon(Icons.shopping_cart_rounded), findsOneWidget);
  });

  testWidgets('HomePage displays product categories', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Verify that some pharmaceutical categories are displayed
    expect(find.text('Antalgiques'), findsOneWidget);
    expect(find.text('Antibiotiques'), findsOneWidget);
    expect(find.text('Vitamines'), findsOneWidget);
  });

  testWidgets('HomePage displays products', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify that popular products are displayed
    expect(find.text('Paracetamol 500mg'), findsOneWidget);
    expect(find.text('Amoxicilline 1g'), findsOneWidget);
  });
}
