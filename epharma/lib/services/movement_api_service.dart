import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movement_model.dart';
import 'auth_service.dart';
import 'api_constants.dart';

class MovementApiService {
  static String get baseUrl => '${ApiConstants.baseUrl}/mouvements';
  static final AuthService _authService = AuthService();

  static dynamic _safeDecode(String body) {
    try {
      return json.decode(body);
    } catch (_) {
      return {'message': body};
    }
  }

  static Future<List<StockMovement>> getMovements({
    String? productId,
    int page = 1,
    int limit = 20,
  }) async {
    final headers = await _authService.getHeaders();
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (productId != null && productId.isNotEmpty) {
      query['produitId'] = productId;
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: query);
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final decoded = _safeDecode(response.body);
      final data = decoded['data'];
      if (data is List) {
        return data
            .map((item) => StockMovement.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    }
    throw Exception(
      'Erreur lors du chargement de l\'historique des mouvements',
    );
  }
}
