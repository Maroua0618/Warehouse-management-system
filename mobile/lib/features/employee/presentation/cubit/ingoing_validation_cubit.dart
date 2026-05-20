import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/ingoing_validation_repository.dart';
import 'ingoing_validation_state.dart';

/// Cubit for managing ingoing order validation state.
class IngoingValidationCubit extends Cubit<IngoingValidationState> {
  final IngoingValidationRepository repository;

  IngoingValidationCubit({required this.repository})
    : super(const IngoingValidationInitial());

  /// Loads validation data for an order.
  Future<void> loadValidation(String orderId) async {
    emit(const IngoingValidationLoading());

    final result = await repository.getValidation(orderId);

    result.fold(
      (failure) => emit(IngoingValidationError(message: failure.message)),
      (validation) => emit(IngoingValidationLoaded(validation: validation)),
    );
  }

  /// Validates the product information step.
  Future<void> validateProduct() async {
    final currentState = state;
    if (currentState is! IngoingValidationLoaded) return;

    emit(
      IngoingValidationValidating(currentValidation: currentState.validation),
    );

    final result = await repository.validateProduct(
      currentState.validation.apiId,
    );

    result.fold(
      (failure) => emit(
        IngoingValidationError(
          message: failure.message,
          previousValidation: currentState.validation,
        ),
      ),
      (validation) =>
          emit(IngoingValidationProductValidated(validation: validation)),
    );
  }

  /// Validates a specific item at a path step.
  Future<void> validateItem(String itemId, String pathStepId) async {
    final currentState = state;
    if (currentState is! IngoingValidationLoaded &&
        currentState is! IngoingValidationItemValidated &&
        currentState is! IngoingValidationProductValidated) {
      return;
    }

    final currentValidation = _getCurrentValidation();
    if (currentValidation == null) return;

    emit(
      IngoingValidationValidating(
        currentValidation: currentValidation,
        validatingItemId: itemId,
      ),
    );

    final result = await repository.validateItem(
      currentValidation.apiId,
      itemId,
      pathStepId,
    );

    result.fold(
      (failure) => emit(
        IngoingValidationError(
          message: failure.message,
          previousValidation: currentValidation,
        ),
      ),
      (validation) => emit(
        IngoingValidationItemValidated(
          validation: validation,
          validatedItemId: itemId,
        ),
      ),
    );
  }

  /// Validates the task with all item validations.
  Future<void> validateTask(
    String orderId, {
    List<String>? validatedItems,
  }) async {
    final currentValidation = _getCurrentValidation();
    if (currentValidation == null) return;

    emit(IngoingValidationValidating(currentValidation: currentValidation));

    final result = await repository.validateTask(
      orderId,
      validatedItems: validatedItems,
    );

    result.fold(
      (failure) => emit(
        IngoingValidationError(
          message: failure.message,
          previousValidation: currentValidation,
        ),
      ),
      (validation) => emit(IngoingValidationCompleted(orderId: orderId)),
    );
  }

  /// Reports a problem with the order.
  Future<void> reportProblem(String category, String description) async {
    final currentValidation = _getCurrentValidation();
    if (currentValidation == null) return;

    emit(IngoingValidationValidating(currentValidation: currentValidation));

    final result = await repository.reportProblem(
      currentValidation.apiId,
      category,
      description,
    );

    result.fold(
      (failure) => emit(
        IngoingValidationError(
          message: failure.message,
          previousValidation: currentValidation,
        ),
      ),
      (_) => emit(
        IngoingValidationProblemReported(
          validation: currentValidation,
          description: description,
        ),
      ),
    );
  }

  /// Completes the validation process.
  Future<void> completeValidation() async {
    final currentValidation = _getCurrentValidation();
    if (currentValidation == null) return;

    emit(IngoingValidationValidating(currentValidation: currentValidation));

    final result = await repository.completeValidation(currentValidation.apiId);

    result.fold(
      (failure) => emit(
        IngoingValidationError(
          message: failure.message,
          previousValidation: currentValidation,
        ),
      ),
      (_) => emit(IngoingValidationCompleted(orderId: currentValidation.apiId)),
    );
  }

  /// Helper to get the current validation from various states.
  _getCurrentValidation() {
    final currentState = state;
    if (currentState is IngoingValidationLoaded) {
      return currentState.validation;
    } else if (currentState is IngoingValidationItemValidated) {
      return currentState.validation;
    } else if (currentState is IngoingValidationProductValidated) {
      return currentState.validation;
    } else if (currentState is IngoingValidationValidating) {
      return currentState.currentValidation;
    } else if (currentState is IngoingValidationProblemReported) {
      return currentState.validation;
    } else if (currentState is IngoingValidationError) {
      return currentState.previousValidation;
    }
    return null;
  }
}
