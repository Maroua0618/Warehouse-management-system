import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/order_model.dart';

/// Abstract interface for remote data source.
/// Defines the contract for fetching orders from the remote API.
abstract class OrderRemoteDataSource {
  /// Fetches orders from the remote API.
  /// Throws [ServerException] or [NetworkException] on failure.
  Future<List<OrderModel>> getOrders({
    required String type,
    String? employeeId,
  });

  /// Fetches a single order by ID from remote API.
  Future<OrderModel> getOrderById(String orderId);

  /// Updates order status on remote server.
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String newStatus,
  });
}

/// Implementation of OrderRemoteDataSource using Dio HTTP client.
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;

  OrderRemoteDataSourceImpl(this.dio);

  @override
  Future<List<OrderModel>> getOrders({
    required String type,
    String? employeeId,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{
        'type': type,
        if (employeeId != null) 'employee_id': employeeId,
      };

      // Make API request
      final response = await dio.get(
        '${AppConstants.baseUrl}/orders',
        queryParameters: queryParams,
      );

      // Check response status and parse data
      if (response.statusCode == 200) {
        final data = response.data;

        // Handle both {data: [...]} and direct [...] response formats
        final List<dynamic> ordersJson = data is Map
            ? (data['data'] as List)
            : (data as List);

        return ordersJson
            .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException('Failed to fetch orders: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/orders/$orderId');

      if (response.statusCode == 200) {
        final data = response.data;
        final orderJson = data is Map && data.containsKey('data')
            ? data['data']
            : data;

        return OrderModel.fromJson(orderJson as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to fetch order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    try {
      final response = await dio.patch(
        '${AppConstants.baseUrl}/orders/$orderId/status',
        data: {'status': newStatus},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final orderJson = data is Map && data.containsKey('data')
            ? data['data']
            : data;

        return OrderModel.fromJson(orderJson as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Failed to update order status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  /// Converts Dio errors to custom exceptions.
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection timeout');

      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return const UnauthorizedException('Unauthorized access');
        } else if (statusCode == 404) {
          return const NotFoundException('Resource not found');
        } else {
          return ServerException(
            'Server error: ${error.response?.statusMessage ?? "Unknown"}',
          );
        }

      case DioExceptionType.cancel:
        return const ServerException('Request cancelled');

      default:
        return ServerException('Network error: ${error.message}');
    }
  }
}
