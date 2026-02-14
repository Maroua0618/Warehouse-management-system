// Models for Operational Monitor and Live Tracking

/// Represents the status of an employee
enum EmployeeStatus {
  active,
  idle,
  standby,
  offline;

  String get label {
    switch (this) {
      case EmployeeStatus.active:
        return 'ACTIVE';
      case EmployeeStatus.idle:
        return 'IDLE';
      case EmployeeStatus.standby:
        return 'STANDBY';
      case EmployeeStatus.offline:
        return 'OFFLINE';
    }
  }
}

/// Represents an employee's location coordinates
class EmployeeLocation {
  final double x; // Position on map (0.0 to 1.0 relative to map width)
  final double y; // Position on map (0.0 to 1.0 relative to map height)
  final String aisle; // e.g., "Aisle 04"
  final String? destination; // e.g., "Dock B"
  final DateTime timestamp;

  EmployeeLocation({
    required this.x,
    required this.y,
    required this.aisle,
    this.destination,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String get locationDescription {
    if (destination != null) {
      return 'Near: $aisle → $destination';
    }
    return 'Location: $aisle';
  }

  factory EmployeeLocation.fromJson(Map<String, dynamic> json) {
    return EmployeeLocation(
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      aisle: json['aisle'] ?? json['current_zone'] ?? '',
      destination: json['destination'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}

/// Represents an employee being tracked in the warehouse
class Employee {
  final String id; // e.g., "EMP-01"
  final String name;
  final EmployeeStatus status;
  final String role; // e.g., "Picker", "Forklift Operator"
  final EmployeeLocation location;
  final String assignedTask; // e.g., "Picking Order #2345"
  final List<EmployeeLocation> path; // Historical path for dotted line

  Employee({
    required this.id,
    required this.name,
    required this.status,
    required this.role,
    required this.location,
    required this.assignedTask,
    this.path = const [],
  });

  bool get isOperational =>
      status == EmployeeStatus.active || status == EmployeeStatus.idle;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? json['user_id'] ?? '',
      name: json['name'] ?? '',
      status: _parseEmployeeStatus(json['status']),
      role: json['role'] ?? '',
      location: json['location'] != null
          ? EmployeeLocation.fromJson(json['location'])
          : EmployeeLocation(x: 0, y: 0, aisle: ''),
      assignedTask:
          json['assigned_task'] ?? json['current_task_type'] ?? 'No task',
      path:
          (json['path'] as List<dynamic>?)
              ?.map((p) => EmployeeLocation.fromJson(p))
              .toList() ??
          [],
    );
  }

  static EmployeeStatus _parseEmployeeStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'ACTIVE':
        return EmployeeStatus.active;
      case 'IDLE':
        return EmployeeStatus.idle;
      case 'STANDBY':
        return EmployeeStatus.standby;
      case 'OFFLINE':
        return EmployeeStatus.offline;
      default:
        return EmployeeStatus.idle;
    }
  }
}

/// Represents an alert or issue in operations
enum AlertType {
  trafficJam,
  lowBattery,
  delayedTask,
  equipmentMalfunction;

  String get icon {
    switch (this) {
      case AlertType.trafficJam:
        return '🚦';
      case AlertType.lowBattery:
        return '🔋';
      case AlertType.delayedTask:
        return '⏱️';
      case AlertType.equipmentMalfunction:
        return '⚠️';
    }
  }
}

class OperationalAlert {
  final AlertType type;
  final String title;
  final String description;
  final String employeeId;
  final DateTime timestamp;
  final bool canResolve;

  OperationalAlert({
    required this.type,
    required this.title,
    required this.description,
    required this.employeeId,
    DateTime? timestamp,
    this.canResolve = false,
  }) : timestamp = timestamp ?? DateTime.now();

  factory OperationalAlert.fromJson(Map<String, dynamic> json) {
    return OperationalAlert(
      type: _parseAlertType(json['alert_type']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      employeeId: json['employee_id'] ?? '',
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      canResolve: json['status'] == 'ACTIVE',
    );
  }

  static AlertType _parseAlertType(String? type) {
    switch (type?.toUpperCase()) {
      case 'TRAFFIC_JAM':
        return AlertType.trafficJam;
      case 'LOW_BATTERY':
        return AlertType.lowBattery;
      case 'DELAYED_TASK':
      case 'TASK_DELAY':
        return AlertType.delayedTask;
      case 'EQUIPMENT_MALFUNCTION':
      case 'EQUIPMENT_ISSUE':
        return AlertType.equipmentMalfunction;
      default:
        return AlertType.delayedTask;
    }
  }
}

/// Represents execution progress for different warehouse operations
class ExecutionProgress {
  final String label;
  final int percentage; // 0-100
  final int completed;
  final int total;

  ExecutionProgress({
    required this.label,
    required this.percentage,
    required this.completed,
    required this.total,
  });

  String get progressText => '$completed/$total';

  factory ExecutionProgress.fromJson(Map<String, dynamic> json) {
    return ExecutionProgress(
      label: json['label'] ?? '',
      percentage: json['percentage'] ?? 0,
      completed: json['completed'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

/// Represents overall operational statistics
class OperationalStats {
  final int activeEmployees;
  final int completedOrders;
  final int zoneEfficiency; // 0-100
  final String currentFloor; // e.g., "RDC"
  final List<ExecutionProgress> executionProgress;

  OperationalStats({
    required this.activeEmployees,
    required this.completedOrders,
    required this.zoneEfficiency,
    required this.currentFloor,
    required this.executionProgress,
  });

  factory OperationalStats.fromJson(Map<String, dynamic> json) {
    return OperationalStats(
      activeEmployees: json['active_employees'] ?? 0,
      completedOrders: json['completed_orders'] ?? 0,
      zoneEfficiency: json['zone_efficiency'] ?? 0,
      currentFloor: json['current_floor'] ?? 'RDC',
      executionProgress:
          (json['execution_progress'] as List<dynamic>?)
              ?.map((p) => ExecutionProgress.fromJson(p))
              .toList() ??
          [],
    );
  }
}
