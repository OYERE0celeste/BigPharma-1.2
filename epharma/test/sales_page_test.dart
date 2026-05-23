import 'package:epharma/models/product_model.dart';
import 'package:epharma/models/order_model.dart';
import 'package:epharma/models/sale_model.dart';
import 'package:epharma/models/user_model.dart';
import 'package:epharma/models/activity_model.dart';
import 'package:epharma/providers/auth_provider.dart';
import 'package:epharma/providers/finance_provider.dart';
import 'package:epharma/providers/order_provider.dart';
import 'package:epharma/providers/product_provider.dart';
import 'package:epharma/providers/sales_provider.dart';
import 'package:epharma/security/rbac.dart';
import 'package:epharma/ventes/pharmacy_sales_page.dart';
import 'package:epharma/ventes/widgets/payment_section.dart';
import 'package:epharma/widgets/bp_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeAuthProvider extends AuthProvider {
  _FakeAuthProvider(this._user);

  final UserModel _user;

  @override
  UserModel? get user => _user;

  @override
  bool get isLoading => false;
}

class _FakeProductProvider extends ProductProvider {
  _FakeProductProvider(this._products);

  final List<Product> _products;

  @override
  List<Product> get products => _products;

  @override
  int get totalProducts => _products.length;

  @override
  bool get isLoading => false;

  @override
  Future<void> loadProducts({bool forceRefresh = false}) async {}
}

class _FakeSalesProvider extends SalesProvider {
  _FakeSalesProvider(this._sales);

  final List<Sale> _sales;

  @override
  List<Sale> get sales => _sales;

  @override
  int get totalSalesCount => _sales.length;

  @override
  bool get isLoading => false;

  @override
  Future<void> loadSales({bool forceRefresh = false}) async {}

  @override
  Future<Sale?> createSale({
    required List<CartItem> items,
    required double discountAmount,
    required double taxAmount,
    required String paymentMethod,
    required double amountReceived,
  }) async {
    final sale = Sale(
      id: 's-created',
      invoiceNumber: 'INV-CREATED',
      dateTime: DateTime(2026, 5, 22, 11, 00),
      client: 'Client test',
      items: items
          .map(
            (item) => SaleItem(
              productId: item.product.id,
              productName: item.product.name,
              lotNumber: item.selectedLot.lotNumber,
              expirationDate: item.selectedLot.expirationDate,
              quantity: item.quantity,
              unitPrice: item.product.sellingPrice,
              total: item.subtotal,
            ),
          )
          .toList(),
      subtotal: items.fold<double>(0, (sum, item) => sum + item.subtotal),
      discountAmount: discountAmount,
      taxAmount: taxAmount,
      totalAmount:
          items.fold<double>(0, (sum, item) => sum + item.subtotal) -
          discountAmount +
          taxAmount,
      paymentMethod: paymentMethod,
      amountReceived: amountReceived,
      changeAmount:
          amountReceived -
          (items.fold<double>(0, (sum, item) => sum + item.subtotal) -
              discountAmount +
              taxAmount),
      pharmacist: 'Admin',
    );
    _sales.insert(0, sale);
    notifyListeners();
    return sale;
  }
}

class _FakeFinanceProvider extends FinanceProvider {
  @override
  Future<void> loadTransactions({bool forceRefresh = false}) async {}
}

class _FakeOrderProvider extends OrderProvider {
  _FakeOrderProvider(this._orders);

  final List<OrderModel> _orders;

  @override
  List<OrderModel> get orders => _orders;

  @override
  bool get isLoading => false;

  @override
  Future<void> fetchOrders({
    required AuthProvider authProvider,
    int page = 1,
    String? status,
    String? search,
    bool forceRefresh = false,
  }) async {}
}

