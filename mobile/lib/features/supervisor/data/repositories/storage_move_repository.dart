import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/storage_move_models.dart';

class StorageMoveRepository {
  final String baseUrl;
  final String? authToken;

  StorageMoveRepository({required this.baseUrl, this.authToken});

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  /// Fetch all storage moves
  Future<List<StorageMove>> fetchStorageMoves({
    TaskStatus? status,
    PriorityLevel? priority,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status.toJson();
      if (priority != null) queryParams['priority'] = priority.toJson();

      final uri = Uri.parse(
        '$baseUrl/storage-moves',
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

  /// Fetch a single storage move by ID
  Future<StorageMove> fetchStorageMoveById(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/storage-moves/$id');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return StorageMove.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load storage move: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching storage move: $e');
    }
  }

  /// Fetch available employees for assignment
  Future<List<Employee>> fetchAvailableEmployees() async {
    try {
      final uri = Uri.parse('$baseUrl/employees/available');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Employee.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching employees: $e');
    }
  }

  /// Assign a storage move to an employee
  Future<StorageMove> assignStorageMove({
    required String moveId,
    required String employeeId,
    String? chariotId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/storage-moves/$moveId/assign');
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

  /// Fetch alternative locations for override
  Future<List<Location>> fetchAlternativeLocations({
    required String moveId,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/storage-moves/$moveId/alternative-locations',
      );
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Location.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load alternative locations: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching alternative locations: $e');
    }
  }

  /// Override AI recommendation
  Future<OverrideDecision> overrideRecommendation({
    required String recommendationId,
    required String newDestinationId,
    required int newQuantity,
    required String justification,
    required String userId,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/ai-recommendations/$recommendationId/override',
      );
      final body = json.encode({
        'new_destination_id': newDestinationId,
        'new_quantity': newQuantity,
        'justification': justification,
        'user_id': userId,
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

  /// Update storage move status
  Future<StorageMove> updateStorageMoveStatus({
    required String moveId,
    required TaskStatus status,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/storage-moves/$moveId/status');
      final body = json.encode({'status': status.toJson()});

      final response = await http.patch(uri, headers: _headers, body: body);

      if (response.statusCode == 200) {
        return StorageMove.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to update storage move status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error updating storage move status: $e');
    }
  }

  /// Complete a storage move
  Future<StorageMove> completeStorageMove({required String moveId}) async {
    try {
      final uri = Uri.parse('$baseUrl/storage-moves/$moveId/complete');
      final response = await http.post(uri, headers: _headers);

      if (response.statusCode == 200) {
        return StorageMove.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to complete storage move: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error completing storage move: $e');
    }
  }

  /// Cancel a storage move
  Future<void> cancelStorageMove({
    required String moveId,
    required String reason,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/storage-moves/$moveId/cancel');
      final body = json.encode({'reason': reason});

      final response = await http.post(uri, headers: _headers, body: body);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to cancel storage move: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error cancelling storage move: $e');
    }
  }
}
