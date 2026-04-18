class User {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String phone;
  final String address;
  final String companyId;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone = '',
    this.address = '',
    required this.companyId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'client',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      companyId: json['companyId'] is Map 
        ? (json['companyId']['id'] ?? json['companyId']['_id'] ?? '') 
        : (json['companyId']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
      'companyId': companyId,
    };
  }
}
