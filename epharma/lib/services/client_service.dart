import '../models/client_model.dart';

class Purchase {
  final String invoiceNumber;
  final DateTime date;
  final List<String> products;
  final double totalAmount;
  final String paymentMethod;

  Purchase({
    required this.invoiceNumber,
    required this.date,
    required this.products,
    required this.totalAmount,
    required this.paymentMethod,
  });
}

class Prescription {
  final String id;
  final String medicationName;
  final DateTime validationDate;
  final String status;
  final int quantity;

  Prescription({
    required this.id,
    required this.medicationName,
    required this.validationDate,
    required this.status,
    required this.quantity,
  });
}

class ClientService {
  static final List<Client> _clients = [];
  static int _nextId = 1;

  // CRUD Operations
  static List<Client> getAllClients() {
    return List.from(_clients);
  }

  static Client? getClientById(String id) {
    try {
      return _clients.firstWhere((client) => client.id == id);
    } catch (e) {
      return null;
    }
  }

  static Client addClient({
    required String fullName,
    required String phone,
    //required String email,
    required String address,
    required DateTime dateOfBirth,
    required Gender gender,
    List<String>? preferredPaymentMethods,
  }) {
    final client = Client(
      id: 'client_$_nextId',
      fullName: fullName,
      phone: phone,
      //email: email,
      address: address,
      dateOfBirth: dateOfBirth,
      gender: gender,
      hasMedicalHistory: false,
      //registrationDate: DateTime.now(),
      //lastVisitDate: DateTime.now(),
      //preferredPaymentMethods: preferredPaymentMethods ?? [],
    );

    _clients.add(client);
    _nextId++;
    return client;
  }

  static Client updateClient(
    String id, {
    String? fullName,
    String? phone,
    //String? email,
    String? address,
    DateTime? dateOfBirth,
    Gender? gender,
    //ClientStatus? status,
    bool? hasMedicalProfile,
    String? description,
    List<String>? preferredPaymentMethods,
  }) {
    final index = _clients.indexWhere((client) => client.id == id);
    if (index == -1) {
      throw ArgumentError('Client non trouvé avec l\'ID: $id');
    }

    final existingClient = _clients[index];
    final updatedClient = existingClient.copyWith(
      fullName: fullName,
      phone: phone,
      //email: email,
      address: address,
      dateOfBirth: dateOfBirth,
      gender: gender,
      //status: status,
      //hasMedicalProfile: hasMedicalProfile,
      //description: description,
      // preferredPaymentMethods: preferredPaymentMethods,
    );

    _clients[index] = updatedClient;
    return updatedClient;
  }

  static bool deleteClient(String id) {
    final index = _clients.indexWhere((client) => client.id == id);
    if (index == -1) return false;

    _clients.removeAt(index);
    return true;
  }

