import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/operational_monitor_models.dart';

/// Operational Monitor Repository - Updated to match new backend API
/// Backend uses: users, operation_tasks, ai_recommendations (type='ALERT_*'), audit_logs
class OperationalMonitorRepository {
  final String? authToken;
  final String? currentUserId;

  OperationalMonitorRepository({this.authToken, this.currentUserId});

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  /// Fetch employee tracking data
  Future<List<Employee>> fetchEmployeeTracking({
    bool activeOnly = true,
  }) async {
    try {
      final queryParams = <String, String>{};
      queryParams['active_only'] = activeOnly.toString();

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/operational-monitor/employees',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Employee.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load employee tracking: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching employee tracking: $e');
    }
  }

  /// Fetch a single employee tracking by ID
  Future<Employee> fetchEmployeeTrackingById(String employeeId) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/operational-monitor/employees/$employeeId',
      );
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return Employee.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to load employee tracking: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching employee tracking: $e');
    }
  }

  /// Fetch operational alerts
  Future<List<OperationalAlert>> fetchOperationalAlerts({
    String? severity,
    bool activeOnly = true,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (severity != null) queryParams['severity'] = severity;
      queryParams['active_only'] = activeOnly.toString();

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/operational-monitor/alerts',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => OperationalAlert.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load operational alerts: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching operational alerts: $e');
    }
  }

  /// Resolve an operational alert
  Future<Map<String, dynamic>> resolveOperationalAlert({
    required String alertId,
    String? resolutionNotes,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/operational-monitor/alerts/$alertId/resolve',
      ).replace(queryParameters: {
        'user_id': currentUserId ?? '',
        if (resolutionNotes != null) 'resolution_notes': resolutionNotes,
      });

      final response = await http.post(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to resolve operational alert: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error resolving operational alert: $e');
    }
  }

  /// Fetch operational performance summary
  Future<OperationalStats> fetchPerformanceSummary() async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/operational-monitor/performance-summary',
      );

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return OperationalStats.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to load performance summary: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching performance summary: $e');
    }
  }
}
