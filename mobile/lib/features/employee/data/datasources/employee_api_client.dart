import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee_profile_model.dart';
import '../models/employee_stats_model.dart';

class EmployeeApiClient {
  // Change this to your backend URL
  // Using ADB reverse port forwarding: adb reverse tcp:8000 tcp:8000
  // This works for USB-connected devices
  static const String baseUrl = 'http://10.36.245.125:8000';

  final http.Client httpClient;
  String? _accessToken;

  EmployeeApiClient({http.Client? httpClient})
    : httpClient = httpClient ?? http.Client();

  void setAccessToken(String token) {
    _accessToken = token;
  }

  String? get accessToken => _accessToken;

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  /// Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _accessToken = data['access_token'] as String;
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  /// Get employee profile
  Future<EmployeeProfileModel> getProfile() async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/employee/profile'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return EmployeeProfileModel.fromJson(data);
    } else {
      throw Exception('Failed to load profile: ${response.body}');
    }
  }

  /// Get employee statistics
  Future<EmployeeStatsModel> getStats() async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/employee/stats'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return EmployeeStatsModel.fromJson(data);
    } else {
      throw Exception('Failed to load stats: ${response.body}');
    }
  }

  /// Get all tasks
  Future<List<dynamic>> getTasks({
    String? taskType, // 'INGOING' or 'OUTGOING'
    String? status, // 'ASSIGNED', 'IN_PROGRESS', 'PENDING', 'DONE', 'CANCELLED'
  }) async {
    final queryParams = <String, String>{};
    if (taskType != null) queryParams['task_type'] = taskType;
    if (status != null) queryParams['status'] = status;

    final uri = Uri.parse(
      '$baseUrl/tasks',
    ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await httpClient.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load tasks: ${response.body}');
    }
  }

  /// Get task details
  Future<Map<String, dynamic>> getTaskDetail(String taskId) async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/tasks/$taskId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load task detail: ${response.body}');
    }
  }

  /// Update task status
  Future<Map<String, dynamic>> updateTaskStatus({
    required String taskId,
    required String status,
    String? notes,
  }) async {
    final response = await httpClient.put(
      Uri.parse('$baseUrl/tasks/$taskId/status'),
      headers: _headers,
      body: jsonEncode({'status': status, if (notes != null) 'notes': notes}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to update task status: ${response.body}');
    }
  }

  /// Validate task
  Future<Map<String, dynamic>> validateTask(String taskId) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/tasks/$taskId/validate'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to validate task: ${response.body}');
    }
  }

  /// Report issue
  Future<Map<String, dynamic>> reportIssue({
    required String taskId,
    required String category,
    required String description,
    String severity = 'MEDIUM',
  }) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/tasks/$taskId/report-issue'),
      headers: _headers,
      body: jsonEncode({
        'category': category,
        'description': description,
        'severity': severity,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to report issue: ${response.body}');
    }
  }

  void dispose() {
    httpClient.close();
  }
}
