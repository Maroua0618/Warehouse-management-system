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
  final String? backendId; // UUID from backend API
  final String? orderNumber;
  final CommandType type;
  final CommandStatus status;
  final String? location;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime? scheduledTime;
  final List<CommandItemEntity> items;
  final int? itemCount; // From backend API item_count (for list view)

  const CommandEntity({
    required this.id,
    this.backendId,
    this.orderNumber,
    required this.type,
    required this.status,
    this.location,
    this.createdBy,
    required this.createdAt,
    this.scheduledTime,
    this.items = const [],
    this.itemCount,
  });

  /// Get the ID to use for backend API calls
  String get apiId => backendId ?? id.toString();

  /// Get formatted order ID in format ORD-YYYY-XXXX
  String get displayOrderId {
    if (orderNumber != null) return orderNumber!;
    final year = createdAt.year;
    return 'ORD-$year-${id.toString().padLeft(4, '0')}';
  }

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

  int get totalItems => itemCount ?? items.length;
  int get completedItems => items.where((i) => i.status == 'COMPLETED').length;
  int get progressPercentage {
    final total = totalItems;
    if (total == 0) return 0;
    return ((completedItems / total) * 100).round();
  }

  CommandEntity copyWith({
    int? id,
    String? backendId,
    String? orderNumber,
    CommandType? type,
    CommandStatus? status,
    String? location,
    int? createdBy,
    DateTime? createdAt,
    DateTime? scheduledTime,
    int? itemCount,
    List<CommandItemEntity>? items,
  }) {
    return CommandEntity(
      id: id ?? this.id,
      backendId: backendId ?? this.backendId,
      orderNumber: orderNumber ?? this.orderNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      location: location ?? this.location,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      itemCount: itemCount ?? this.itemCount,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
    id,
    backendId,
    orderNumber,
    type,
    status,
    location,
    createdBy,
    createdAt,
    scheduledTime,
    itemCount,
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
  final String? location;
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
    this.location,
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
    String? location,
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
      location: location ?? this.location,
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
    location,
    status,
    validatedAt,
    validatedBy,
  ];
}
