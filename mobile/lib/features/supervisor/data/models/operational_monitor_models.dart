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
}
