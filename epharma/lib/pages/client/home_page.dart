import 'package:flutter/material.dart' hide SearchBar;
import 'package:provider/provider.dart';
import '../../client_services/cart_provider.dart';
import '../../client_widgets/index.dart';
import '../../client_services/product_service.dart';
import '../../client_models/product.dart';
import 'product_detail_page.dart';
import 'cart_page.dart';
import '../../screens/auth/login_page.dart';
import '../../providers/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _popularProductsFuture;
  late Future<List<Product>> _newProductsFuture;

  @override
  void initState() {
    super.initState();
    _popularProductsFuture = _productService.getPopularProducts();
    _newProductsFuture = _productService.getNewProducts();
  }

  void _refreshData() {
    setState(() {
      _popularProductsFuture = _productService.getPopularProducts();
      _newProductsFuture = _productService.getNewProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 20,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: primary.withOpacity(0.14),
              child: Icon(Icons.local_pharmacy_rounded, color: primary),
            ),
            const SizedBox(width: 10),
            const Text('BigPharma'),
          ],
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, _) => Padding(
              padding: const EdgeInsets.only(right: 14),
              child: IconButton(
                onPressed: () async {
                  if (auth.isAuthenticated) {
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
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Déconnexion',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (logout == true) auth.logout();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  }
                },
                icon: Icon(
                  auth.isAuthenticated
                      ? Icons.person_rounded
                      : Icons.account_circle_rounded,
                  size: 32,
                  color: auth.isAuthenticated ? primary : null,
                ),
                tooltip: auth.isAuthenticated
                    ? 'Profil (${auth.user?.fullName})'
                    : 'Connexion',
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
              backgroundColor: primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.shopping_cart_rounded),
            ),
            if (cart.totalItems > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
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
                      SearchBar(primary: primary),
                      const SizedBox(height: 24),
                      SectionTitle(
                        title: 'Catégories',
                        actionLabel: 'Voir tout',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            CategoryChip(label: 'Tout', onTap: () {}),
                            const SizedBox(width: 8),
                            CategoryChip(label: 'Analgésique', onTap: () {}),
                            const SizedBox(width: 8),
                            CategoryChip(label: 'Antibiotique', onTap: () {}),
                            const SizedBox(width: 8),
                            CategoryChip(
                              label: 'Anti-inflammatoire',
                              onTap: () {},
                            ),
                            const SizedBox(width: 8),
                            CategoryChip(label: 'Sirop', onTap: () {}),
                            const SizedBox(width: 8),
                            CategoryChip(label: 'Vitamines', onTap: () {}),
                          ],
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
                                  childAspectRatio: isDesktop ? 0.86 : 0.8,
                                ),
                            itemBuilder: (_, int index) {
                              return ProductCard(
                                product: products[index],
                                onAddTap: () {
                                  context.read<CartProvider>().addItem(
                                    products[index],
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${products[index].name} ajouté au panier',
                                      ),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                onDetailsTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailPage(
                                        product: products[index],
                                      ),
                                    ),
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
                        height: 280,
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
                                      ScaffoldMessenger.of(
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailPage(
                                                product: products[index],
                                              ),
                                        ),
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
}
