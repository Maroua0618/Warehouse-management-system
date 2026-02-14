import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/storage_move_models.dart';

/// Storage Move Repository - Updated to match new backend API
/// Backend uses: operation_tasks (operation_type='STORAGE'), ai_recommendations, override_decisions
class StorageMoveRepository {
  final String? authToken;
  final String? currentUserId;

  StorageMoveRepository({this.authToken, this.currentUserId});

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  /// Fetch all storage moves (tasks)
  Future<List<StorageMove>> fetchStorageMoves({TaskStatus? status}) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status.toJson();

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.storageMoves}',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => StorageMove.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load storage moves: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching storage moves: $e');
    }
  }

  /// Create a new storage move task
  Future<StorageMove> createStorageMove({
    required String orderId,
    required String skuId,
    required String fromLocationId,
    required String toLocationId,
    required int quantity,
    PriorityLevel priority = PriorityLevel.MEDIUM,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.storageMoves}',
      ).replace(queryParameters: {'user_id': currentUserId ?? ''});

      final body = json.encode({
        'order_id': orderId,
        'sku_id': skuId,
        'from_location_id': fromLocationId,
        'to_location_id': toLocationId,
        'quantity': quantity,
        'priority': priority.toJson(),
      });

      final response = await http.post(uri, headers: _headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return StorageMove.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to create storage move: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error creating storage move: $e');
    }
  }

  /// Update storage move (status, assignment, etc.)
  Future<StorageMove> updateStorageMove({
    required String taskId,
    TaskStatus? status,
    String? assignedToUserId,
    String? chariotId,
    String? toLocationId,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.storageMoves}/$taskId',
      ).replace(queryParameters: {'user_id': currentUserId ?? ''});

      final body = json.encode({
        if (status != null) 'status': status.toJson(),
        if (assignedToUserId != null) 'assigned_to_user_id': assignedToUserId,
        if (chariotId != null) 'chariot_id': chariotId,
        if (toLocationId != null) 'to_location_id': toLocationId,
      });

      final response = await http.put(uri, headers: _headers, body: body);

      if (response.statusCode == 200) {
        return StorageMove.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to update storage move: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error updating storage move: $e');
    }
  }

  /// Assign storage task to employee
  Future<StorageMove> assignStorageMove({
    required String taskId,
    required String employeeId,
    String? chariotId,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.storageMoves}/$taskId/assign',
      );

      final body = json.encode({
        'employee_id': employeeId,
        if (chariotId != null) 'chariot_id': chariotId,
      });

      final response = await http.post(uri, headers: _headers, body: body);

      if (response.statusCode == 200) {
        return StorageMove.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to assign storage move: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error assigning storage move: $e');
    }
  }

  /// Get AI recommendation for storage location
  Future<AIRecommendation> getAIRecommendation({
    required String skuId,
    required int quantity,
    String? abcClass,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.storageMoves}/ai/recommend',
      ).replace(queryParameters: {'user_id': currentUserId ?? ''});

      final body = json.encode({
        'sku_id': skuId,
        'quantity': quantity,
        if (abcClass != null) 'abc_class': abcClass,
      });

      final response = await http.post(uri, headers: _headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AIRecommendation.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to get AI recommendation: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error getting AI recommendation: $e');
    }
  }

  /// Override AI recommendation (human decision)
  Future<OverrideDecision> overrideRecommendation({
    required String recommendationId,
    required String newDestinationId,
    required String justification,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.storageMoves}/ai/override',
      );

      final body = json.encode({
        'recommendation_id': recommendationId,
        'new_destination_id': newDestinationId,
        'user_id': currentUserId ?? '',
        'justification': justification,
      });

      final response = await http.post(uri, headers: _headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OverrideDecision.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to override recommendation: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error overriding recommendation: $e');
    }
  }

  /// Complete storage move (mark as completed)
  Future<StorageMove> completeStorageMove({
    required String taskId,
    required String toLocationId,
  }) async {
    return updateStorageMove(
      taskId: taskId,
      status: TaskStatus.COMPLETED,
      toLocationId: toLocationId,
    );
  }

  /// Cancel storage move
  Future<void> cancelStorageMove({required String taskId}) async {
    try {
      await updateStorageMove(taskId: taskId, status: TaskStatus.CANCELLED);
    } catch (e) {
      throw Exception('Error cancelling storage move: $e');
    }
  }
}
