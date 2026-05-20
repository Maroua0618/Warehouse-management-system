import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/outgoing_execution_repository.dart';
import 'outgoing_execution_state.dart';

/// Cubit for managing outgoing order execution state.
class OutgoingExecutionCubit extends Cubit<OutgoingExecutionState> {
  final OutgoingExecutionRepository repository;

  OutgoingExecutionCubit({required this.repository})
    : super(const OutgoingExecutionInitial());

  /// Loads execution data for an order.
  Future<void> loadExecution(String orderId) async {
    emit(const OutgoingExecutionLoading());

    final result = await repository.getExecution(orderId);

    result.fold(
      (failure) => emit(OutgoingExecutionError(message: failure.message)),
      (command) => emit(OutgoingExecutionLoaded(command: command)),
    );
  }

  /// Picks an item from inventory.
  Future<void> pickItem(String itemId) async {
    final currentCommand = _getCurrentCommand();
    if (currentCommand == null) return;

    emit(
      OutgoingExecutionProcessing(
        currentCommand: currentCommand,
        processingItemId: itemId,
      ),
    );

    final result = await repository.pickItem(currentCommand.apiId, itemId);

    result.fold(
      (failure) => emit(
        OutgoingExecutionError(
          message: failure.message,
          previousCommand: currentCommand,
        ),
      ),
      (command) => emit(
        OutgoingExecutionItemPicked(command: command, pickedItemId: itemId),
      ),
    );
  }

  /// Confirms the delivery.
  Future<void> confirmDelivery() async {
    final currentCommand = _getCurrentCommand();
    if (currentCommand == null) return;

    emit(OutgoingExecutionProcessing(currentCommand: currentCommand));

    final result = await repository.confirmDelivery(currentCommand.apiId);

    result.fold(
      (failure) => emit(
        OutgoingExecutionError(
          message: failure.message,
          previousCommand: currentCommand,
        ),
      ),
      (command) => emit(OutgoingExecutionDeliveryConfirmed(command: command)),
    );
  }

  /// Reports a problem with the order.
  Future<void> reportProblem(String description) async {
    final currentCommand = _getCurrentCommand();
    if (currentCommand == null) return;

    emit(OutgoingExecutionProcessing(currentCommand: currentCommand));

    final result = await repository.reportProblem(
      currentCommand.apiId,
      description,
    );

    result.fold(
      (failure) => emit(
        OutgoingExecutionError(
          message: failure.message,
          previousCommand: currentCommand,
        ),
      ),
      (_) => emit(
        OutgoingExecutionProblemReported(
          command: currentCommand,
          description: description,
        ),
      ),
    );
  }

  /// Completes the execution process.
  Future<void> completeExecution() async {
    final currentCommand = _getCurrentCommand();
    if (currentCommand == null) return;

    emit(OutgoingExecutionProcessing(currentCommand: currentCommand));

    final result = await repository.completeExecution(currentCommand.apiId);

    result.fold(
      (failure) => emit(
        OutgoingExecutionError(
          message: failure.message,
          previousCommand: currentCommand,
        ),
      ),
      (_) => emit(OutgoingExecutionCompleted(orderId: currentCommand.apiId)),
    );
  }

  /// Helper to get the current command from various states.
  _getCurrentCommand() {
    final currentState = state;
    if (currentState is OutgoingExecutionLoaded) {
      return currentState.command;
    } else if (currentState is OutgoingExecutionItemPicked) {
      return currentState.command;
    } else if (currentState is OutgoingExecutionDeliveryConfirmed) {
      return currentState.command;
    } else if (currentState is OutgoingExecutionProcessing) {
      return currentState.currentCommand;
    } else if (currentState is OutgoingExecutionProblemReported) {
      return currentState.command;
    } else if (currentState is OutgoingExecutionError) {
      return currentState.previousCommand;
    }
    return null;
  }
}
