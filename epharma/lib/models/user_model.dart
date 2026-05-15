import '../security/rbac.dart';

class UserModel {
  final String id;
  final String fullName;
  final String? username;
  final String email;
  final String role;
  final String companyId;
  final String phone;
  final String address;
  final bool isActive;
  final Map<String, bool> permissions;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.fullName,
    this.username,
    required this.email,
    required this.role,
    required this.companyId,
    this.phone = '',
    this.address = '',
    this.isActive = true,
    this.permissions = const {},
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    Map<String, bool> perms = {};
    if (json['permissions'] != null && json['permissions'] is Map) {
      (json['permissions'] as Map).forEach((key, value) {
        perms[key.toString()] = value == true;
      });
    }

    final role = (json['role'] ?? 'pharmacien').toString();
    final normalizedPermissions = normalizePermissions(role, perms);

    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      username: json['username'] as String?,
      email: (json['email'] ?? '').toString(),
      role: role,
      companyId: json['companyId'] is Map
          ? (json['companyId']['_id'] ?? json['companyId']['id'] ?? '')
                .toString()
          : (json['companyId'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      isActive: json['isActive'] == true,
      permissions: normalizedPermissions,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'].toString())
          : null,
    );
  }

  bool can(String permission) {
    return permissions[permission] == true;
  }

  bool canAny(List<String> requiredPermissions) {
    return requiredPermissions.any(can);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      if (username != null) 'username': username,
      'email': email,
      'role': role,
      'companyId': companyId,
      'phone': phone,
      'address': address,
      'isActive': isActive,
      'permissions': permissions,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }
}
