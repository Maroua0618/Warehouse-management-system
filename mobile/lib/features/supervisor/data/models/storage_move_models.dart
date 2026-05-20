// Enums based on database schema
enum OperationType {
  PICKING,
  COMMAND,
  RECEIPT,
  STORAGE,
  REPLENISHMENT,
  INVENTORY;

  String toJson() => name;
  static OperationType fromJson(String value) =>
      OperationType.values.firstWhere((e) => e.name == value);
}

enum TaskStatus {
  PENDING,
  IN_PROGRESS,
  COMPLETED,
  CANCELLED;

  String toJson() => name;
  static TaskStatus fromJson(String value) =>
      TaskStatus.values.firstWhere((e) => e.name == value);
}

enum LocationType {
  STORAGE,
  PICKING,
  RECEIVING,
  DISPATCH;

  String toJson() => name;
  static LocationType fromJson(String value) =>
      LocationType.values.firstWhere((e) => e.name == value);
}

enum PriorityLevel {
  LOW,
  MEDIUM,
  HIGH;

  String toJson() => name;
  static PriorityLevel fromJson(String value) =>
      PriorityLevel.values.firstWhere((e) => e.name == value);
}

enum RecommendationType {
  STORAGE_LOCATION,
  ROUTE_OPTIMIZATION,
  TASK_PRIORITY,
  LOAD_BALANCING;

  String toJson() => name;
  static RecommendationType fromJson(String value) =>
      RecommendationType.values.firstWhere((e) => e.name == value);
}

enum OverrideStatus {
  PENDING,
  APPROVED,
  REJECTED;

  String toJson() => name;
  static OverrideStatus fromJson(String value) =>
      OverrideStatus.values.firstWhere((e) => e.name == value);
}

// SKU Model
class SKU {
  final String id;
  final String skuCode;
  final String name;
  final double weightKg;

  SKU({
    required this.id,
    required this.skuCode,
    required this.name,
    required this.weightKg,
  });

