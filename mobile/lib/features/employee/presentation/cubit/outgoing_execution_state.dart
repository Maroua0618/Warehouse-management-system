import 'package:equatable/equatable.dart';
import '../../domain/entities/command_entity.dart';

/// Base state for outgoing execution operations.
abstract class OutgoingExecutionState extends Equatable {
  const OutgoingExecutionState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading.
class OutgoingExecutionInitial extends OutgoingExecutionState {
  const OutgoingExecutionInitial();
}

/// Loading state while fetching execution data.
class OutgoingExecutionLoading extends OutgoingExecutionState {
  const OutgoingExecutionLoading();
}

/// Loaded state with execution data.
class OutgoingExecutionLoaded extends OutgoingExecutionState {
  final CommandEntity command;
  final bool isFromCache;

  const OutgoingExecutionLoaded({
    required this.command,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [command, isFromCache];
}

/// State while executing an action.
class OutgoingExecutionProcessing extends OutgoingExecutionState {
  final CommandEntity currentCommand;
  final String? processingItemId;

  const OutgoingExecutionProcessing({
    required this.currentCommand,
    this.processingItemId,
  });

  @override
  List<Object?> get props => [currentCommand, processingItemId];
}

/// State when an item has been successfully picked.
class OutgoingExecutionItemPicked extends OutgoingExecutionState {
  final CommandEntity command;
  final String pickedItemId;

  const OutgoingExecutionItemPicked({
    required this.command,
    required this.pickedItemId,
  });

  @override
  List<Object?> get props => [command, pickedItemId];
}

/// State when the delivery is confirmed.
class OutgoingExecutionDeliveryConfirmed extends OutgoingExecutionState {
  final CommandEntity command;

  const OutgoingExecutionDeliveryConfirmed({required this.command});

  @override
  List<Object?> get props => [command];
}

/// State when the entire execution process is complete.
class OutgoingExecutionCompleted extends OutgoingExecutionState {
  final String orderId;

  const OutgoingExecutionCompleted({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

/// State when a problem has been reported.
class OutgoingExecutionProblemReported extends OutgoingExecutionState {
  final CommandEntity command;
  final String description;

  const OutgoingExecutionProblemReported({
    required this.command,
    required this.description,
  });

  @override
  List<Object?> get props => [command, description];
}

/// Error state with message.
class OutgoingExecutionError extends OutgoingExecutionState {
  final String message;
  final CommandEntity? previousCommand;

  const OutgoingExecutionError({required this.message, this.previousCommand});

  @override
  List<Object?> get props => [message, previousCommand];
}
