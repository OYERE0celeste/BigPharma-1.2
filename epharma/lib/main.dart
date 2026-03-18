import 'package:epharma/fournisseurs/fournisseurs_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pharmacy_dashboard_page.dart';
import 'ventes/pharmacy_sales_page.dart';
import 'products/pharmacy_products_page.dart';
import 'clients/pharmacy_clients_page.dart';
import 'activites/activity_register_page.dart';
import 'finances/pharmacy_finance_page.dart';
import 'providers/product_provider.dart';
import 'providers/sales_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/finance_provider.dart';
import 'providers/supplier_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
      ],
      child: MaterialApp(
        title: 'E-Pharma',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const PharmacyDashboardPage(),
          '/products': (context) => const PharmacyProductsPage(),
          '/sales': (context) => const PharmacySalesPage(),
          '/clients': (context) => const PharmacyClientsPage(),
          '/activity': (context) => const PharmacyActivityRegisterPage(),
          '/suppliers': (context) => const PharmacySuppliersPage(),
          '/finance': (context) => const PharmacyFinancePage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
