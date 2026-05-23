import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client_app/models/product.dart';
import 'package:client_app/services/auth_provider.dart';
import 'package:client_app/services/cart_provider.dart';
import 'package:client_app/services/review_provider.dart';
import 'package:client_app/widgets/app_notification.dart';
import 'package:client_app/widgets/review_section.dart';

class ProductDetailsBottomSheet extends StatefulWidget {
  final Product product;
  final ScrollController scrollController;

  const ProductDetailsBottomSheet({
    super.key,
    required this.product,
    required this.scrollController,
  });

  static void show(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.35,
          maxChildSize: 0.96,
          snap: true,
          snapSizes: const [0.65, 0.96],
          builder: (context, scrollController) {
            return ProductDetailsBottomSheet(
              product: product,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  @override
  State<ProductDetailsBottomSheet> createState() =>
      _ProductDetailsBottomSheetState();
}

class _ProductDetailsBottomSheetState extends State<ProductDetailsBottomSheet> {
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

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
              children: [
                Center(
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Hero(
                        tag: 'product_sheet_${product.id}',
                        child: product.image.startsWith('http')
                            ? Image.network(product.image, fit: BoxFit.cover)
                            : Icon(
                                Icons.medication_rounded,
                                size: 84,
                                color: primary.withOpacity(0.4),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                    Row(
                      children: [
                        CircleAvatar(radius: 5, backgroundColor: stockColor),
                        const SizedBox(width: 6),
                        Text(
                          product.stockStatusLabel,
                          style: TextStyle(
                            color: stockColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${product.sellingPrice.toStringAsFixed(0)} FCFA',
                  style: TextStyle(
                    fontSize: 22,
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description.isEmpty
                      ? "Aucune description disponible pour ce produit. Veuillez contacter un pharmacien pour plus d'informations."
                      : product.description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[100]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(
                        Icons.inventory_2_outlined,
                        'Stock',
                        '${product.availableStock}',
                      ),
                      _buildInfoItem(
                        Icons.verified_user_outlined,
                        'Qualite',
                        'Certifie',
                      ),
                      _buildInfoItem(
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
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
                                content: Text(
                                  '${product.name} ajoute au panier',
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: primary,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      canAddToCart ? 'Ajouter au panier' : 'Indisponible',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
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
      backgroundColor: Colors.white,
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
