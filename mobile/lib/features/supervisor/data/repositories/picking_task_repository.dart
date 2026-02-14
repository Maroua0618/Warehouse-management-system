import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/picking_route_models.dart';

/// Picking Task Repository - Updated to match new backend API
/// Backend uses: operation_tasks (operation_type='PICKING'), route_plans, ai_recommendations
class PickingTaskRepository {
  final String? authToken;
  final String? currentUserId;

  PickingTaskRepository({this.authToken, this.currentUserId});

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  /// Fetch all picking tasks
  Future<List<PickingTask>> fetchPickingTasks({
    String? status,
    String? assignedTo,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (assignedTo != null) queryParams['assigned_to'] = assignedTo;

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.pickingTasks}',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PickingTask.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load picking tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching picking tasks: $e');
    }
  }

  /// Fetch a single picking task by ID
  Future<PickingTask> fetchPickingTaskById(String taskId) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.pickingTasks}/$taskId',
      );
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return PickingTask.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load picking task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching picking task: $e');
    }
  }

  /// Create a new picking task
  Future<PickingTask> createPickingTask({
    required String orderId,
    String? priority,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.pickingTasks}',
      ).replace(queryParameters: {'user_id': currentUserId ?? ''});

      final body = json.encode({
        'order_id': orderId,
        if (priority != null) 'priority': priority,
      });

      final response = await http.post(uri, headers: _headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PickingTask.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to create picking task: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error creating picking task: $e');
    }
  }

  /// Update picking task (status, assignment, etc.)
  Future<PickingTask> updatePickingTask({
    required String taskId,
    String? status,
    String? assignedToUserId,
    String? chariotId,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.pickingTasks}/$taskId',
      ).replace(queryParameters: {'user_id': currentUserId ?? ''});

      final body = json.encode({
        if (status != null) 'status': status,
        if (assignedToUserId != null) 'assigned_to_user_id': assignedToUserId,
        if (chariotId != null) 'chariot_id': chariotId,
      });

      final response = await http.put(uri, headers: _headers, body: body);

      if (response.statusCode == 200) {
        return PickingTask.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to update picking task: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error updating picking task: $e');
    }
  }

  /// Get AI-optimized picking route
  Future<PickingRouteOptimization> optimizePickingRoute({
    required String pickingTaskId,
    required List<PickingItemRequest> items,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.pickingTasks}/ai/optimize-route',
      ).replace(queryParameters: {'user_id': currentUserId ?? ''});

      final body = json.encode({
        'picking_task_id': pickingTaskId,
        'items': items.map((item) => item.toJson()).toList(),
      });

      final response = await http.post(uri, headers: _headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PickingRouteOptimization.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to optimize picking route: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error optimizing picking route: $e');
    }
  }

  /// Assign picking task to worker
  Future<PickingTask> assignPickingTask({
    required String taskId,
    required String workerId,
    String? chariotId,
  }) async {
    return updatePickingTask(
      taskId: taskId,
      assignedToUserId: workerId,
      chariotId: chariotId,
    );
  }

  /// Update task status
  Future<PickingTask> updatePickingTaskStatus({
    required String taskId,
    required String status,
  }) async {
    return updatePickingTask(
      taskId: taskId,
      status: status,
    );
  }

  /// Complete picking task
  Future<PickingTask> completePickingTask({
    required String taskId,
  }) async {
    return updatePickingTask(
      taskId: taskId,
      status: 'COMPLETED',
    );
  }

  /// Delete picking task
  Future<void> deletePickingTask({required String taskId}) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.pickingTasks}/$taskId',
      ).replace(queryParameters: {'user_id': currentUserId ?? ''});

      final response = await http.delete(uri, headers: _headers);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete picking task: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting picking task: $e');
    }
  }
}