  factory SKU.fromJson(Map<String, dynamic> json) {
    return SKU(
      id: json['id'] as String,
      skuCode: json['sku_code'] as String,
      name: json['name'] as String,
      weightKg: (json['weight_kg'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'sku_code': skuCode, 'name': name, 'weight_kg': weightKg};
  }
}

// Location Model
class Location {
  final String id;
  final String code;
  final LocationType type;
  final bool isActive;
  final String? floorId;
  final StorageLocationDetails? storageDetails;

  Location({
    required this.id,
    required this.code,
    required this.type,
    required this.isActive,
    this.floorId,
    this.storageDetails,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as String,
      code: json['code'] as String,
      type: LocationType.fromJson(json['type'] as String),
      isActive: json['is_active'] as bool,
      floorId: json['floor_id'] as String?,
      storageDetails: json['storage_details'] != null
          ? StorageLocationDetails.fromJson(
              json['storage_details'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'type': type.toJson(),
      'is_active': isActive,
      'floor_id': floorId,
      'storage_details': storageDetails?.toJson(),
    };
  }
}

// Storage Location Details
class StorageLocationDetails {
  final int level;
  final String slotCode;
  final double areaM2;
  final bool isAvailable;

  StorageLocationDetails({
    required this.level,
    required this.slotCode,
    required this.areaM2,
    required this.isAvailable,
  });

  factory StorageLocationDetails.fromJson(Map<String, dynamic> json) {
    return StorageLocationDetails(
      level: json['level'] as int,
      slotCode: json['slot_code'] as String,
      areaM2: (json['area_m2'] as num).toDouble(),
      isAvailable: json['is_available'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'slot_code': slotCode,
      'area_m2': areaM2,
      'is_available': isAvailable,
    };
  }
}

// Employee Model
class Employee {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String? currentZone;
  final bool isAvailable;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.currentZone,
    this.isAvailable = true,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      currentZone: json['current_zone'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'current_zone': currentZone,
      'is_available': isAvailable,
    };
  }
}

// Storage Move Model
class StorageMove {
  final String id;
  final String productId;
  final SKU? sku;
  final String sourceLocationId;
  final Location? sourceLocation;
  final String destinationLocationId;
  final Location? destinationLocation;
  final int quantity;
  final PriorityLevel priority;
  final TaskStatus status;
  final String? assignedToUserId;
  final Employee? assignedEmployee;
  final String? chariotId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool validated;
  final String? orderId;
  final AIRecommendation? aiRecommendation;
  final OverrideDecision? overrideDecision;

  StorageMove({
    required this.id,
    required this.productId,
    this.sku,
    required this.sourceLocationId,
    this.sourceLocation,
    required this.destinationLocationId,
    this.destinationLocation,
    required this.quantity,
    required this.priority,
    required this.status,
    this.assignedToUserId,
    this.assignedEmployee,
    this.chariotId,
    required this.createdAt,
    this.completedAt,
    required this.validated,
    this.orderId,
    this.aiRecommendation,
    this.overrideDecision,
  });

  factory StorageMove.fromJson(Map<String, dynamic> json) {
    return StorageMove(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      sku: json['sku'] != null
          ? SKU.fromJson(json['sku'] as Map<String, dynamic>)
          : null,
      sourceLocationId: json['source_location_id'] as String,
      sourceLocation: json['source_location'] != null
          ? Location.fromJson(json['source_location'] as Map<String, dynamic>)
          : null,
      destinationLocationId: json['destination_location_id'] as String,
      destinationLocation: json['destination_location'] != null
          ? Location.fromJson(
              json['destination_location'] as Map<String, dynamic>,
            )
          : null,
      quantity: json['quantity'] as int,
      priority: PriorityLevel.fromJson(json['priority'] as String),
      status: TaskStatus.fromJson(json['status'] as String),
      assignedToUserId: json['assigned_to_user_id'] as String?,
      assignedEmployee: json['assigned_employee'] != null
          ? Employee.fromJson(json['assigned_employee'] as Map<String, dynamic>)
          : null,
      chariotId: json['chariot_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      validated: json['validated'] as bool,
      orderId: json['order_id'] as String?,
      aiRecommendation: json['ai_recommendation'] != null
          ? AIRecommendation.fromJson(
              json['ai_recommendation'] as Map<String, dynamic>,
            )
          : null,
      overrideDecision: json['override_decision'] != null
          ? OverrideDecision.fromJson(
              json['override_decision'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'sku': sku?.toJson(),
      'source_location_id': sourceLocationId,
      'source_location': sourceLocation?.toJson(),
      'destination_location_id': destinationLocationId,
      'destination_location': destinationLocation?.toJson(),
      'quantity': quantity,
      'priority': priority.toJson(),
      'status': status.toJson(),
      'assigned_to_user_id': assignedToUserId,
      'assigned_employee': assignedEmployee?.toJson(),
      'chariot_id': chariotId,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'validated': validated,
      'order_id': orderId,
      'ai_recommendation': aiRecommendation?.toJson(),
      'override_decision': overrideDecision?.toJson(),
    };
  }

  StorageMove copyWith({
    String? id,
    String? productId,
    SKU? sku,
    String? sourceLocationId,
    Location? sourceLocation,
    String? destinationLocationId,
    Location? destinationLocation,
    int? quantity,
    PriorityLevel? priority,
    TaskStatus? status,
    String? assignedToUserId,
    Employee? assignedEmployee,
    String? chariotId,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? validated,
    String? orderId,
    AIRecommendation? aiRecommendation,
    OverrideDecision? overrideDecision,
  }) {
    return StorageMove(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      sku: sku ?? this.sku,
      sourceLocationId: sourceLocationId ?? this.sourceLocationId,
      sourceLocation: sourceLocation ?? this.sourceLocation,
      destinationLocationId:
          destinationLocationId ?? this.destinationLocationId,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      quantity: quantity ?? this.quantity,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      assignedEmployee: assignedEmployee ?? this.assignedEmployee,
      chariotId: chariotId ?? this.chariotId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      validated: validated ?? this.validated,
      orderId: orderId ?? this.orderId,
      aiRecommendation: aiRecommendation ?? this.aiRecommendation,
      overrideDecision: overrideDecision ?? this.overrideDecision,
    );
  }
}

// AI Recommendation Model
class AIRecommendation {
  final String id;
  final RecommendationType type;
  final Map<String, dynamic> payloadJson;
  final DateTime createdAt;

  AIRecommendation({
    required this.id,
    required this.type,
    required this.payloadJson,
    required this.createdAt,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      id: json['id'] as String,
      type: RecommendationType.fromJson(json['type'] as String),
      payloadJson: json['payload_json'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toJson(),
      'payload_json': payloadJson,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Override Decision Model
class OverrideDecision {
  final String id;
  final String recommendationId;
  final OverrideStatus status;
  final String overriddenByUserId;
  final String justification;
  final Map<String, dynamic> finalPayloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;

  OverrideDecision({
    required this.id,
    required this.recommendationId,
    required this.status,
    required this.overriddenByUserId,
    required this.justification,
    required this.finalPayloadJson,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OverrideDecision.fromJson(Map<String, dynamic> json) {
    return OverrideDecision(
      id: json['id'] as String,
      recommendationId: json['recommendation_id'] as String,
      status: OverrideStatus.fromJson(json['status'] as String),
      overriddenByUserId: json['overridden_by_user_id'] as String,
      justification: json['justification'] as String,
      finalPayloadJson: json['final_payload_json'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recommendation_id': recommendationId,
      'status': status.toJson(),
      'overridden_by_user_id': overriddenByUserId,
      'justification': justification,
      'final_payload_json': finalPayloadJson,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
