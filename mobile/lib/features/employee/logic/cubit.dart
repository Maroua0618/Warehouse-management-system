import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../data/datasources/employee_local_datasource.dart';
import '../data/models/command_model.dart';
import '../data/models/incident_model.dart';
import '../domain/entities/command_entity.dart';
import '../domain/entities/incident_entity.dart';
import '../../shared/domain/entities/user_entity.dart';
import '../../shared/presentation/cubit/auth_cubit.dart';
import '../../shared/presentation/cubit/auth_state.dart';

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
  final AuthCubit _authCubit;
  final String _baseUrl = 'http://10.36.245.125:8000';

  EmployeeCubit({
    required EmployeeLocalDatasource datasource,
    required AuthCubit authCubit,
  }) : _datasource = datasource,
       _authCubit = authCubit,
       super(EmployeeInitial());

  /// Initialize and load all employee data
  Future<void> initialize() async {
    emit(EmployeeLoading());
    try {
      print('🔵 CUBIT: Starting initialize()');
      // Get authenticated user from AuthCubit
      final authState = _authCubit.state;
      if (authState is! AuthAuthenticated) {
        print('❌ CUBIT: User not authenticated');
        emit(const EmployeeError('User not authenticated'));
        return;
      }

      final backendToken = authState.user.backendToken;
      if (backendToken == null) {
        print('❌ CUBIT: Backend token not available');
        emit(const EmployeeError('Backend token not available'));
        return;
      }

      print('✅ CUBIT: Auth OK, user=${authState.user.email}');
      // Use authenticated user data
      final user = authState.user;

      // Fetch commands and stats from backend in parallel
      final results = await Future.wait([
        _fetchAllTasksFromBackend(backendToken),
        _fetchStatsFromBackend(backendToken),
      ]);

      final tasksMap = results[0] as Map<String, List<CommandEntity>>;
      final stats = results[1] as Map<String, dynamic>;

      final incomingOrders = tasksMap['ingoing'] ?? [];
      final outgoingOrders = tasksMap['outgoing'] ?? [];
      final pickingOrders = tasksMap['picking'] ?? [];

      print(
        '📦 Tasks loaded - Incoming: ${incomingOrders.length}, Outgoing: ${outgoingOrders.length}, Picking: ${pickingOrders.length}',
      );

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

  /// Fetch all tasks from backend API (single call)
  Future<Map<String, List<CommandEntity>>> _fetchAllTasksFromBackend(
    String token,
  ) async {
    try {
      print('Fetching tasks from: $_baseUrl/tasks');
      print(
        'Using token: ${token.length > 20 ? '${token.substring(0, 20)}...' : token}',
      );
      final response = await http
          .get(
            Uri.parse('$_baseUrl/tasks'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('Successfully fetched all tasks from backend');
        print('Response body: ${response.body}');
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final ingoingRaw = data['ingoing_tasks'] as List? ?? [];
        final outgoingRaw = data['outgoing_tasks'] as List? ?? [];

        final ingoing = ingoingRaw
            .map(
              (json) =>
                  CommandModel.fromTaskSummary(json as Map<String, dynamic>),
            )
            .toList();
        final outgoing = outgoingRaw
            .map(
              (json) =>
                  CommandModel.fromTaskSummary(json as Map<String, dynamic>),
            )
            .toList();

        // Separate picking tasks from outgoing based on operation_type
        final picking = outgoing
            .where((c) => c.type == CommandType.picking)
            .toList();
        final delivery = outgoing
            .where((c) => c.type != CommandType.picking)
            .toList();

        return {'ingoing': ingoing, 'outgoing': delivery, 'picking': picking};
      } else {
        print(
          'Backend failed to fetch tasks. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return {'ingoing': [], 'outgoing': [], 'picking': []};
      }
    } catch (e) {
      print('Error fetching tasks from backend: $e');
      print('Token used: ${token.substring(0, 20)}...');
      return {'ingoing': [], 'outgoing': [], 'picking': []};
    }
  }

  /// Fetch stats from backend API
  Future<Map<String, dynamic>> _fetchStatsFromBackend(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/employee/stats'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        // Fallback to local stats
        final authState = _authCubit.state;
        if (authState is AuthAuthenticated) {
          return {
            'total_tasks': 0,
            'completed_tasks': 0,
            'completion_rate': 0.0,
          };
        }
        return {};
      }
    } catch (e) {
      // Return empty stats if API fails
      return {'total_tasks': 0, 'completed_tasks': 0, 'completion_rate': 0.0};
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
      // Get auth token
      final authState = _authCubit.state;
      if (authState is! AuthAuthenticated ||
          authState.user.backendToken == null) {
        emit(const EmployeeError('User not authenticated'));
        return;
      }

      final backendToken = authState.user.backendToken!;

      // Fetch fresh data from backend
      final results = await Future.wait([
        _fetchAllTasksFromBackend(backendToken),
        _fetchStatsFromBackend(backendToken),
      ]);

      final tasksMap = results[0] as Map<String, List<CommandEntity>>;
      final stats = results[1] as Map<String, dynamic>;

      final incomingOrders = tasksMap['ingoing'] ?? [];
      final outgoingOrders = tasksMap['outgoing'] ?? [];
      final pickingOrders = tasksMap['picking'] ?? [];

      emit(
        EmployeeLoaded(
          currentUser: currentState.currentUser,
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
      // Get user ID from current state
      final userId = int.tryParse(currentState.currentUser.userId) ?? 0;

      // Parse type from display name
      final incidentType = IncidentModel.parseFromDisplayName(type);

      final incidentId = await _datasource.createIncident(
        type: _incidentTypeToString(incidentType),
        description: description,
        reportedBy: userId,
        commandId: commandId,
        locationId: locationId,
      );

      // Log the action
      await _datasource.logAction(
        userId: userId,
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
        reportedBy: userId,
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
      final userId = int.tryParse(currentState.currentUser.userId) ?? 0;

      await _datasource.updateCommandItemStatus(
        itemId,
        'COMPLETED',
        validatedBy: userId,
      );

      // Update command status
      await _datasource.updateCommandStatus(commandId);

      // Log the action
      await _datasource.logAction(
        userId: userId,
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
      final userId = int.tryParse(currentState.currentUser.userId) ?? 0;

      await _datasource.completePathStep(pathStepId);

      // Log the action
      await _datasource.logAction(
        userId: userId,
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
