import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ingoing_validation_entity.dart';
import '../../domain/entities/path_step_entity.dart';
import '../../domain/entities/validation_item_entity.dart';
import 'ingoing_validation_state.dart';

/// Mock cubit for testing ingoing validation UI with static data.
class MockIngoingValidationCubit extends Cubit<IngoingValidationState> {
  MockIngoingValidationCubit() : super(const IngoingValidationInitial());

  // Current state of validation for mock purposes
  late IngoingValidationEntity _currentValidation;

  /// Static mock validation data
  IngoingValidationEntity get _initialMockValidation {
    final items = [
      const ValidationItemEntity(
        id: 'item1',
        sku: 'SKU-98283-AX',
        name: 'Electronic Component A',
        quantity: 4,
        isValidated: false,
        slotLocation: 'N/A',
      ),
      const ValidationItemEntity(
        id: 'item2',
        sku: 'SKU-98284-BX',
        name: 'Electronic Component B',
        quantity: 12,
        isValidated: false,
        slotLocation: 'B-12',
      ),
      const ValidationItemEntity(
        id: 'item3',
        sku: 'SKU-98285-CX',
        name: 'Electronic Component C',
        quantity: 20,
        isValidated: false,
        slotLocation: 'C-05',
      ),
      const ValidationItemEntity(
        id: 'item4',
        sku: 'SKU-98286-DX',
        name: 'Electronic Component D',
        quantity: 14,
        isValidated: false,
        slotLocation: 'D-08',
      ),
    ];

    final pathSteps = [
      const PathStepEntity(
        id: 'step1',
        type: PathStepType.pickup,
        floor: 'Floor 1',
        locationName: 'Warehouse Entrance',
        row: 'A-04',
        slot: null,
        quantity: 12,
        isCompleted: true,
        isCurrent: false,
      ),
      PathStepEntity(
        id: 'step2',
        type: PathStepType.transit,
        floor: 'Floor 2',
        locationName: 'Buffer Zone',
        row: 'M',
        transit: 'Transit',
        slot: 'N/A',
        quantity: null,
        itemToPick: items[0],
        isCompleted: false,
        isCurrent: true,
      ),
      PathStepEntity(
        id: 'step3',
        type: PathStepType.transit,
        floor: 'Floor 2',
        locationName: 'Intermediate Storage Zone',
        row: 'N',
        transit: 'Transit',
        slot: 'B-12',
        quantity: null,
        itemToPick: items[1],
        isCompleted: false,
        isCurrent: false,
      ),
      PathStepEntity(
        id: 'step4',
        type: PathStepType.transit,
        floor: 'Floor 3',
        locationName: 'Consolidation Zone',
        row: 'P',
        transit: 'Transit',
        slot: 'C-05',
        quantity: null,
        itemToPick: items[2],
        isCompleted: false,
        isCurrent: false,
      ),
      PathStepEntity(
        id: 'step5',
        type: PathStepType.dropoff,
        floor: 'Floor 3',
        locationName: 'Bulk Storage',
        row: null,
        slot: 'B-12',
        quantity: 4,
        itemToPick: items[3],
        isCompleted: false,
        isCurrent: false,
      ),
    ];

    return IngoingValidationEntity(
      id: 'val-001',
      orderNumber: '#ING-9932',
      status: ValidationStatus.inProgress,
      productType: 'Electronics',
      totalQuantity: 50,
      validatedQuantity: 0,
      items: items,
      pathSteps: pathSteps,
      startFloor: 'Floor 1',
      endFloor: 'Floor 3',
      isProductValidated: false,
    );
  }

  /// Loads mock validation data.
  Future<void> loadValidation(String orderId) async {
    emit(const IngoingValidationLoading());

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _currentValidation = _initialMockValidation;
    emit(IngoingValidationLoaded(validation: _currentValidation));
  }

  /// Validates the product step.
  Future<void> validateProduct() async {
    emit(IngoingValidationValidating(currentValidation: _currentValidation));

    await Future.delayed(const Duration(milliseconds: 300));

    _currentValidation = _currentValidation.copyWith(isProductValidated: true);

    emit(IngoingValidationProductValidated(validation: _currentValidation));

    // Transition to loaded state for further operations
    await Future.delayed(const Duration(milliseconds: 100));
    emit(IngoingValidationLoaded(validation: _currentValidation));
  }

  /// Validates a specific item.
  Future<void> validateItem(String itemId, String pathStepId) async {
    emit(
      IngoingValidationValidating(
        currentValidation: _currentValidation,
        validatingItemId: itemId,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 300));

    // Update the item as validated
    final updatedItems = _currentValidation.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isValidated: true);
      }
      return item;
    }).toList();

    // Update path steps - mark current as completed, next as current
    final updatedPathSteps = <PathStepEntity>[];
    bool foundCurrent = false;
    bool setNextCurrent = false;

    for (final step in _currentValidation.pathSteps) {
      if (step.id == pathStepId) {
        updatedPathSteps.add(
          step.copyWith(isCompleted: true, isCurrent: false),
        );
        foundCurrent = true;
      } else if (foundCurrent && !setNextCurrent && !step.isCompleted) {
        updatedPathSteps.add(step.copyWith(isCurrent: true));
        setNextCurrent = true;
      } else {
        updatedPathSteps.add(step);
      }
    }

    _currentValidation = _currentValidation.copyWith(
      items: updatedItems,
      pathSteps: updatedPathSteps,
      validatedQuantity: updatedItems.where((i) => i.isValidated).length,
      status: updatedItems.every((i) => i.isValidated)
          ? ValidationStatus.completed
          : ValidationStatus.inProgress,
    );

    emit(
      IngoingValidationItemValidated(
        validation: _currentValidation,
        validatedItemId: itemId,
      ),
    );

    // Transition to loaded state
    await Future.delayed(const Duration(milliseconds: 100));
    emit(IngoingValidationLoaded(validation: _currentValidation));
  }

  /// Reports a problem.
  Future<void> reportProblem(String description) async {
    emit(IngoingValidationValidating(currentValidation: _currentValidation));

    await Future.delayed(const Duration(milliseconds: 300));

    _currentValidation = _currentValidation.copyWith(
      status: ValidationStatus.hasIssue,
      problemDescription: description,
    );

    emit(
      IngoingValidationProblemReported(
        validation: _currentValidation,
        description: description,
      ),
    );
  }

  /// Completes the validation process.
  Future<void> completeValidation() async {
    emit(IngoingValidationValidating(currentValidation: _currentValidation));

    await Future.delayed(const Duration(milliseconds: 300));

    emit(IngoingValidationCompleted(orderId: _currentValidation.id));
  }
}
