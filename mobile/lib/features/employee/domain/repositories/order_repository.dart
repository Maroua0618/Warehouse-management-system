import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';

/// Abstract repository interface for Order operations.
/// This defines the contract that the data layer must implement.
/// 
/// The repository coordinates between remote and local data sources:
/// - If online: Fetch from remote API, cache locally, return data
/// - If offline: Fetch from local cache
abstract class OrderRepository {
  /// Fetches orders based on the type (outgoing/incoming).
  /// 
  /// Parameters:
  /// - [type]: Either 'outgoing' or 'incoming'
  /// - [employeeId]: Optional filter for specific employee's orders
  /// 
  /// Returns:
  /// - [Right(List<OrderEntity>)]: Success with list of orders
  /// - [Left(Failure)]: Error with failure details
  Future<Either<Failure, List<OrderEntity>>> getOrders({
    required String type,
    String? employeeId,
  });

  /// Fetches a single order by its ID.
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);

  /// Updates the status of an order.
  Future<Either<Failure, OrderEntity>> updateOrderStatus({
    required String orderId,
    required String newStatus,
  });

  /// Forces a refresh from remote API and updates local cache.
  Future<Either<Failure, List<OrderEntity>>> refreshOrders({
    required String type,
    String? employeeId,
  });
}
