import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/bon_de_preparation_model.dart';

/// Bon de Préparation Repository - Updated to match new backend API
/// Backend uses: orders (type='PREPARATION'), deliveries, stock_ledger_entries
class BonDePreparationRepository {
  final String? authToken;
  final String? currentUserId;

  BonDePreparationRepository({this.authToken, this.currentUserId});

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  /// Fetch all bon de préparation (preparation orders)
  Future<List<BonDePreparation>> fetchBonDePreparationList({
    String? status,
    String? deliveryId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (deliveryId != null) queryParams['delivery_id'] = deliveryId;

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/preparations',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => BonDePreparation.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load bon de préparation: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching bon de préparation: $e');
    }
  }

  /// Fetch a single bon de préparation by ID
  Future<BonDePreparation> fetchBonDePreparationById(String orderId) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/preparations/$orderId',
      );
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return BonDePreparation.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to load bon de préparation: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching bon de préparation: $e');
    }
  }

  /// Create a new bon de préparation (preparation order)
  Future<BonDePreparation> createBonDePreparation({
    required String deliveryId,
    String? priority,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/preparations',
      ).replace(queryParameters: {'user_id': currentUserId ?? ''});

      final body = json.encode({
        'delivery_id': deliveryId,
        if (priority != null) 'priority': priority,
      });

      final response = await http.post(uri, headers: _headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BonDePreparation.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to create bon de préparation: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error creating bon de préparation: $e');
    }
  }

  /// Add item to preparation order
  Future<PreparationItem> addPreparationItem({
    required String orderId,
    required String skuId,
    required int quantity,
    required String locationId,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/preparations/$orderId/items',
      ).replace(queryParameters: {'user_id': currentUserId ?? ''});

      final body = json.encode({
        'sku_id': skuId,
        'quantity': quantity,
        'location_id': locationId,
      });

      final response = await http.post(uri, headers: _headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PreparationItem.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to add preparation item: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error adding preparation item: $e');
    }
  }

  /// Update bon de préparation (status, assignment, etc.)
  Future<BonDePreparation> updateBonDePreparation({
    required String orderId,
    String? status,
    String? assignedToUserId,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/preparations/$orderId',
      ).replace(queryParameters: {'user_id': currentUserId ?? ''});

      final body = json.encode({
        if (status != null) 'status': status,
        if (assignedToUserId != null) 'assigned_to_user_id': assignedToUserId,
      });

      final response = await http.put(uri, headers: _headers, body: body);

      if (response.statusCode == 200) {
        return BonDePreparation.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to update bon de préparation: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error updating bon de préparation: $e');
    }
  }

  /// Assign bon de préparation to employee
  Future<BonDePreparation> assignBonDePreparation({
    required String orderId,
    required String employeeId,
  }) async {
    return updateBonDePreparation(
      orderId: orderId,
      assignedToUserId: employeeId,
    );
  }

  /// Update bon de préparation status
  Future<BonDePreparation> updateBonDePreparationStatus({
    required String orderId,
    required String status,
  }) async {
    return updateBonDePreparation(
      orderId: orderId,
      status: status,
    );
  }

  /// Complete bon de préparation
  Future<BonDePreparation> completeBonDePreparation({
    required String orderId,
  }) async {
    return updateBonDePreparation(
      orderId: orderId,
      status: 'COMPLETED',
    );
  }

  /// Delete bon de préparation
  Future<void> deleteBonDePreparation({required String orderId}) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/preparations/$orderId',
      ).replace(queryParameters: {'user_id': currentUserId ?? ''});

      final response = await http.delete(uri, headers: _headers);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete bon de préparation: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting bon de préparation: $e');
    }
  }
}
