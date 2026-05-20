import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/command_entity.dart';

/// Repository interface for outgoing order execution operations.
abstract class OutgoingExecutionRepository {
  /// Loads the execution data for a specific order.
  Future<Either<Failure, CommandEntity>> getExecution(String orderId);

  /// Picks an item from inventory.
  Future<Either<Failure, CommandEntity>> pickItem(
    String orderId,
    String itemId,
  );

  /// Confirms the delivery.
  Future<Either<Failure, CommandEntity>> confirmDelivery(String orderId);

  /// Reports a problem with the order.
  Future<Either<Failure, bool>> reportProblem(
    String orderId,
    String description,
  );

  /// Completes the entire execution process.
  Future<Either<Failure, bool>> completeExecution(String orderId);
}
