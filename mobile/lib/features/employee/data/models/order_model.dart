import '../../domain/entities/order_entity.dart';

/// Data model for Order that extends the domain entity.
/// Handles JSON serialization/deserialization for API communication
/// and database operations.
class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.status,
    required super.type,
    required super.location,
    required super.itemCount,
    required super.createdAt,
    super.scheduledTime,
    super.assignedTo,
    super.zone,
  });

  /// Creates an OrderModel from API JSON response.
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      location: json['location'] as String,
      itemCount: json['item_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      scheduledTime: json['scheduled_time'] != null
          ? DateTime.parse(json['scheduled_time'] as String)
          : null,
      assignedTo: json['assigned_to'] as String?,
      zone: json['zone'] as String?,
    );
  }

  /// Converts OrderModel to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status,
      'type': type,
      'location': location,
      'item_count': itemCount,
      'created_at': createdAt.toIso8601String(),
      'scheduled_time': scheduledTime?.toIso8601String(),
      'assigned_to': assignedTo,
      'zone': zone,
    };
  }

  /// Creates OrderModel from local database map.
  factory OrderModel.fromDatabase(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      orderNumber: map['order_number'] as String,
      status: map['status'] as String,
      type: map['type'] as String,
      location: map['location'] as String,
      itemCount: map['item_count'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      scheduledTime: map['scheduled_time'] != null
          ? DateTime.parse(map['scheduled_time'] as String)
          : null,
      assignedTo: map['assigned_to'] as String?,
      zone: map['zone'] as String?,
    );
  }

  /// Converts OrderModel to database map for local storage.
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status,
      'type': type,
      'location': location,
      'item_count': itemCount,
      'created_at': createdAt.toIso8601String(),
      'scheduled_time': scheduledTime?.toIso8601String(),
      'assigned_to': assignedTo,
      'zone': zone,
      'cached_at': DateTime.now().toIso8601String(),
    };
  }

  /// Creates a copy with updated fields.
  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? status,
    String? type,
    String? location,
    int? itemCount,
    DateTime? createdAt,
    DateTime? scheduledTime,
    String? assignedTo,
    String? zone,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      type: type ?? this.type,
      location: location ?? this.location,
      itemCount: itemCount ?? this.itemCount,
      createdAt: createdAt ?? this.createdAt,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      assignedTo: assignedTo ?? this.assignedTo,
      zone: zone ?? this.zone,
    );
  }
}
