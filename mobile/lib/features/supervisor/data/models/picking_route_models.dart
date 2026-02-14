// Models for Picking Route (Itinéraire de Prélèvement)

/// Represents a worker that can be assigned to picking tasks
class Worker {
  final String id;
  final String name;
  final String role;
  final String? avatarUrl;
  final bool isAvailable;

  Worker({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.isAvailable = true,
  });
}

/// Represents equipment used for picking
class Equipment {
  final String id;
  final String name;
  final String type;
  final bool isAvailable;

  Equipment({
    required this.id,
    required this.name,
    required this.type,
    this.isAvailable = true,
  });
}

/// Represents a location in the picking sequence
class PickingLocation {
  final String code;
  final String warehousePosition;
  final String estimatedDistance;

  PickingLocation({
    required this.code,
    required this.warehousePosition,
    required this.estimatedDistance,
  });
}

/// Represents a picking route with optimized sequence
class PickingRoute {
  final String deliveryId;
  final List<PickingLocation> sequence;
  final String totalDistance;
  final int totalItems;

  PickingRoute({
    required this.deliveryId,
    required this.sequence,
    required this.totalDistance,
    required this.totalItems,
  });
}

/// Represents a picking task
class PickingTask {
  final String deliveryId;
  final String pathType; // 'Residential Path', 'Commercial Path', etc.
  final String startLocation;
  final String endLocation;
  final int timeRemaining; // in minutes
  final String estimatedTime; // formatted time
  final int totalItems;
  final String? assignedWorker;
  final String? assignedEquipment;
  final String status; // 'pending', 'assigned', 'in_progress', 'completed'
  final PickingRoute? route;

  PickingTask({
    required this.deliveryId,
    required this.pathType,
    required this.startLocation,
    required this.endLocation,
    required this.timeRemaining,
    required this.estimatedTime,
    required this.totalItems,
    this.assignedWorker,
    this.assignedEquipment,
    this.status = 'pending',
    this.route,
  });

  PickingTask copyWith({
    String? deliveryId,
    String? pathType,
    String? startLocation,
    String? endLocation,
    int? timeRemaining,
    String? estimatedTime,
    int? totalItems,
    String? assignedWorker,
    String? assignedEquipment,
    String? status,
    PickingRoute? route,
  }) {
    return PickingTask(
      deliveryId: deliveryId ?? this.deliveryId,
      pathType: pathType ?? this.pathType,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      totalItems: totalItems ?? this.totalItems,
      assignedWorker: assignedWorker ?? this.assignedWorker,
      assignedEquipment: assignedEquipment ?? this.assignedEquipment,
      status: status ?? this.status,
      route: route ?? this.route,
    );
  }
}
