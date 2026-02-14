import 'package:equatable/equatable.dart';
import '../../domain/entities/ingoing_validation_entity.dart';

/// Base state for ingoing validation operations.
abstract class IngoingValidationState extends Equatable {
  const IngoingValidationState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading.
class IngoingValidationInitial extends IngoingValidationState {
  const IngoingValidationInitial();
}

/// Loading state while fetching validation data.
class IngoingValidationLoading extends IngoingValidationState {
  const IngoingValidationLoading();
}

/// Loaded state with validation data.
class IngoingValidationLoaded extends IngoingValidationState {
  final IngoingValidationEntity validation;
  final bool isFromCache;

  const IngoingValidationLoaded({
    required this.validation,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [validation, isFromCache];
}

/// State while validating an item.
class IngoingValidationValidating extends IngoingValidationState {
  final IngoingValidationEntity currentValidation;
  final String? validatingItemId;

  const IngoingValidationValidating({
    required this.currentValidation,
    this.validatingItemId,
  });

  @override
  List<Object?> get props => [currentValidation, validatingItemId];
}

/// State when an item has been successfully validated.
class IngoingValidationItemValidated extends IngoingValidationState {
  final IngoingValidationEntity validation;
  final String validatedItemId;

  const IngoingValidationItemValidated({
    required this.validation,
    required this.validatedItemId,
  });

  @override
  List<Object?> get props => [validation, validatedItemId];
}

/// State when product validation is complete.
class IngoingValidationProductValidated extends IngoingValidationState {
  final IngoingValidationEntity validation;

  const IngoingValidationProductValidated({required this.validation});

  @override
  List<Object?> get props => [validation];
}

/// State when the entire validation process is complete.
class IngoingValidationCompleted extends IngoingValidationState {
  final String orderId;

  const IngoingValidationCompleted({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

/// State when a problem has been reported.
class IngoingValidationProblemReported extends IngoingValidationState {
  final IngoingValidationEntity validation;
  final String description;

  const IngoingValidationProblemReported({
    required this.validation,
    required this.description,
  });

  @override
  List<Object?> get props => [validation, description];
}

/// Error state with message.
class IngoingValidationError extends IngoingValidationState {
  final String message;
  final IngoingValidationEntity? previousValidation;

  const IngoingValidationError({
    required this.message,
    this.previousValidation,
  });

  @override
  List<Object?> get props => [message, previousValidation];
}
