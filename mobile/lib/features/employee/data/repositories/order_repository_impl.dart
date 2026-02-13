import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_local_datasource.dart';
import '../datasources/order_remote_datasource.dart';

/// Implementation of OrderRepository that coordinates between
/// remote and local data sources based on network connectivity.
///
/// Data Flow:
/// 1. Check network connectivity
/// 2. If online:
///    - Fetch from remote API
///    - Cache results locally
///    - Return data
/// 3. If offline:
///    - Fetch from local cache
///    - Return cached data
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final OrderLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders({
    required String type,
    String? employeeId,
  }) async {
    // Check network connectivity
    if (await networkInfo.isConnected) {
      // Online: Fetch from remote API
      try {
        final remoteOrders = await remoteDataSource.getOrders(
          type: type,
          employeeId: employeeId,
        );

        // Cache the fetched orders locally
        await localDataSource.cacheOrders(remoteOrders);

        // Return the orders
        return Right(remoteOrders);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException {
        // Network error during request, try local cache
        return _getOrdersFromCache(type: type, employeeId: employeeId);
      } on UnauthorizedException catch (e) {
        return Left(UnauthorizedFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      // Offline: Fetch from local cache
      return _getOrdersFromCache(type: type, employeeId: employeeId);
    }
  }

  /// Helper method to fetch orders from local cache.
  Future<Either<Failure, List<OrderEntity>>> _getOrdersFromCache({
    required String type,
    String? employeeId,
  }) async {
    try {
      final localOrders = await localDataSource.getOrders(
        type: type,
        employeeId: employeeId,
      );
      return Right(localOrders);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to load cached data'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    if (await networkInfo.isConnected) {
      try {
        final order = await remoteDataSource.getOrderById(orderId);
        // Update local cache
        await localDataSource.updateOrder(order);
        return Right(order);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
      } on NetworkException {
        // Try local cache on network error
        return _getOrderByIdFromCache(orderId);
      } catch (e) {
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      return _getOrderByIdFromCache(orderId);
    }
  }

  /// Helper method to fetch single order from cache.
  Future<Either<Failure, OrderEntity>> _getOrderByIdFromCache(
    String orderId,
  ) async {
    try {
      final order = await localDataSource.getOrderById(orderId);
      return Right(order);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Order not found in cache'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedOrder = await remoteDataSource.updateOrderStatus(
          orderId: orderId,
          newStatus: newStatus,
        );

        // Update local cache
        await localDataSource.updateOrder(updatedOrder);

        return Right(updatedOrder);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
      } on UnauthorizedException catch (e) {
        return Left(UnauthorizedFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('Cannot update order while offline'));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> refreshOrders({
    required String type,
    String? employeeId,
  }) async {
    // Force refresh always tries remote first
    if (await networkInfo.isConnected) {
      try {
        final remoteOrders = await remoteDataSource.getOrders(
          type: type,
          employeeId: employeeId,
        );

        // Clear old cache and store new data
        await localDataSource.clearOrders();
        await localDataSource.cacheOrders(remoteOrders);

        return Right(remoteOrders);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('Cannot refresh while offline'));
    }
  }
}
