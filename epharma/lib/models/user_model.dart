class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String companyId;
  final String phone;
  final String address;
  final bool isActive;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.companyId,
    this.phone = '',
    this.address = '',
    this.isActive = true,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'pharmacien').toString(),
      companyId: json['companyId'] is Map 
          ? (json['companyId']['_id'] ?? json['companyId']['id'] ?? '').toString()
          : (json['companyId'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      isActive: json['isActive'] == true,
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.tryParse(json['lastLoginAt'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'companyId': companyId,
      'phone': phone,
      'address': address,
      'isActive': isActive,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }
}
