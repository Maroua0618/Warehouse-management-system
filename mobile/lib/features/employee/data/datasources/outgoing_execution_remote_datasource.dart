import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/command_model.dart';

/// Remote data source for outgoing execution operations.
abstract class OutgoingExecutionRemoteDataSource {
  /// Fetches execution data for an order.
  Future<CommandModel> getExecution(String orderId);

  /// Picks an item.
  Future<CommandModel> pickItem(String orderId, String itemId);

  /// Confirms delivery.
  Future<CommandModel> confirmDelivery(String orderId);

  /// Reports a problem.
  Future<bool> reportProblem(String orderId, String description);

  /// Completes execution.
  Future<bool> completeExecution(String orderId);
}

/// Implementation using Dio HTTP client.
class OutgoingExecutionRemoteDataSourceImpl
    implements OutgoingExecutionRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  OutgoingExecutionRemoteDataSourceImpl({
    required this.dio,
    this.baseUrl = '/tasks',
  });

  @override
  Future<CommandModel> getExecution(String orderId) async {
    try {
      final response = await dio.get('$baseUrl/$orderId');
      if (response.statusCode == 200) {
        return CommandModel.fromTaskDetail(
          response.data as Map<String, dynamic>,
        );
      }
      throw const ServerException('Failed to load execution data');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['detail'] ??
            e.response?.data?['message'] ??
            'Network error occurred',
      );
    }
  }

  @override
  Future<CommandModel> pickItem(String orderId, String itemId) async {
    try {
      final response = await dio.post(
        '$baseUrl/$orderId/pick-item',
        data: {'item_id': itemId},
      );
      if (response.statusCode == 200) {
        return CommandModel.fromTaskDetail(
          response.data as Map<String, dynamic>,
        );
      }
      throw const ServerException('Failed to pick item');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['detail'] ??
            e.response?.data?['message'] ??
            'Network error occurred',
      );
    }
  }

  @override
  Future<CommandModel> confirmDelivery(String orderId) async {
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
      throw const ServerException('Failed to confirm delivery');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['detail'] ??
            e.response?.data?['message'] ??
            'Network error occurred',
      );
    }
  }

  @override
  Future<bool> reportProblem(String orderId, String description) async {
    try {
      final response = await dio.post(
        '$baseUrl/$orderId/report-issue',
        data: {'description': description},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error occurred',
      );
    }
  }

  @override
  Future<bool> completeExecution(String orderId) async {
    try {
      final response = await dio.put(
        '$baseUrl/$orderId/status',
        data: {'status': 'COMPLETED'},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error occurred',
      );
    }
  }
}
