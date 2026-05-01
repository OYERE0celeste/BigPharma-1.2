import 'package:flutter_test/flutter_test.dart';
import 'package:epharma/models/product_model.dart';

void main() {
  group('Product Model Tests', () {
    test('should correctly calculate total stock from lots', () {
      final product = Product(
        id: '1',
        name: 'Test',
        category: 'Test',
        description: '',
        barcode: '',
        prescriptionRequired: false,
        purchasePrice: 10.0,
        sellingPrice: 15.0,
        lowStockThreshold: 5,
        lots: [
          Lot(
            lotNumber: 'L1',
            manufacturingDate: DateTime.now(),
            expirationDate: DateTime.now().add(Duration(days: 100)),
            quantity: 10,
            quantityAvailable: 10,
            costPrice: 10.0,
          ),
          Lot(
            lotNumber: 'L2',
            manufacturingDate: DateTime.now(),
            expirationDate: DateTime.now().add(Duration(days: 200)),
            quantity: 20,
            quantityAvailable: 5,
            costPrice: 10.0,
          ),
        ],
      );

      expect(product.totalStock, 15);
    });

    test('should determine correct stock status', () {
      final lowStockProduct = Product(
        id: '1',
        name: 'Test',
        category: 'Test',
        description: '',
        barcode: '',
        prescriptionRequired: false,
        purchasePrice: 10.0,
        sellingPrice: 15.0,
        lowStockThreshold: 10,
        lots: [
          Lot(
            lotNumber: 'L1',
            manufacturingDate: DateTime.now(),
            expirationDate: DateTime.now().add(Duration(days: 100)),
            quantity: 10,
            quantityAvailable: 5,
            costPrice: 10.0,
          ),
        ],
      );

      expect(lowStockProduct.stockStatus, StockStatus.lowStock);
    });

    test('should correctly calculate profit margin', () {
      final product = Product(
        id: '1',
        name: 'Test',
        category: 'Test',
        description: '',
        barcode: '',
        prescriptionRequired: false,
        purchasePrice: 100.0,
        sellingPrice: 150.0,
        lowStockThreshold: 10,
        lots: [],
      );

      expect(product.profitMargin, 50.0);
    });

    test('fromJson should handle both string and num for prices', () {
      final json = {
        'id': 'p123',
        'name': 'Aspirin',
        'purchasePrice': '10.5',
        'sellingPrice': 20.0,
        'lots': [],
      };

      final product = Product.fromJson(json);

      expect(product.id, 'p123');
      expect(product.name, 'Aspirin');
      expect(product.purchasePrice, 10.5);
      expect(product.sellingPrice, 20.0);
    });
  });

  group('Lot Model Tests', () {
    test('should identify expired lots', () {
      final expiredLot = Lot(
        lotNumber: 'L1',
        manufacturingDate: DateTime.now(),
        expirationDate: DateTime.now().subtract(Duration(days: 1)),
        quantity: 10,
        quantityAvailable: 10,
        costPrice: 10.0,
      );

      expect(expiredLot.status, LotStatus.expired);
    });

    test('should identify lots near expiration', () {
      final nearExpLot = Lot(
        lotNumber: 'L1',
        manufacturingDate: DateTime.now(),
        expirationDate: DateTime.now().add(Duration(days: 15)),
        quantity: 10,
        quantityAvailable: 10,
        costPrice: 10.0,
      );

      expect(nearExpLot.status, LotStatus.nearExpiration);
    });
  });
}
