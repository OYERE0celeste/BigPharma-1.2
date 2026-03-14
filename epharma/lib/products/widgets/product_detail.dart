import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import 'lot_card.dart';

class ProductDetailsPanel extends StatelessWidget {
  final Product product;

  const ProductDetailsPanel({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 900,
        height: 620,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _leftColumn()),
                    const SizedBox(width: 16),
                    Expanded(child: _rightColumn()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leftColumn() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _infoRow('Name', product.name),
          _infoRow('Description', product.description),
          _infoRow('Category', product.category),
          _infoRow('Supplier', product.supplier),
          _infoRow('Barcode', product.barcode),
          _infoRow('Prescription', product.prescriptionRequired ? 'Yes' : 'No'),
          _infoRow(
            'Purchase price',
            '€${product.purchasePrice.toStringAsFixed(2)}',
          ),
          _infoRow(
            'Selling price',
            '€${product.sellingPrice.toStringAsFixed(2)}',
          ),
          _infoRow(
            'Profit margin',
            '€${product.profitMargin.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          const Text(
            'Movement history',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: const Center(child: Text('Movement history placeholder')),
          ),
        ],
      ),
    );
  }

  Widget _rightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stock & Lots',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Total stock: ${product.totalStock}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text('Low stock threshold: ${product.lowStockThreshold}'),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: product.lots.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) => LotCard(lot: product.lots[index]),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      children: [
        Expanded(flex: 2, child: Text('$label:')),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}