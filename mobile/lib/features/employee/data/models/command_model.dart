import '../../domain/entities/command_entity.dart';

/// Data model for Command with JSON/DB serialization.
class CommandModel extends CommandEntity {
  const CommandModel({
    required super.id,
    super.backendId,
    super.orderNumber,
    required super.type,
    required super.status,
    super.location,
    super.createdBy,
    required super.createdAt,
    super.scheduledTime,
    super.itemCount,
    super.items,
  });

  /// Parse command type from string
  static CommandType _parseType(String type) {
    switch (type.toUpperCase()) {
      case 'RECEIPT':
        return CommandType.receipt;
      case 'TRANSFER':
        return CommandType.transfer;
      case 'STORAGE_ASSIGNMENT':
        return CommandType.storageAssignment;
      case 'PICKING':
        return CommandType.picking;
      case 'DELIVERY':
        return CommandType.delivery;
      default:
        return CommandType.receipt;
    }
  }

  /// Parse command status from string
  static CommandStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return CommandStatus.pending;
      case 'IN_PROGRESS':
        return CommandStatus.inProgress;
      case 'COMPLETED':
        return CommandStatus.completed;
      case 'CANCELLED':
        return CommandStatus.cancelled;
      default:
        return CommandStatus.pending;
    }
  }

  /// Convert type to string
  static String _typeToString(CommandType type) {
    switch (type) {
      case CommandType.receipt:
        return 'RECEIPT';
      case CommandType.transfer:
        return 'TRANSFER';
      case CommandType.storageAssignment:
        return 'STORAGE_ASSIGNMENT';
      case CommandType.picking:
        return 'PICKING';
      case CommandType.delivery:
        return 'DELIVERY';
    }
  }

  /// Convert status to string
  static String _statusToString(CommandStatus status) {
    switch (status) {
      case CommandStatus.pending:
        return 'PENDING';
      case CommandStatus.inProgress:
        return 'IN_PROGRESS';
      case CommandStatus.completed:
        return 'COMPLETED';
      case CommandStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Create from simple API response (used by remote datasource)
  factory CommandModel.fromApiResponse(Map<String, dynamic> json) {
    return CommandModel(
      id: json['id'],
      orderNumber: json['orderId'],
      type: _parseType(json['type']),
      status: _parseStatus(json['status']),
      location: json['displayLocation'],
      createdAt: DateTime.parse(json['createdAt']),
      items: [], // TODO: Parse items if available in the new API
    );
  }

  /// Create from backend TaskSummary response (GET /tasks list)
  /// TaskSummary has: id (string), order_id, order_type, status, operation_type, created_at, item_count, delivery_id, storage_location
  factory CommandModel.fromTaskSummary(Map<String, dynamic> json) {
    // Parse storage location if available
    String? locationStr;
    if (json['storage_location'] != null) {
      final storageLoc = json['storage_location'] as Map<String, dynamic>;
      locationStr = storageLoc['code']?.toString();
    }

    final rawId = json['id']?.toString() ?? '0';
    return CommandModel(
      id: int.tryParse(rawId) ?? 0,
      backendId: rawId,
      orderNumber:
          json['delivery_id']?.toString() ?? json['order_id']?.toString(),
      type: _parseType(
        json['operation_type']?.toString() ??
            json['order_type']?.toString() ??
            'RECEIPT',
      ),
      status: _parseStatus(json['status']?.toString() ?? 'PENDING'),
      location: locationStr,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      itemCount: json['item_count'],
      items: [],
    );
  }

  /// Create from backend TaskDetail response (GET /tasks/{id})
  factory CommandModel.fromTaskDetail(Map<String, dynamic> json) {
    // Parse items from backend format
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final items = itemsList.map((item) {
      final itemMap = item as Map<String, dynamic>;
      final sku = itemMap['sku'] as Map<String, dynamic>?;
      final destLocation =
          itemMap['destination_location'] as Map<String, dynamic>?;
      return CommandItemModel(
        id: int.tryParse(itemMap['id']?.toString() ?? '0') ?? 0,
        commandId: int.tryParse(json['order_id']?.toString() ?? '0') ?? 0,
        sku: sku?['sku_code'] ?? 'N/A',
        productName: sku?['name'],
        quantity: itemMap['quantity'] ?? 0,
        locationExpectedId: destLocation != null
            ? int.tryParse(destLocation['id']?.toString() ?? '0')
            : null,
        location: destLocation?['code'] as String?,
        status: 'PENDING',
      );
    }).toList();

    // Build location string from storage_location if available
    String? locationStr;
    final storageLoc = json['storage_location'] as Map<String, dynamic>?;
    if (storageLoc != null) {
      locationStr = storageLoc['code'] as String?;
    }

    final rawId = json['id']?.toString() ?? '0';

    return CommandModel(
      id: int.tryParse(rawId) ?? 0,
      backendId: rawId,
      orderNumber: json['order_code'] as String?,
      type: _parseType(
        json['operation_type']?.toString() ??
            json['order_type']?.toString() ??
            'RECEIPT',
      ),
      status: _parseStatus(json['status']?.toString() ?? 'PENDING'),
      location: locationStr,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      items: items,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'command_id': id,
      'order_number': orderNumber,
      'command_type': _typeToString(type),
      'status': _statusToString(status),
      'location': location,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'scheduled_time': scheduledTime?.toIso8601String(),
    };
  }

  /// Create from database row with pre-loaded items
  factory CommandModel.fromMap(
    Map<String, dynamic> map, {
    List<CommandItemModel>? items,
  }) {
    return CommandModel(
      id: map['command_id'] as int,
      orderNumber: map['order_number'] as String?,
      type: _parseType(map['command_type'] as String),
      status: _parseStatus(map['status'] as String),
      location: map['location'] as String?,
      createdBy: map['created_by'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      scheduledTime: map['scheduled_time'] != null
          ? DateTime.parse(map['scheduled_time'] as String)
          : null,
      items: items ?? [],
    );
  }

  /// Create from JSON
  factory CommandModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>?;
    return CommandModel(
      id: json['command_id'] as int,
      orderNumber: json['order_number'] as String?,
      type: _parseType(json['command_type'] as String),
      status: _parseStatus(json['status'] as String),
      location: json['location'] as String?,
      createdBy: json['created_by'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      scheduledTime: json['scheduled_time'] != null
          ? DateTime.parse(json['scheduled_time'] as String)
          : null,
      items:
          itemsList
              ?.map(
                (item) =>
                    CommandItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final map = toMap();
    map['items'] = items.map((item) {
      if (item is CommandItemModel) {
        return item.toJson();
      }
      return CommandItemModel.fromEntity(item).toJson();
    }).toList();
    return map;
  }

  /// Create from entity
  factory CommandModel.fromEntity(CommandEntity entity) {
    return CommandModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      type: entity.type,
      status: entity.status,
      location: entity.location,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      scheduledTime: entity.scheduledTime,
      items: entity.items,
    );
  }
}

/// Data model for CommandItem with JSON/DB serialization.
class CommandItemModel extends CommandItemEntity {
  const CommandItemModel({
    required super.id,
    required super.commandId,
    required super.sku,
    super.productName,
    required super.quantity,
    super.lotNumber,
    super.locationExpectedId,
    super.location,
    required super.status,
    super.validatedAt,
    super.validatedBy,
  });

  /// Create from database row
  factory CommandItemModel.fromMap(Map<String, dynamic> map) {
    return CommandItemModel(
      id: map['command_item_id'] as int,
      commandId: map['command_id'] as int,
      sku: map['sku'] as String,
      productName: map['product_name'] as String?,
      quantity: map['quantity'] as int,
      lotNumber: map['lot_number'] as String?,
      locationExpectedId: map['location_expected_id'] as int?,
      status: map['status'] as String,
      validatedAt: map['validated_at'] != null
          ? DateTime.parse(map['validated_at'] as String)
          : null,
      validatedBy: map['validated_by'] as int?,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'command_item_id': id,
      'command_id': commandId,
      'sku': sku,
      'product_name': productName,
      'quantity': quantity,
      'lot_number': lotNumber,
      'location_expected_id': locationExpectedId,
      'status': status,
      'validated_at': validatedAt?.toIso8601String(),
      'validated_by': validatedBy,
    };
  }

  /// Create from JSON
  factory CommandItemModel.fromJson(Map<String, dynamic> json) {
    return CommandItemModel(
      id: json['command_item_id'] as int,
      commandId: json['command_id'] as int,
      sku: json['sku'] as String,
      productName: json['product_name'] as String?,
      quantity: json['quantity'] as int,
      lotNumber: json['lot_number'] as String?,
      locationExpectedId: json['location_expected_id'] as int?,
      status: json['status'] as String,
      validatedAt: json['validated_at'] != null
          ? DateTime.parse(json['validated_at'] as String)
          : null,
      validatedBy: json['validated_by'] as int?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => toMap();

  /// Create from entity
  factory CommandItemModel.fromEntity(CommandItemEntity entity) {
    return CommandItemModel(
      id: entity.id,
      commandId: entity.commandId,
      sku: entity.sku,
      productName: entity.productName,
      quantity: entity.quantity,
      lotNumber: entity.lotNumber,
      locationExpectedId: entity.locationExpectedId,
      status: entity.status,
      validatedAt: entity.validatedAt,
      validatedBy: entity.validatedBy,
    );
  }
}
