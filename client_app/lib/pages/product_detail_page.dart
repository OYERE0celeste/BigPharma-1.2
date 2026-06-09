import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:client_app/models/product.dart';
import 'package:client_app/services/auth_provider.dart';
import 'package:client_app/services/cart_provider.dart';
import 'package:client_app/services/review_provider.dart';
import 'package:client_app/widgets/app_notification.dart';
import 'package:client_app/widgets/review_section.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().loadProductReviews(widget.product.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final product = widget.product;
    final stockColor = _stockColor(product.stockStatus);
    final canAddToCart = !product.isOutOfStock;
    final reviewProvider = context.watch<ReviewProvider>();
    final reviews = reviewProvider.reviewsForProduct(product.id);
    final summary = reviewProvider.summaryForProduct(product.id);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_${product.id}',
                child: Container(
                  decoration: BoxDecoration(color: primary.withOpacity(0.1)),
                  child: _buildProductImage(product.image, primary),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        product.stockStatusLabel,
                        style: TextStyle(
                          color: stockColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.sellingPrice.toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: primary,
                    ),
                  ),
                  if (product.isLowStock) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Reste ${product.availableStock} en stock',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: stockColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isEmpty
                        ? "Aucune description disponible pour ce produit. Veuillez contacter un pharmacien pour plus d'informations."
                        : product.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onBackground,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          context,
                          Icons.inventory_2_outlined,
                          'Stock',
                          '${product.availableStock}',
                        ),
                        _buildInfoItem(
                          context,
                          Icons.verified_user_outlined,
                          'Qualite',
                          'Certifie',
                        ),
                        _buildInfoItem(
                          context,
                          Icons.local_shipping_outlined,
                          'Retrait',
                          'Rapide',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ReviewSection(
                    summary: summary,
                    reviews: reviews,
                    isLoading: reviewProvider.isLoading,
                    onWriteReview: () => _showReviewDialog(context, product.id),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: canAddToCart
                    ? () {
                        context.read<CartProvider>().addItem(product);
                        Navigator.pop(context);
                        AppScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} ajoute au panier'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: primary,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  canAddToCart ? 'Ajouter au panier' : 'Indisponible',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReviewDialog(BuildContext context, String productId) async {
    if (!context.read<AuthProvider>().isAuthenticated) {
      AppScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connectez-vous pour laisser un avis apres achat.'),
        ),
      );
      return;
    }

    final commentController = TextEditingController();
    final serviceController = TextEditingController();
    int rating = 5;
    int serviceRating = 5;
    bool lightDissatisfaction = false;
    bool wouldRecommend = true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Donner mon avis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Note du produit'),
                    _StarSelector(
                      value: rating,
                      onChanged: (value) => setModalState(() => rating = value),
                    ),
                    const SizedBox(height: 12),
                    const Text('Note du service'),
                    _StarSelector(
                      value: serviceRating,
                      onChanged: (value) =>
                          setModalState(() => serviceRating = value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      minLines: 3,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Commentaire sur le produit',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: serviceController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Retour sur la qualite du service',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: lightDissatisfaction,
                      title: const Text('Signaler une insatisfaction legere'),
                      onChanged: (value) =>
                          setModalState(() => lightDissatisfaction = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: wouldRecommend,
                      title: const Text('Je recommanderais ce produit'),
                      onChanged: (value) =>
                          setModalState(() => wouldRecommend = value),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          try {
                            await context.read<ReviewProvider>().submitReview(
                              productId: productId,
                              rating: rating,
                              comment: commentController.text.trim(),
                              serviceRating: serviceRating,
                              serviceComment: serviceController.text.trim(),
                              dissatisfactionLevel: lightDissatisfaction
                                  ? 'legere'
                                  : 'aucune',
                              wouldRecommend: wouldRecommend,
                            );
                            if (!mounted) return;
                            Navigator.pop(context);
                            AppScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Merci, votre avis a ete envoye.',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            AppScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        child: const Text('Envoyer mon avis'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProductImage(String image, Color primary) {
    if (image.startsWith('http')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildProductPlaceholder(primary),
      );
    }

    return _buildProductPlaceholder(primary);
  }

  Widget _buildProductPlaceholder(Color primary) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: primary.withOpacity(0.10),
      child: Center(
        child: Text(
          'Image indisponible',
          style: TextStyle(
            color: primary.withOpacity(0.85),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Color _stockColor(ProductStockStatus status) {
    switch (status) {
      case ProductStockStatus.inStock:
        return Colors.green;
      case ProductStockStatus.lowStock:
        return Colors.orange;
      case ProductStockStatus.outOfStock:
        return Colors.red;
    }
  }
}

class _StarSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _StarSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
        (index) => IconButton(
          onPressed: () => onChanged(index + 1),
          icon: Icon(
            index < value ? Icons.star_rounded : Icons.star_border_rounded,
            color: Colors.amber,
          ),
        ),
      ),
    );
  }
}