void main() {
  final adminUser = UserModel(
    id: '1',
    fullName: 'Admin',
    email: 'admin@test.com',
    role: 'administrateur',
    companyId: 'company-1',
    permissions: permissionMap(const [
      AppPermission.makeSale,
      AppPermission.viewSalesHistory,
      AppPermission.viewProducts,
    ]),
  );

  final products = [
    Product(
      id: 'p1',
      name: 'Paracetamol',
      category: 'Antalgique',
      description: 'desc',
      barcode: '111',
      purchasePrice: 100,
      sellingPrice: 150,
      lowStockThreshold: 2,
      lots: [
        Lot(
          lotNumber: 'LOT-1',
          manufacturingDate: DateTime(2026, 1, 1),
          expirationDate: DateTime(2027, 1, 1),
          quantity: 10,
          quantityAvailable: 10,
          costPrice: 100,
        ),
      ],
    ),
  ];

  final sales = [
    Sale(
      id: 's1',
      invoiceNumber: 'INV-001',
      dateTime: DateTime(2026, 5, 22, 10, 30),
      client: 'Client test',
      items: const [],
      subtotal: 1000,
      discountAmount: 0,
      taxAmount: 0,
      totalAmount: 1000,
      paymentMethod: 'cash',
      amountReceived: 1000,
      changeAmount: 0,
      pharmacist: 'Admin',
    ),
  ];

  final orders = [
    OrderModel(
      id: 'o1',
      orderNumber: 'CMD-001',
      userId: '1',
      userName: 'Admin',
      clientId: 'c1',
      clientName: 'Alice',
      items: const [],
      totalPrice: 3200,
      status: OrderStatus.validee,
      createdAt: DateTime(2026, 5, 22, 9, 15),
      updatedAt: DateTime(2026, 5, 22, 9, 30),
      invoiceNumber: 'FAC-CMD-001',
    ),
  ];

  Widget buildPage() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => _FakeAuthProvider(adminUser),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => _FakeProductProvider(products),
        ),
        ChangeNotifierProvider<SalesProvider>(
          create: (_) => _FakeSalesProvider(sales),
        ),
        ChangeNotifierProvider<FinanceProvider>(
          create: (_) => _FakeFinanceProvider(),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => _FakeOrderProvider(orders),
        ),
      ],
      child: MaterialApp(
        theme: BpTheme.materialTheme(),
        home: const Scaffold(body: PharmacySalesPage()),
      ),
    );
  }

  testWidgets('sales page renders desktop content', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1000));
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text('POINT DE VENTE'), findsOneWidget);
    expect(find.text('PANIER'), findsOneWidget);
    expect(find.text('Paracetamol'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('sales history view renders after tap', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1000));
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Historique').first);
    await tester.pumpAndSettle();

    expect(find.text('HISTORIQUE DES VENTES'), findsOneWidget);
    expect(find.text('INV-001'), findsOneWidget);
    expect(find.text('CMD-001'), findsOneWidget);
    expect(find.textContaining('FAC-CMD-001'), findsOneWidget);
    expect(find.text('Voir la facture'), findsOneWidget);
    expect(find.text('Telecharger'), findsWidgets);

    await tester.tap(find.text('Voir la facture'));
    await tester.pumpAndSettle();

    expect(find.text('Facture INV-001'), findsOneWidget);
    expect(find.text('PHARMACIE LA FLORALE'), findsOneWidget);
    expect(find.text('Facture N INV-001 du 22/05/2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('payment section syncs with parent state updates', (
    WidgetTester tester,
  ) async {
    Widget buildPaymentSection({
      required PaymentMethod selectedPaymentMethod,
      required double amountReceived,
    }) {
      return MaterialApp(
        theme: BpTheme.materialTheme(),
        home: Scaffold(
          body: PaymentSection(
            totalAmount: 150,
            selectedPaymentMethod: selectedPaymentMethod,
            amountReceived: amountReceived,
            onPaymentMethodChanged: (_) {},
            onAmountReceivedChanged: (_) {},
          ),
        ),
      );
    }

    await tester.pumpWidget(
      buildPaymentSection(
        selectedPaymentMethod: PaymentMethod.card,
        amountReceived: 200,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Carte')).selected,
      isTrue,
    );

    await tester.pumpWidget(
      buildPaymentSection(
        selectedPaymentMethod: PaymentMethod.cash,
        amountReceived: 0,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Cash')).selected,
      isTrue,
    );
    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Carte')).selected,
      isFalse,
    );

    final amountField = tester.widget<TextField>(
      find.descendant(
        of: find.byType(PaymentSection),
        matching: find.byType(TextField),
      ),
    );
    expect(amountField.controller?.text ?? '', isEmpty);
  });
}