  // Search and Filter Operations
  static List<Client> searchClients(String query) {
    if (query.isEmpty) return getAllClients();

    final lowerQuery = query.toLowerCase();
    return _clients
        .where(
          (client) =>
              client.fullName.toLowerCase().contains(lowerQuery) ||
              // client.email.toLowerCase().contains(lowerQuery) ||
              client.phone.contains(query) ||
              client.address.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  static List<Client> filterClients({
    // ClientStatus? status,
    Gender? gender,
    bool? hasMedicalProfile,
    DateTime? startDate,
    DateTime? endDate,
    int? minSpent,
    int? maxSpent,
    int? minPurchases,
  }) {
    return _clients.where((client) {
      //if (status != null && client.status != status) return false;
      if (gender != null && client.gender != gender) return false;
      /*if (hasMedicalProfile != null &&
          client.hasMedicalProfile != hasMedicalProfile) {
        return false;
      }*/
      //  if (startDate != null && client.registrationDate.isBefore(startDate)) {
      //  return false;
      //}
      //if (endDate != null && client.registrationDate.isAfter(endDate)) {
      // return false;
      //}
      /*if (minSpent != null && client.totalSpent < minSpent) return false;
      if (maxSpent != null && client.totalSpent > maxSpent) return false;
      if (minPurchases != null && client.totalPurchases < minPurchases) {
        return false;
      }*/
      return true;
    }).toList();
  }

  // Client Categories

  /*static List<Client> getActiveClients() {
    return _clients
        .where((client) => client.status == ClientStatus.active)
        .toList();
  }*/

  /* static List<Client> getInactiveClients() {
    return _clients.where((client) => client.isInactive).toList();
  }*/

  // static List<Client> getClientsWithMedicalProfile() {
  //return _clients.where((client) => client.hasMedicalProfile).toList();
  //}

  static List<Client> getFrequentClients({int minPurchases = 10}) {
    return _clients
        // .where((client) => client.totalPurchases >= minPurchases)
        .toList();
  }

  // Business Operations
  static Client addPurchase(String clientId, int amount) {
    final client = getClientById(clientId);
    if (client == null) {
      throw ArgumentError('Client non trouvé avec l\'ID: $clientId');
    }

    // final updatedClient = client.addPurchase(amount);
    final index = _clients.indexWhere((c) => c.id == clientId);
    //_clients[index] = updatedClient;

    //return updatedClient;
    return client;
  }

  static Client updateLastVisit(String clientId) {
    final client = getClientById(clientId);
    if (client == null) {
      throw ArgumentError('Client non trouvé avec l\'ID: $clientId');
    }

    //final updatedClient = client.copyWith(lastVisitDate: DateTime.now());
    final index = _clients.indexWhere((c) => c.id == clientId);
    //_clients[index] = updatedClient;

    //return updatedClient;
    return client;
  }

  // Validation Operations
  static bool isEmailUnique(String email, {String? excludeClientId}) {
    return !_clients.any(
      (client) =>
          //client.email.toLowerCase() == email.toLowerCase() &&
          (excludeClientId == null || client.id != excludeClientId),
    );
  }

  static bool isPhoneUnique(String phone, {String? excludeClientId}) {
    return !_clients.any(
      (client) =>
          client.phone == phone &&
          (excludeClientId == null || client.id != excludeClientId),
    );
  }

  // Statistics and Analytics
  /*static ClientMetrics getClientMetrics() {
    return ClientMetrics.fromClients(_clients);
  }*/

  static List<Map<String, dynamic>> getTopClientsBySpending({int limit = 10}) {
    final sortedClients = List<Client>.from(_clients);
    //..sort((a, b) => b.totalSpent.compareTo(a.totalSpent));

    return sortedClients
        .take(limit)
        .map(
          (client) => {
            'id': client.id,
            'fullName': client.fullName,
            //'totalSpent': client.totalSpent,
            //'totalPurchases': client.totalPurchases,
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> getTopClientsByPurchases({int limit = 10}) {
    final sortedClients = List<Client>.from(_clients);
    // ..sort((a, b) => b.totalPurchases.compareTo(a.totalPurchases));

    return sortedClients
        .take(limit)
        .map(
          (client) => {
            'id': client.id,
            'fullName': client.fullName,
            //'totalPurchases': client.totalPurchases,
            //'totalSpent': client.totalSpent,
            //'averageBasketValue': client.averageBasketValue,
          },
        )
        .toList();
  }

  static List<Purchase> getClientPurchases(String clientId) {
    // Placeholder implementation
    return [];
  }

  static List<Prescription> getClientPrescriptions(String clientId) {
    // Placeholder implementation
    return [];
  }

  static Map<String, int> getClientsByGender() {
    final Map<String, int> counts = {};
    for (final client in _clients) {
      final gender = client.genderDisplay;
      counts[gender] = (counts[gender] ?? 0) + 1;
    }
    return counts;
  }

  static Map<String, int> getClientsByStatus() {
    final Map<String, int> counts = {};
    for (final client in _clients) {
      // final status = client.statusDisplay;
      //counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  static int getAverageClientSpending() {
    if (_clients.isEmpty) return 0;
    //final totalSpent = _clients.fold<int>(
    //  0,
    //  (sum, client) => sum + client.totalSpent,
    //);
    //return totalSpent ~/ _clients.length;
    return 0;
  }

  static int getAverageClientAge() {
    if (_clients.isEmpty) return 0;
    final totalAge = _clients.fold<int>(0, (sum, client) => sum + client.age);
    return totalAge ~/ _clients.length;
  }

  // Data Import/Export
  static List<Map<String, dynamic>> exportClients() {
    return _clients.map((client) => client.toJson()).toList();
  }

  static void importClients(List<Map<String, dynamic>> clientData) {
    for (final data in clientData) {
      try {
        final client = Client.fromJson(data);
        _clients.add(client);
        _nextId = int.parse(client.id.split('_').last) + 1;
      } catch (e) {
        // Ignorer les données invalides
        continue;
      }
    }
  }

  // Utility Methods
  static void clearAllClients() {
    _clients.clear();
    _nextId = 1;
  }

  static int getClientCount() {
    return _clients.length;
  }

  static List<String> getAllClientNames() {
    return _clients.map((client) => client.fullName).toList();
  }

  /*static List<String> getAllClientEmails() {
    return _clients.map((client) => client.email).toList();
  }*/

  static List<String> getAllClientPhones() {
    return _clients.map((client) => client.phone).toList();
  }

  // Advanced Search
  static List<Client> advancedSearch({
    String? nameQuery,
    String? emailQuery,
    String? phoneQuery,
    //ClientStatus? status,
    Gender? gender,
    bool? hasMedicalProfile,
    DateTime? birthDateFrom,
    DateTime? birthDateTo,
    DateTime? registrationDateFrom,
    DateTime? registrationDateTo,
    int? minSpent,
    int? maxSpent,
    int? minPurchases,
    int? maxPurchases,
  }) {
    return _clients.where((client) {
      if (nameQuery != null &&
          nameQuery.isNotEmpty &&
          !client.fullName.toLowerCase().contains(nameQuery.toLowerCase())) {
        return false;
      }
      /*if (emailQuery != null &&
          emailQuery.isNotEmpty &&
          !client.email.toLowerCase().contains(emailQuery.toLowerCase())) {
        return false;
      }*/
      if (phoneQuery != null &&
          phoneQuery.isNotEmpty &&
          !client.phone.contains(phoneQuery)) {
        return false;
      }
      //if (status != null && client.status != status) return false;
      if (gender != null && client.gender != gender) return false;
      /*if (hasMedicalProfile != null &&
          client.hasMedicalProfile != hasMedicalProfile) {
        return false;
      }*/
      if (birthDateFrom != null && client.dateOfBirth.isBefore(birthDateFrom)) {
        return false;
      }
      if (birthDateTo != null && client.dateOfBirth.isAfter(birthDateTo)) {
        return false;
      }
      /*   if (registrationDateFrom != null &&
          client.registrationDate.isBefore(registrationDateFrom)) {
        return false;
      }
      if (registrationDateTo != null &&
          client.registrationDate.isAfter(registrationDateTo)) {
        return false;
      }
      if (minSpent != null && client.totalSpent < minSpent) return false;
      if (maxSpent != null && client.totalSpent > maxSpent) return false;
      if (minPurchases != null && client.totalPurchases < minPurchases) {
        return false;
      }
      if (maxPurchases != null && client.totalPurchases > maxPurchases) {
        return false;
      }*/
      return true;
    }).toList();
  }
}
