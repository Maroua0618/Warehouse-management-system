import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/supervisor_models.dart';

/// Supervisor Repository - Updated to match new backend API
/// Backend uses: users, orders, operation_tasks, override_decisions, ai_recommendations, audit_logs
class SupervisorRepository {
  final String? authToken;
  final String? currentUserId;

  SupervisorRepository({this.authToken, this.currentUserId});

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  /// Get dashboard statistics
  Future<DashboardStats> getDashboardStats() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/supervisor/dashboard');

      final response = await http
          .get(uri, headers: _headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Dashboard request timed out');
            },
          );

      if (response.statusCode == 200) {
        return DashboardStats.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          'Failed to load dashboard stats: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching dashboard stats: $e');
    }
  }

  /// Get recent activity from audit logs
  Future<List<RecentActivity>> getRecentActivity({int limit = 10}) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/supervisor/recent-activity',
      ).replace(queryParameters: {'limit': limit.toString()});

      final response = await http
          .get(uri, headers: _headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Recent activity request timed out');
            },
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RecentActivity.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load recent activity: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching recent activity: $e');
    }
  }

  /// Get operational issues (from AI alerts and override decisions)
  Future<List<OperationalIssue>> getOperationalIssues({
    String? status,
    String? priority,
    String? issueType,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (priority != null) queryParams['priority'] = priority;
      if (issueType != null) queryParams['issue_type'] = issueType;
      queryParams['skip'] = skip.toString();
      queryParams['limit'] = limit.toString();

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/supervisor/operational-issues',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => OperationalIssue.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load operational issues: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching operational issues: $e');
    }
  }

  /// Create a manual operational issue
  Future<OperationalIssue> createOperationalIssue({
    required String issueType,
    required String priority,
    required String employeeName,
    required String title,
    required String description,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/supervisor/operational-issues',
      );

      final body = json.encode({
        'issue_type': issueType,
        'priority': priority,
        'employee_name': employeeName,
        'title': title,
        'description': description,
      });

      final response = await http.post(uri, headers: _headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OperationalIssue.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          'Failed to create operational issue: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error creating operational issue: $e');
    }
  }

  /// Review and resolve an operational issue
  Future<void> reviewIssue(String issueId) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/supervisor/operational-issues/$issueId/review',
      ).replace(queryParameters: {'user_id': currentUserId ?? ''});

      final response = await http.put(uri, headers: _headers);

      if (response.statusCode != 200) {
        throw Exception('Failed to review issue: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error reviewing issue: $e');
    }
  }

  /// Dismiss an operational issue
  Future<void> dismissIssue(String issueId) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/supervisor/operational-issues/$issueId/dismiss',
      ).replace(queryParameters: {'user_id': currentUserId ?? ''});

      final response = await http.put(uri, headers: _headers);

      if (response.statusCode != 200) {
        throw Exception('Failed to dismiss issue: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error dismissing issue: $e');
    }
  }
}
