import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/datasources/employee_local_datasource.dart';
import '../data/models/command_model.dart';
import '../data/models/incident_model.dart';
import '../domain/entities/command_entity.dart';
import '../domain/entities/incident_entity.dart';
import '../domain/entities/user_entity.dart';

// ============== EMPLOYEE STATE ==============

/// Base state for employee feature
abstract class EmployeeState extends Equatable {
  const EmployeeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class EmployeeInitial extends EmployeeState {}

/// Loading state
class EmployeeLoading extends EmployeeState {}

/// Loaded state with all employee data
class EmployeeLoaded extends EmployeeState {
  final UserEntity currentUser;
  final List<CommandEntity> incomingOrders;
  final List<CommandEntity> outgoingOrders;
  final List<CommandEntity> pickingOrders;
  final Map<String, dynamic> stats;

  const EmployeeLoaded({
    required this.currentUser,
    required this.incomingOrders,
    required this.outgoingOrders,
    required this.pickingOrders,
    required this.stats,
  });

  /// Get all commands combined
  List<CommandEntity> get allCommands => [
    ...incomingOrders,
    ...outgoingOrders,
    ...pickingOrders,
  ];

  /// Get pending orders count
  int get pendingCount =>
      allCommands.where((c) => c.status == CommandStatus.pending).length;

  /// Get in-progress orders count
  int get inProgressCount =>
      allCommands.where((c) => c.status == CommandStatus.inProgress).length;

  @override
  List<Object?> get props => [
    currentUser,
    incomingOrders,
    outgoingOrders,
    pickingOrders,
    stats,
  ];

  EmployeeLoaded copyWith({
    UserEntity? currentUser,
    List<CommandEntity>? incomingOrders,
    List<CommandEntity>? outgoingOrders,
    List<CommandEntity>? pickingOrders,
    Map<String, dynamic>? stats,
  }) {
    return EmployeeLoaded(
      currentUser: currentUser ?? this.currentUser,
      incomingOrders: incomingOrders ?? this.incomingOrders,
      outgoingOrders: outgoingOrders ?? this.outgoingOrders,
      pickingOrders: pickingOrders ?? this.pickingOrders,
      stats: stats ?? this.stats,
    );
  }
}

/// Error state
class EmployeeError extends EmployeeState {
  final String message;

  const EmployeeError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when submitting an incident report
class EmployeeReportingIncident extends EmployeeState {
  final EmployeeLoaded previousState;

  const EmployeeReportingIncident(this.previousState);

  @override
  List<Object?> get props => [previousState];
}

/// State after incident successfully reported
class EmployeeIncidentReported extends EmployeeState {
  final EmployeeLoaded previousState;
  final IncidentEntity incident;

  const EmployeeIncidentReported(this.previousState, this.incident);

  @override
  List<Object?> get props => [previousState, incident];
}

// ============== EMPLOYEE CUBIT ==============

/// Cubit for managing employee feature state.
class EmployeeCubit extends Cubit<EmployeeState> {
  final EmployeeLocalDatasource _datasource;
  final int _currentUserId;

  EmployeeCubit({
    required EmployeeLocalDatasource datasource,
    required int currentUserId,
  }) : _datasource = datasource,
       _currentUserId = currentUserId,
       super(EmployeeInitial());

