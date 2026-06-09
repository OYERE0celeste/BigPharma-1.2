import 'package:flutter_test/flutter_test.dart';
import 'package:client_app/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('Should parse User from JSON correctly', () {
      // Arrange
      final Map<String, dynamic> json = {
        '_id': '123',
        'fullName': 'John Doe',
        'email': 'john@example.com',
        'role': 'admin',
        'companyId': 'comp_456'
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.id, '123');
      expect(user.fullName, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.role, 'admin');
      expect(user.companyId, 'comp_456');
    });

    test('Should serialize User to JSON correctly', () {
      // Arrange
      final user = User(
        id: '123',
        fullName: 'John Doe',
        email: 'john@example.com',
        role: 'admin',
        companyId: 'comp_456',
        phone: '+33123456789',
        address: '123 Main St',
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], '123');
      expect(json['fullName'], 'John Doe');
      expect(json['email'], 'john@example.com');
      expect(json['role'], 'admin');
      expect(json['phone'], '+33123456789');
    });
  });
}
