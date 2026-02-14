import 'package:equatable/equatable.dart';

/// Status of a command in the system.
enum CommandStatus { pending, inProgress, completed, cancelled }

/// Type of command/order.
enum CommandType {
  receipt, // Ingoing/reception
  transfer, // Internal transfer
  storageAssignment, // Storage placement
  picking, // Order picking
  delivery, // Outgoing delivery
}

/// Domain entity representing a command (order) in the warehouse system.
class CommandEntity extends Equatable {
  final int id;
  final String? orderNumber;
  final CommandType type;
  final CommandStatus status;
  final String? location;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime? scheduledTime;
  final List<CommandItemEntity> items;

  const CommandEntity({
    required this.id,
    this.orderNumber,
    required this.type,
    required this.status,
    this.location,
    this.createdBy,
    required this.createdAt,
    this.scheduledTime,
    this.items = const [],
  });

  /// Get formatted order ID
  String get displayOrderId =>
      orderNumber ?? 'ORD-${id.toString().padLeft(4, '0')}';

  /// Get display location or default
  String get displayLocation => location ?? 'N/A';

  /// Check if order is validated
  bool get isValidated => status == CommandStatus.completed;

  /// Get French status string
  String get frenchStatus {
    switch (status) {
      case CommandStatus.pending:
        return 'EN ATTENTE';
      case CommandStatus.inProgress:
        return 'EN COURS';
      case CommandStatus.completed:
        return 'VALIDÉ';
      case CommandStatus.cancelled:
        return 'ANNULÉ';
    }
  }

  /// Get formatted time from scheduledTime or createdAt
  String get displayTime {
    final time = scheduledTime ?? createdAt;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Get command type display name
  String get typeDisplayName {
    switch (type) {
      case CommandType.receipt:
        return 'Receipt';
      case CommandType.transfer:
        return 'Transfer';
      case CommandType.storageAssignment:
        return 'Storage Assignment';
      case CommandType.picking:
        return 'Picking';
      case CommandType.delivery:
        return 'Delivery';
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case CommandStatus.pending:
        return 'Pending';
      case CommandStatus.inProgress:
        return 'In Progress';
      case CommandStatus.completed:
        return 'Completed';
      case CommandStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get totalItems => items.length;
  int get completedItems => items.where((i) => i.status == 'COMPLETED').length;
  int get progressPercentage {
    if (items.isEmpty) return 0;
    return ((completedItems / totalItems) * 100).round();
  }

  CommandEntity copyWith({
    int? id,
    String? orderNumber,
    CommandType? type,
    CommandStatus? status,
    String? location,
    int? createdBy,
    DateTime? createdAt,
    DateTime? scheduledTime,
    List<CommandItemEntity>? items,
  }) {
    return CommandEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      location: location ?? this.location,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    type,
    status,
    location,
    createdBy,
    createdAt,
    scheduledTime,
    items,
  ];
}

/// Entity representing an item within a command.
class CommandItemEntity extends Equatable {
  final int id;
  final int commandId;
  final String sku;
  final String? productName;
  final int quantity;
  final String? lotNumber;
  final int? locationExpectedId;
  final String status;
  final DateTime? validatedAt;
  final int? validatedBy;

  const CommandItemEntity({
    required this.id,
    required this.commandId,
    required this.sku,
    this.productName,
    required this.quantity,
    this.lotNumber,
    this.locationExpectedId,
    required this.status,
    this.validatedAt,
    this.validatedBy,
  });

  bool get isValidated => status == 'COMPLETED';
  bool get isPending => status == 'PENDING';
  bool get hasDiscrepancy => status == 'DISCREPANCY';

  CommandItemEntity copyWith({
    int? id,
    int? commandId,
    String? sku,
    String? productName,
    int? quantity,
    String? lotNumber,
    int? locationExpectedId,
    String? status,
    DateTime? validatedAt,
    int? validatedBy,
  }) {
    return CommandItemEntity(
      id: id ?? this.id,
      commandId: commandId ?? this.commandId,
      sku: sku ?? this.sku,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      lotNumber: lotNumber ?? this.lotNumber,
      locationExpectedId: locationExpectedId ?? this.locationExpectedId,
      status: status ?? this.status,
      validatedAt: validatedAt ?? this.validatedAt,
      validatedBy: validatedBy ?? this.validatedBy,
    );
  }

  @override
  List<Object?> get props => [
    id,
    commandId,
    sku,
    productName,
    quantity,
    lotNumber,
    locationExpectedId,
    status,
    validatedAt,
    validatedBy,
  ];
}
