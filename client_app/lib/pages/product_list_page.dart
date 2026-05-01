import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/index.dart';
import '../widgets/skeleton_loader.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  final String? category;
  final String? search;

  const ProductListPage({super.key, this.category, this.search});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();
  
  final List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      // Mocking a paginated API call for demo (since backend has limit/page)
      final newProducts = await _productService.getNewProducts(); // In real app, pass page/limit
      
      setState(() {
        _isLoading = false;
        if (newProducts.length < _limit) {
          _hasMore = false;
        }
        _products.addAll(newProducts);
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category ?? widget.search ?? 'Produits'),
      ),
      body: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: _products.length + (_hasMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index < _products.length) {
            final product = _products[index];
            return ProductCard(
              product: product,
              onDetailsTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => ProductDetailPage(product: product))
              ),
            );
          } else {
            return const SkeletonProductCard();
          }
        },
      ),
    );
  }
}
