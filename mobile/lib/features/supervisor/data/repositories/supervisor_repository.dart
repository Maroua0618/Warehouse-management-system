import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/supervisor_models.dart';

class SupervisorRepository {
  Map<String, String> _getHeaders() {
    return {'Content-Type': 'application/json'};
  }

  Future<DashboardStats> getDashboardStats() async {
    final headers = _getHeaders();
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.dashboard}'),
          headers: headers,
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Dashboard request timed out');
          },
        );

    if (response.statusCode == 200) {
      return DashboardStats.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  }

  Future<List<RecentActivity>> getRecentActivity({int limit = 10}) async {
    final headers = _getHeaders();
    final response = await http
        .get(
          Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.recentActivity}?limit=$limit',
          ),
          headers: headers,
        )
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
      throw Exception('Failed to load recent activity');
    }
  }

  Future<List<OperationalIssue>> getOperationalIssues({
    String? status,
    String? priority,
    String? issueType,
  }) async {
    final headers = _getHeaders();

    var url = '${ApiConfig.baseUrl}${ApiConfig.operationalIssues}?';
    if (status != null) url += 'status=$status&';
    if (priority != null) url += 'priority=$priority&';
    if (issueType != null) url += 'issue_type=$issueType&';

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => OperationalIssue.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load operational issues');
    }
  }

  Future<void> reviewIssue(String issueId) async {
    final headers = _getHeaders();
    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.operationalIssues}/$issueId/review',
      ),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to review issue');
    }
  }

  Future<void> dismissIssue(String issueId) async {
    final headers = _getHeaders();
    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.operationalIssues}/$issueId/dismiss',
      ),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to dismiss issue');
    }
  }
}
