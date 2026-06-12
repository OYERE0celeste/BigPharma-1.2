import 'dart:async';

import 'package:flutter/material.dart' hide SearchBar;
import 'package:provider/provider.dart';
import 'package:client_app/services/cart_provider.dart';
import 'package:client_app/widgets/app_notification.dart';
import 'package:client_app/widgets/brand_title.dart';
import 'package:client_app/widgets/bp_theme.dart';
import 'package:client_app/widgets/index.dart';
import 'package:client_app/services/product_service.dart';
import 'package:client_app/models/product.dart';
import 'cart_page.dart';
import 'package:client_app/pages/login_page.dart';
import 'package:client_app/services/auth_provider.dart';
import 'package:client_app/widgets/settings_dialog.dart';
import 'package:client_app/services/notification_provider.dart';
import 'package:client_app/widgets/notification_panel.dart';
import 'invoices_page.dart';
import 'relation_client_page.dart';
import 'package:client_app/widgets/telegram_page_route.dart';
import 'package:client_app/widgets/product_details_bottom_sheet.dart';
import 'package:client_app/widgets/barcode_scanner_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _popularProductsFuture;
  late Future<List<Product>> _newProductsFuture;
  final List<String> _categories = [
    'Tout',
    'Dermo-cosmétique (Soins du visage)',
    'Hygiène Corporelle',
    'Soins Capillaires',
    'Santé Bucco-dentaire',
    'Maternité et Bébé',
    'Compléments Alimentaires et Vitamines',
    'Premiers Secours et Bobologie',
    'Protection Solaire',
    'Diététique et Phytothérapie',
    'Orthopédie et Contention Légère',
  ];
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';
  String _selectedCategory = 'Tout';

  @override
  void initState() {
    super.initState();
    _popularProductsFuture = _productService.getPopularProducts();
    _newProductsFuture = _productService.getNewProducts();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _scheduleFilterUpdate() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), _updateFilters);
  }

  void _updateFilters() {
    setState(() {
      _popularProductsFuture = _productService.getPopularProducts(
        search: _searchQuery,
        category: _selectedCategory,
      );
      _newProductsFuture = _productService.getNewProducts(
        search: _searchQuery,
        category: _selectedCategory,
      );
    });
  }

  void _refreshData() {
    setState(() {
      _popularProductsFuture = _productService.getPopularProducts(
        search: _searchQuery,
        category: _selectedCategory,
      );
      _newProductsFuture = _productService.getNewProducts(
        search: _searchQuery,
        category: _selectedCategory,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final authProvider = context.watch<AuthProvider>();
    final notificationProvider = context.read<NotificationProvider>();

    if (authProvider.isAuthenticated && !notificationProvider.isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notificationProvider.ensureInitialized();
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: const BrandTitle(title: 'BigPharma'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 26),
            tooltip: 'Scanner un produit',
            onPressed: () async {
              final product = await BarcodeScannerDialog.show(context);
              if (product != null && mounted) {
                ProductDetailsBottomSheet.show(context, product);
              }
            },
          ),
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                icon: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 26),
                    if (notificationProvider.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: BpColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          notificationProvider.unreadCount > 9
                              ? '9+'
                              : '${notificationProvider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  _showNotificationPanel(context);
                },
              ),
            ),
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, _) => Padding(
              padding: const EdgeInsets.only(right: 14),
              child: PopupMenuButton<String>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (value) async {
                  if (value == 'settings') {
                    SettingsDialog.show(context);
                  } else if (value == 'logout') {
                    final logout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Déconnexion'),
                        content: Text(
                          'Voulez-vous vraiment vous déconnecter, ${auth.user?.fullName ?? ''} ?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              'Déconnexion',
                              style: TextStyle(color: BpColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (logout == true) auth.logout();
                  } else if (value == 'login') {
                    Navigator.push(
                      context,
                      TelegramPageRoute(child: const LoginPage()),
                    );
                  }
                },
                itemBuilder: (context) => auth.isAuthenticated
                    ? [
                        PopupMenuItem(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(Icons.settings_outlined, size: 20),
                              SizedBox(width: 12),
                              Text('Paramètres'),
                            ],
                          ),
                        ),
                        PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                size: 20,
                                color: BpColors.error,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Déconnexion',
                                style: TextStyle(color: BpColors.error),
                              ),
                            ],
                          ),
                        ),
                      ]
                    : [
                        PopupMenuItem(
                          value: 'login',
                          child: Row(
                            children: [
                              Icon(Icons.login_rounded, size: 20),
                              SizedBox(width: 12),
                              Text('Se connecter'),
                            ],
                          ),
                        ),
                      ],
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: auth.isAuthenticated
                      ? primary.withOpacity(0.18)
                      : BpColors.surfaceMuted,
                  child: Icon(
                    auth.isAuthenticated
                        ? Icons.person_rounded
                        : Icons.account_circle_rounded,
                    size: 24,
                    color: auth.isAuthenticated
                        ? primary
                        : BpColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, child) => Stack(
          alignment: Alignment.center,
          children: [
            FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const CartPage(),
                );
              },
              backgroundColor: primary,
              foregroundColor: Colors.white,
              child: Icon(Icons.shopping_cart_rounded),
            ),
            if (cart.totalItems > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: BpColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    '${cart.totalItems}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isDesktop = constraints.maxWidth >= 1100;
          final bool isTablet = constraints.maxWidth >= 720;
          final double horizontalPadding = isDesktop ? 28 : 16;
          final int crossAxisCount = isDesktop
              ? 4
              : isTablet
              ? 3
              : 2;

          return RefreshIndicator(
            onRefresh: () async {
              _refreshData();
              await Future.wait([_popularProductsFuture, _newProductsFuture]);
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                100,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          final name =
                              auth.user?.fullName.split(' ').first ??
                              'Pharmacien';
                          final hour = DateTime.now().hour;
                          final greeting = hour < 12
                              ? 'Bonjour'
                              : hour < 18
                              ? 'Bon après-midi'
                              : 'Bonsoir';

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$greeting, $name !',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Recherchez un médicament ou parcourez vos favoris.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],
                          );
                        },
                      ),
                      SearchBar(
                        primary: primary,
                        controller: _searchController,
                        onChanged: (value) {
                          _searchQuery = value;
                          _scheduleFilterUpdate();
                        },
                      ),
                      const SizedBox(height: 24),
                      SectionTitle(
                        title: 'Catégories',
                        actionLabel: 'Voir tout',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 50,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return CategoryChip(
                              label: category,
                              isSelected: _selectedCategory == category,
                              onTap: () {
                                setState(() => _selectedCategory = category);
                                _updateFilters();
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 28),
                      SectionTitle(
                        title: 'Produits populaires',
                        actionLabel: 'Plus de produits',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<Product>>(
                        future: _popularProductsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (snapshot.hasError ||
                              !snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return _buildErrorState(
                              'Aucun produit populaire trouvé',
                            );
                          }
                          final products = snapshot.data!;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: isDesktop
                                      ? 0.86
                                      : isTablet
                                      ? 0.82
                                      : 0.74,
                                ),
                            itemBuilder: (_, int index) {
                              return ProductCard(
                                product: products[index],
                                onAddTap: () {
                                  context.read<CartProvider>().addItem(
                                    products[index],
                                  );
                                  AppScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${products[index].name} ajouté au panier',
                                      ),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: primary,
                                    ),
                                  );
                                },
                                onDetailsTap: () {
                                  ProductDetailsBottomSheet.show(
                                    context,
                                    products[index],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      SectionTitle(
                        title: 'Promotions / Nouveautés',
                        actionLabel: 'Découvrir',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: isDesktop ? 280 : 300,
                        child: FutureBuilder<List<Product>>(
                          future: _newProductsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError ||
                                !snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text('Aucune nouveauté'),
                              );
                            }
                            final products = snapshot.data!;
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: products.length,
                              separatorBuilder: (_, index) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (_, int index) {
                                return SizedBox(
                                  width: isDesktop ? 280 : 240,
                                  child: ProductCard(
                                    product: products[index],
                                    onAddTap: () {
                                      AppScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${products[index].name} ajouté au panier',
                                          ),
                                        ),
                                      );
                                    },
                                    onDetailsTap: () {
                                      ProductDetailsBottomSheet.show(
                                        context,
                                        products[index],
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 28),
                      SectionTitle(title: 'Mes commandes'),
                      const SizedBox(height: 12),
                      OrdersPanel(primary: primary),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.description_outlined),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              "J'ai une ordonnance",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D62),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.grey)),
            TextButton(onPressed: _refreshData, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }

  void _showNotificationPanel(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned(
            top: kToolbarHeight + 10,
            right: 10,
            child: Material(
              color: Colors.transparent,
              child: NotificationPanel(
                onTap: (type, data) {
                  Navigator.pop(context); // Close dialog
                  if (type == 'support') {
                    Navigator.push(
                      context,
                      TelegramPageRoute(
                        child: const RelationClientPage(initialIndex: 0),
                      ),
                    );
                  } else if (type == 'invoice') {
                    InvoicesDialog.show(context);
                  } else if (type == 'review') {
                    Navigator.push(
                      context,
                      TelegramPageRoute(
                        child: const RelationClientPage(initialIndex: 1),
                      ),
                    );
                  } else if (type == 'complaint') {
                    Navigator.push(
                      context,
                      TelegramPageRoute(
                        child: const RelationClientPage(initialIndex: 2),
                      ),
                    );
                  } else if (type == 'order') {
                    // Navigate to orders (which are on the home page)
                    // For now, just scroll to bottom or show a snackbar
                    AppScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Vérifiez "Mes commandes" en bas de la page',
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