  /// Initialize and load all employee data
  Future<void> initialize() async {
    emit(EmployeeLoading());
    try {
      // Initialize sample data if needed
      await _datasource.insertSampleCommands();
      await _datasource.insertSampleInventory();

      // Load user
      final user = await _datasource.getCurrentUser(_currentUserId);
      if (user == null) {
        emit(const EmployeeError('User not found'));
        return;
      }

      // Load commands by type
      final incomingOrders = await _datasource.getCommands(type: 'RECEIPT');
      final outgoingOrders = await _datasource.getCommands(type: 'DELIVERY');
      final pickingOrders = await _datasource.getCommands(type: 'PICKING');

      // Load stats
      final stats = await _datasource.getEmployeeStats(_currentUserId);

      emit(
        EmployeeLoaded(
          currentUser: user,
          incomingOrders: incomingOrders,
          outgoingOrders: outgoingOrders,
          pickingOrders: pickingOrders,
          stats: stats,
        ),
      );
    } catch (e) {
      emit(EmployeeError('Erreur lors du chargement: ${e.toString()}'));
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    final currentState = state;
    if (currentState is! EmployeeLoaded) {
      await initialize();
      return;
    }

    try {
      final incomingOrders = await _datasource.getCommands(type: 'RECEIPT');
      final outgoingOrders = await _datasource.getCommands(type: 'DELIVERY');
      final pickingOrders = await _datasource.getCommands(type: 'PICKING');
      final stats = await _datasource.getEmployeeStats(_currentUserId);

      emit(
        currentState.copyWith(
          incomingOrders: incomingOrders,
          outgoingOrders: outgoingOrders,
          pickingOrders: pickingOrders,
          stats: stats,
        ),
      );
    } catch (e) {
      emit(EmployeeError('Error while refreshing: ${e.toString()}'));
    }
  }

  /// Report an incident
  Future<void> reportIncident({
    required String type,
    required String description,
    int? commandId,
    int? locationId,
  }) async {
    final currentState = state;
    if (currentState is! EmployeeLoaded) return;

    emit(EmployeeReportingIncident(currentState));

    try {
      // Parse type from display name
      final incidentType = IncidentModel.parseFromDisplayName(type);

      final incidentId = await _datasource.createIncident(
        type: _incidentTypeToString(incidentType),
        description: description,
        reportedBy: _currentUserId,
        commandId: commandId,
        locationId: locationId,
      );

      // Log the action
      await _datasource.logAction(
        userId: _currentUserId,
        action: 'CREATE_INCIDENT',
        entity: 'incident',
        entityId: incidentId,
        details: 'Type: $type, Description: $description',
      );

      // Create the incident entity to return
      final incident = IncidentEntity(
        id: incidentId,
        type: incidentType,
        description: description,
        reportedBy: _currentUserId,
        reporterName: currentState.currentUser.fullName,
        commandId: commandId,
        locationId: locationId,
        status: IncidentStatus.open,
        createdAt: DateTime.now(),
      );

      emit(EmployeeIncidentReported(currentState, incident));

      // Refresh stats after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      await refresh();
    } catch (e) {
      emit(EmployeeError('Erreur lors du signalement: ${e.toString()}'));
      emit(currentState);
    }
  }

  /// Helper to convert incident type to string
  String _incidentTypeToString(IncidentType type) {
    switch (type) {
      case IncidentType.workflowBottleneck:
        return 'WORKFLOW_BOTTLENECK';
      case IncidentType.wrongQuantity:
        return 'WRONG_QUANTITY';
      case IncidentType.wrongSku:
        return 'WRONG_SKU';
      case IncidentType.deliveryNotValidated:
        return 'DELIVERY_NOT_VALIDATED';
      case IncidentType.wrongStorageAssignment:
        return 'WRONG_STORAGE_ASSIGNMENT';
      case IncidentType.stockAvailabilityProblem:
        return 'STOCK_AVAILABILITY_PROBLEM';
      case IncidentType.damagedProducts:
        return 'DAMAGED_PRODUCTS';
      case IncidentType.other:
        return 'OTHER';
    }
  }

  /// Validate a command item
  Future<void> validateCommandItem(int commandId, int itemId) async {
    final currentState = state;
    if (currentState is! EmployeeLoaded) return;

    try {
      await _datasource.updateCommandItemStatus(
        itemId,
        'COMPLETED',
        validatedBy: _currentUserId,
      );

      // Update command status
      await _datasource.updateCommandStatus(commandId);

      // Log the action
      await _datasource.logAction(
        userId: _currentUserId,
        action: 'VALIDATE_ITEM',
        entity: 'command_item',
        entityId: itemId,
        details: 'Command: $commandId',
      );

      // Refresh data
      await refresh();
    } catch (e) {
      emit(EmployeeError('Erreur lors de la validation: ${e.toString()}'));
      emit(currentState);
    }
  }

  /// Complete a path step
  Future<void> completePathStep(int pathStepId) async {
    final currentState = state;
    if (currentState is! EmployeeLoaded) return;

    try {
      await _datasource.completePathStep(pathStepId);

      // Log the action
      await _datasource.logAction(
        userId: _currentUserId,
        action: 'COMPLETE_PATH_STEP',
        entity: 'path_step',
        entityId: pathStepId,
      );

      // Refresh data
      await refresh();
    } catch (e) {
      emit(EmployeeError('Erreur: ${e.toString()}'));
      emit(currentState);
    }
  }

  /// Get a specific command with details
  Future<CommandModel?> getCommandDetails(int commandId) async {
    try {
      return await _datasource.getCommandById(commandId);
    } catch (e) {
      return null;
    }
  }
}
