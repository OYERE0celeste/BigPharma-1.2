import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity_model.dart';
import 'auth_service.dart';
import 'api_constants.dart';

class ActivityApiService {
  static String get baseUrl => '${ApiConstants.baseUrl}/activityLogs';
  static final AuthService _authService = AuthService();

  static Future<List<ActivityModel>> getAllActivities() async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.get(Uri.parse(baseUrl), headers: headers);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'] ?? [];
        if (data is List) {
          return data.map((item) => ActivityModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<ActivityModel>> getActivitiesByRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.get(
        Uri.parse(
          '$baseUrl?start=${start.toIso8601String()}&end=${end.toIso8601String()}',
        ),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'] ?? [];
        if (data is List) {
          return data.map((item) => ActivityModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<ActivityModel?> createActivity(ActivityModel activity) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(activity.toJson()),
      );
      if (response.statusCode == 201) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        if (data != null) {
          return ActivityModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
