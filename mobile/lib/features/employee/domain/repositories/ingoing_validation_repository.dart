import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ingoing_validation_entity.dart';

/// Repository interface for ingoing order validation operations.
abstract class IngoingValidationRepository {
  /// Loads the validation data for a specific order.
  Future<Either<Failure, IngoingValidationEntity>> getValidation(
    String orderId,
  );

  /// Validates the product information step.
  Future<Either<Failure, IngoingValidationEntity>> validateProduct(
    String orderId,
  );

  /// Validates a specific item at a path step.
  Future<Either<Failure, IngoingValidationEntity>> validateItem(
    String orderId,
    String itemId,
    String pathStepId,
  );

  /// Reports a problem with the order.
  Future<Either<Failure, bool>> reportProblem(
    String orderId,
    String description,
  );

  /// Completes the entire validation process.
  Future<Either<Failure, bool>> completeValidation(String orderId);

  /// Caches validation data locally.
  Future<Either<Failure, void>> cacheValidation(
    IngoingValidationEntity validation,
  );

  /// Gets cached validation data.
  Future<Either<Failure, IngoingValidationEntity>> getCachedValidation(
    String orderId,
  );
}
