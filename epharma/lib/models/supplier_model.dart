enum SupplierStatus { active, inactive, suspended }

class Supplier {
  final String id;
  final String name;
  final String contactName;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String country;
  final String notes;
  final DateTime createdAt;
  final SupplierStatus status;
  final int totalOrders;
  final int totalAmount;

  Supplier({
    required this.id,
    required this.name,
    required this.contactName,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    required this.country,
    this.notes = '',
    required this.createdAt,
    this.status = SupplierStatus.active,
    this.totalOrders = 0,
    this.totalAmount = 0,
  });

  // Getters calculés
  String get statusDisplay {
    switch (status) {
      case SupplierStatus.active:
        return 'Actif';
      case SupplierStatus.inactive:
        return 'Inactif';
      case SupplierStatus.suspended:
        return 'Suspendu';
    }
  }

  int get averageOrderAmount =>
      totalOrders > 0 ? totalAmount ~/ totalOrders : 0;

  // Méthodes utilitaires
  Supplier copyWith({
    String? id,
    String? name,
    String? contactName,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? country,
    String? notes,
    DateTime? createdAt,
    SupplierStatus? status,
    int? totalOrders,
    int? totalAmount,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      totalOrders: totalOrders ?? this.totalOrders,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  // Méthodes de validation
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool get isValidPhone {
    return RegExp(r'^[+]?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

  // Méthode pour ajouter une commande
  Supplier addOrder(int amount) {
    return copyWith(
      totalOrders: totalOrders + 1,
      totalAmount: totalAmount + amount,
    );
  }

  // Conversion pour JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactName': contactName,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'country': country,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'totalOrders': totalOrders,
      'totalAmount': totalAmount,
    };
  }

  // Création depuis JSON
  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id:
          json['_id']?.toString() ??
          json['id']?.toString() ??
          (json['_doc']?['_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? "",
      contactName: json['contactName']?.toString() ?? "",
      phone: json['phone']?.toString() ?? "",
      email: json['email']?.toString() ?? "",
      address: json['address']?.toString() ?? "",
      city: json['city']?.toString() ?? "",
      country: json['country']?.toString() ?? "",
      notes: json['notes']?.toString() ?? "",
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is String
                ? DateTime.parse(json['createdAt'])
                : DateTime.tryParse(json['createdAt'].toString()) ??
                      DateTime.now())
          : DateTime.now(),
      status: json['status'] != null
          ? SupplierStatus.values.firstWhere(
              (s) => s.name == json['status'].toString(),
              orElse: () => SupplierStatus.active,
            )
          : SupplierStatus.active,
      totalOrders: int.tryParse(json['totalOrders']?.toString() ?? '') ?? 0,
      totalAmount: int.tryParse(json['totalAmount']?.toString() ?? '') ?? 0,
    );
  }

  @override
  String toString() {
    return 'Supplier(id: $id, name: $name, contactName: $contactName, email: $email, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Supplier && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum SupplierOrderStatus { pending, confirmed, delivered, cancelled }

class SupplierOrder {
  final String id;
  final String supplierId;
  final String supplierName;
  final DateTime orderDate;
  final SupplierOrderStatus status;
  final List<SupplierOrderItem> items;
  final int totalAmount;
  final String? notes;
  final DateTime? deliveryDate;

  SupplierOrder({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.orderDate,
    this.status = SupplierOrderStatus.pending,
    required this.items,
    required this.totalAmount,
    this.notes,
    this.deliveryDate,
  });

  String get statusDisplay {
    switch (status) {
      case SupplierOrderStatus.pending:
        return 'En attente';
      case SupplierOrderStatus.confirmed:
        return 'Confirmée';
      case SupplierOrderStatus.delivered:
        return 'Livrée';
      case SupplierOrderStatus.cancelled:
        return 'Annulée';
    }
  }

  SupplierOrder copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    DateTime? orderDate,
    SupplierOrderStatus? status,
    List<SupplierOrderItem>? items,
    int? totalAmount,
    String? notes,
    DateTime? deliveryDate,
  }) {
    return SupplierOrder(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      deliveryDate: deliveryDate ?? this.deliveryDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'orderDate': orderDate.toIso8601String(),
      'status': status.name,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'notes': notes,
      'deliveryDate': deliveryDate?.toIso8601String(),
    };
  }

  factory SupplierOrder.fromJson(Map<String, dynamic> json) {
    return SupplierOrder(
      id: json['id'],
      supplierId: json['supplierId'],
      supplierName: json['supplierName'],
      orderDate: DateTime.parse(json['orderDate']),
      status: SupplierOrderStatus.values.firstWhere(
        (s) => s.name == json['status'],
      ),
      items: (json['items'] as List)
          .map((item) => SupplierOrderItem.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] ?? 0).toInt(),
      notes: json['notes'],
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
    );
  }

  @override
  String toString() {
    return 'SupplierOrder(id: $id, supplierName: $supplierName, totalAmount: $totalAmount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupplierOrder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class SupplierOrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final int unitPrice;
  final int totalPrice;

  SupplierOrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  SupplierOrderItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    int? unitPrice,
    int? totalPrice,
  }) {
    return SupplierOrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  factory SupplierOrderItem.fromJson(Map<String, dynamic> json) {
    return SupplierOrderItem(
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] ?? 0).toInt(),
      totalPrice: (json['totalPrice'] ?? 0).toInt(),
    );
  }

  @override
  String toString() {
    return 'SupplierOrderItem(productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupplierOrderItem && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;
}
