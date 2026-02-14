// Models for Picking Route (Itinéraire de Prélèvement)

/// Represents an item request for picking route optimization
class PickingItemRequest {
  final String skuId;
  final String locationId;
  final int quantity;

  PickingItemRequest({
    required this.skuId,
    required this.locationId,
    required this.quantity,
  });

  factory PickingItemRequest.fromJson(Map<String, dynamic> json) {
    return PickingItemRequest(
      skuId: json['sku_id'] as String,
      locationId: json['location_id'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'sku_id': skuId, 'location_id': locationId, 'quantity': quantity};
  }
}

/// Represents the result of route optimization
class PickingRouteOptimization {
  final String routePlanId;
  final List<Map<String, dynamic>> optimizedSequence;
  final double estimatedTimeSeconds;
  final double estimatedDistanceMeters;
  final Map<String, dynamic>? aiRecommendation;

  PickingRouteOptimization({
    required this.routePlanId,
    required this.optimizedSequence,
    required this.estimatedTimeSeconds,
    required this.estimatedDistanceMeters,
    this.aiRecommendation,
  });

  factory PickingRouteOptimization.fromJson(Map<String, dynamic> json) {
    return PickingRouteOptimization(
      routePlanId: json['route_plan_id'] as String,
      optimizedSequence: (json['optimized_sequence'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      estimatedTimeSeconds: (json['estimated_time_seconds'] as num).toDouble(),
      estimatedDistanceMeters: (json['estimated_distance_meters'] as num)
          .toDouble(),
      aiRecommendation: json['ai_recommendation'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route_plan_id': routePlanId,
      'optimized_sequence': optimizedSequence,
      'estimated_time_seconds': estimatedTimeSeconds,
      'estimated_distance_meters': estimatedDistanceMeters,
      if (aiRecommendation != null) 'ai_recommendation': aiRecommendation,
    };
  }
}

/// Represents a picking step in the sequence
class PickingStep {
  final int stepNumber;
  final String sku;
  final String location;

  PickingStep({
    required this.stepNumber,
    required this.sku,
    required this.location,
  });

  String get formattedStep => '$sku → $location';
}

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

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      avatarUrl: json['avatar_url'],
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'avatar_url': avatarUrl,
      'is_available': isAvailable,
    };
  }
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

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] ?? '',
      name: json['name'] ?? json['code'] ?? '',
      type: json['type'] ?? '',
      isAvailable: json['is_available'] ?? json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'type': type, 'is_available': isAvailable};
  }
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
  final List<PickingStep> steps;
  final String destinationRack;
  final String optimizedDistance;
  final int optimizedStops;

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
    this.steps = const [],
    this.destinationRack = '',
    this.optimizedDistance = '0m',
    this.optimizedStops = 0,
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
    List<PickingStep>? steps,
    String? destinationRack,
    String? optimizedDistance,
    int? optimizedStops,
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
      steps: steps ?? this.steps,
      destinationRack: destinationRack ?? this.destinationRack,
      optimizedDistance: optimizedDistance ?? this.optimizedDistance,
      optimizedStops: optimizedStops ?? this.optimizedStops,
    );
  }

  factory PickingTask.fromJson(Map<String, dynamic> json) {
    return PickingTask(
      deliveryId: json['delivery_id']?.toString() ?? '',
      pathType: json['path_type'] ?? '',
      startLocation: json['start_location'] ?? '',
      endLocation: json['end_location'] ?? '',
      timeRemaining: json['time_remaining'] ?? 0,
      estimatedTime: json['estimated_time'] ?? '0 min',
      totalItems: json['total_items'] ?? 0,
      assignedWorker: json['assigned_worker'],
      assignedEquipment: json['assigned_equipment'],
      status: json['status'] ?? 'pending',
      destinationRack: json['destination_rack'] ?? '',
      optimizedDistance: json['optimized_distance'] ?? '0m',
      optimizedStops: json['optimized_stops'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delivery_id': deliveryId,
      'path_type': pathType,
      'start_location': startLocation,
      'end_location': endLocation,
      'time_remaining': timeRemaining,
      'estimated_time': estimatedTime,
      'total_items': totalItems,
      'assigned_worker': assignedWorker,
      'assigned_equipment': assignedEquipment,
      'status': status,
      'destination_rack': destinationRack,
      'optimized_distance': optimizedDistance,
      'optimized_stops': optimizedStops,
    };
  }
}
