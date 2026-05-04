import 'dart:convert';
import '../models/support_model.dart';
import 'api_constants.dart';
import 'api_service.dart';

class SupportService {
  final ApiService _apiService = ApiService();

  Future<List<SupportQuestion>> getQuestions({String? status, String? clientId}) async {
    String url = ApiConstants.questionsClients;
    List<String> params = [];
    if (status != null) params.add('status=$status');
    if (clientId != null) params.add('clientId=$clientId');
    
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }

    final response = await _apiService.get(url);
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['success'] == true) {
        final List<dynamic> data = decoded['data'];
        return data.map((q) => SupportQuestion.fromJson(q)).toList();
      }
    }
    throw Exception('Erreur lors de la récupération des questions');
  }

  Future<SupportQuestion> createQuestion(String subject, String content) async {
    final response = await _apiService.post(
      ApiConstants.questionsClients,
      {
        'subject': subject,
        'content': content,
      },
    );
    final decoded = json.decode(response.body);
    if (response.statusCode == 201) {
      if (decoded['success'] == true) {
        return SupportQuestion.fromJson(decoded['data']);
      }
    }
    throw Exception('FRONT_DEBUG | Status: ${response.statusCode} | Msg: ${decoded['message'] ?? decoded['error']?['message'] ?? 'N/A'}');
  }

  Future<SupportQuestion> getQuestionById(String id) async {
    final response = await _apiService.get('${ApiConstants.questionsClients}/$id');
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['success'] == true) {
        return SupportQuestion.fromJson(decoded['data']);
      }
    }
    throw Exception('Erreur lors de la récupération de la question');
  }

  Future<SupportQuestion> addMessage(String questionId, String content) async {
    final response = await _apiService.post(
      '${ApiConstants.questionsClients}/$questionId/messages',
      {'content': content},
    );
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['success'] == true) {
        return SupportQuestion.fromJson(decoded['data']);
      }
    }
    throw Exception('Erreur lors de l\'envoi du message');
  }

  Future<SupportQuestion> closeQuestion(String id) async {
    final response = await _apiService.patch(
      '${ApiConstants.questionsClients}/$id/close',
      {},
    );
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['success'] == true) {
        return SupportQuestion.fromJson(decoded['data']);
      }
    }
    throw Exception('Erreur lors de la fermeture de la discussion');
  }
}
