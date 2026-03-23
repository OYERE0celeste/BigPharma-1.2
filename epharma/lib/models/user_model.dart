class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String companyId;
  final bool isActive;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.companyId,
    this.isActive = true,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'pharmacien',
      companyId: json['companyId'] is Map 
          ? (json['companyId']['_id'] ?? json['companyId']['id'] ?? '')
          : (json['companyId'] ?? ''),
      isActive: json['isActive'] ?? true,
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt']) 
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
      'isActive': isActive,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }
}
