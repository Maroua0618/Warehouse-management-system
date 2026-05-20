import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/command_model.dart';

/// Remote data source for ingoing validation operations.
abstract class IngoingValidationRemoteDataSource {
  /// Fetches validation data for an order from the API.
  Future<CommandModel> getValidation(String orderId);

  /// Validates product information via API.
  Future<CommandModel> validateProduct(String orderId);

  /// Validates the task with all item validations.
  Future<CommandModel> validateTask(
    String orderId, {
    List<String>? validatedItems,
  });

  /// Validates an item at a path step via API.
  Future<CommandModel> validateItem(
    String orderId,
    String itemId,
    String pathStepId,
  );

  /// Reports a problem with the order via API.
  Future<bool> reportProblem(
    String orderId,
    String category,
    String description,
  );

  /// Completes the validation process via API.
  Future<bool> completeValidation(String orderId);
}

/// Implementation of IngoingValidationRemoteDataSource using Dio.
class IngoingValidationRemoteDataSourceImpl
    implements IngoingValidationRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  IngoingValidationRemoteDataSourceImpl({
    required this.dio,
    this.baseUrl = '/tasks',
  });

  @override
  Future<CommandModel> getValidation(String orderId) async {
    try {
      final response = await dio.get('$baseUrl/$orderId');
      if (response.statusCode == 200) {
        return CommandModel.fromTaskDetail(
          response.data as Map<String, dynamic>,
        );
      }
      throw const ServerException('Failed to load validation data');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['detail'] ??
            e.response?.data?['message'] ??
            'Network error occurred',
      );
    }
  }

  @override
  Future<CommandModel> validateProduct(String orderId) async {
    try {
      final response = await dio.post(
        '$baseUrl/$orderId/validate',
        data: {'validated': true},
      );
      if (response.statusCode == 200) {
        return CommandModel.fromTaskDetail(
          response.data as Map<String, dynamic>,
        );
      }
      throw const ServerException('Failed to validate product');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['detail'] ??
            e.response?.data?['message'] ??
            'Network error occurred',
      );
    }
  }

  @override
  Future<CommandModel> validateTask(
    String orderId, {
    List<String>? validatedItems,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/$orderId/validate',
        data: {
          'validated': true,
          'validated_items': validatedItems,
          'notes': 'All items validated by employee',
        },
      );
      if (response.statusCode == 200) {
        return CommandModel.fromTaskDetail(
          response.data as Map<String, dynamic>,
        );
      }
      throw const ServerException('Failed to validate task');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['detail'] ??
            e.response?.data?['message'] ??
            'Network error occurred',
      );
    }
  }

  @override
  Future<CommandModel> validateItem(
    String orderId,
    String itemId,
    String pathStepId,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/$orderId/validate-item',
        data: {'item_id': itemId, 'path_step_id': pathStepId},
      );
      if (response.statusCode == 200) {
        return CommandModel.fromTaskDetail(
          response.data as Map<String, dynamic>,
        );
      }
      throw const ServerException('Failed to validate item');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['detail'] ??
            e.response?.data?['message'] ??
            'Network error occurred',
      );
    }
  }

  @override
  Future<bool> reportProblem(
    String orderId,
    String category,
    String description,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/$orderId/report-issue',
        data: {'category': category, 'description': description},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['detail'] ??
            e.response?.data?['message'] ??
            'Network error occurred',
      );
    }
  }

  @override
  Future<bool> completeValidation(String orderId) async {
    try {
      final response = await dio.post('$baseUrl/$orderId/complete');
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error occurred',
      );
    }
  }
}
