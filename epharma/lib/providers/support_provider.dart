import 'package:flutter/material.dart';
import '../models/support_model.dart';
import '../services/support_service.dart';

class SupportProvider with ChangeNotifier {
  final SupportService _supportService = SupportService();
  
  List<SupportQuestion> _questions = [];
  bool _isLoading = false;
  String? _error;

  List<SupportQuestion> get questions => _questions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadQuestions({String? status, String? clientId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _questions = await _supportService.getQuestions(status: status, clientId: clientId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createQuestion(String subject, String content) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newQuestion = await _supportService.createQuestion(subject, content);
      _questions.insert(0, newQuestion);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String questionId, String content) async {
    try {
      final updatedQuestion = await _supportService.addMessage(questionId, content);
      
      // Update the question in the list
      int index = _questions.indexWhere((q) => q.id == questionId);
      if (index != -1) {
        _questions[index] = updatedQuestion;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> closeQuestion(String questionId) async {
    try {
      final updatedQuestion = await _supportService.closeQuestion(questionId);
      
      // Update the question in the list
      int index = _questions.indexWhere((q) => q.id == questionId);
      if (index != -1) {
        _questions[index] = updatedQuestion;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
