enum Gender { male, female }

enum LoyaltyStatus { standard, regular, vip }

class Client {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String address;
  final DateTime dateOfBirth;
  final DateTime registrationDate;
  final Gender gender;
  final bool hasMedicalHistory;
  final int totalPurchases;
  final double totalSpent;
  final DateTime lastVisitDate;
  final LoyaltyStatus loyaltyStatus;
  final bool hasMedicalProfile;
  final String description;

  Client({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email = '',
    this.address = '',
    required this.dateOfBirth,
    DateTime? registrationDate,
    required this.gender,
    this.hasMedicalHistory = false,
    this.totalPurchases = 0,
    this.totalSpent = 0,
    DateTime? lastVisitDate,
    this.loyaltyStatus = LoyaltyStatus.standard,
    this.hasMedicalProfile = false,
    this.description = '',
  }) : registrationDate = registrationDate ?? DateTime.now(),
      lastVisitDate = lastVisitDate ?? DateTime.now();

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  double get averageBasketValue {
    return totalPurchases > 0 ? totalSpent / totalPurchases : 0;
  }

  String get genderDisplay {
    switch (gender) {
      case Gender.male:
        return 'Homme';
      case Gender.female:
        return 'Femme';
    }
  }

  String get loyaltyLabel {
    switch (loyaltyStatus) {
      case LoyaltyStatus.standard:
        return 'Standard';
      case LoyaltyStatus.regular:
        return 'Regular';
      case LoyaltyStatus.vip:
        return 'VIP';
    }
  }

  // Méthodes utilitaires
  Client copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    String? address,
    DateTime? dateOfBirth,
    Gender? gender,
    bool? hasMedicalHistory,
    int? totalPurchases,
    double? totalSpent,
    DateTime? lastVisitDate,
    LoyaltyStatus? loyaltyStatus,
    bool? hasMedicalProfile,
    String? description,
    DateTime? registrationDate,
  }) {
    return Client(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      registrationDate: registrationDate ?? this.registrationDate,
      gender: gender ?? this.gender,
      hasMedicalHistory: hasMedicalHistory ?? this.hasMedicalHistory,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalSpent: totalSpent ?? this.totalSpent,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      loyaltyStatus: loyaltyStatus ?? this.loyaltyStatus,
      hasMedicalProfile: hasMedicalProfile ?? this.hasMedicalProfile,
      description: description ?? this.description,
    );
  }

  bool get isValidPhone {
    return RegExp(r'^[0-9]{8,15}$').hasMatch(phone);
  }

  // Conversion pour JSON (si nécessaire pour la persistance)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender.name,
      'hasMedicalHistory': hasMedicalHistory,
      'registrationDate': registrationDate.toIso8601String(),
      'totalPurchases': totalPurchases,
      'totalSpent': totalSpent,
      'lastVisitDate': lastVisitDate.toIso8601String(),
      'loyaltyStatus': loyaltyStatus.name,
      'hasMedicalProfile': hasMedicalProfile,
      'description': description,
    };
  }

  // Création depuis JSON
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id:
          json['_id']?.toString() ??
          json['id']?.toString() ??
          (json['_doc']?['_id']?.toString() ?? ''),
      fullName:
          json['fullName']?.toString() ??
          json['_doc']?['fullName']?.toString() ??
          '',
      phone:
          json['phone']?.toString() ?? json['_doc']?['phone']?.toString() ?? '',
      email:
          json['email']?.toString() ?? json['_doc']?['email']?.toString() ?? '',
      address:
          json['address']?.toString() ??
          json['_doc']?['address']?.toString() ??
          '',
      dateOfBirth: DateTime.parse(
        (json['dateOfBirth'] ?? json['_doc']?['dateOfBirth']).toString(),
      ),
      registrationDate: json['registrationDate'] != null
          ? DateTime.parse(json['registrationDate'].toString())
          : DateTime.now(),
      gender: Gender.values.firstWhere(
        (g) => g.name == json['gender']?.toString(),
        orElse: () => Gender.male,
      ),
      hasMedicalHistory:
          json['hasMedicalHistory'] == true ||
          json['hasMedicalHistory']?.toString() == 'true',
      totalPurchases:
          int.tryParse(json['totalPurchases']?.toString() ?? '0') ?? 0,
      totalSpent: double.tryParse(json['totalSpent']?.toString() ?? '0') ?? 0,
      lastVisitDate: json['lastVisitDate'] != null
          ? DateTime.parse(json['lastVisitDate'].toString())
          : json['lastVisit'] != null
          ? DateTime.parse(json['lastVisit'].toString())
          : DateTime.now(),
      loyaltyStatus: json['loyaltyStatus'] != null
          ? LoyaltyStatus.values.firstWhere(
              (status) => status.name == json['loyaltyStatus'].toString(),
              orElse: () => LoyaltyStatus.standard,
            )
          : LoyaltyStatus.standard,
      hasMedicalProfile:
          json['hasMedicalProfile'] == true ||
          json['hasMedicalProfile']?.toString() == 'true',
      description: json['description']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'Client(id: $id, fullName: $fullName, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Client && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
