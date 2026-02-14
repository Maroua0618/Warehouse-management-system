import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/command_entity.dart';

/// Repository interface for ingoing order validation operations.
abstract class IngoingValidationRepository {
  /// Loads the validation data for a specific order.
  Future<Either<Failure, CommandEntity>> getValidation(String orderId);

  /// Validates the product information step.
  Future<Either<Failure, CommandEntity>> validateProduct(String orderId);

  /// Validates the task with all item validations.
  Future<Either<Failure, CommandEntity>> validateTask(
    String orderId, {
    List<String>? validatedItems,
  });

  /// Validates a specific item at a path step.
  Future<Either<Failure, CommandEntity>> validateItem(
    String orderId,
    String itemId,
    String pathStepId,
  );

  /// Reports a problem with the order.
  Future<Either<Failure, bool>> reportProblem(
    String orderId,
    String category,
    String description,
  );

  /// Completes the entire validation process.
  Future<Either<Failure, bool>> completeValidation(String orderId);

  /// Caches validation data locally.
  Future<Either<Failure, void>> cacheValidation(CommandEntity validation);

  /// Gets cached validation data.
  Future<Either<Failure, CommandEntity>> getCachedValidation(String orderId);
}
