// Modèles pour Bon de préparation (Preparation Order)

class BonDePreparation {
  final String deliveryId; // Auto-incremental ID (e.g., BP-2026-001)
  final List<PreparationItem> items;
  final String status; // 'pending', 'approved', 'dispatched', 'overridden'
  final DateTime createdAt;
  final String? assignedEmployeeId;
  final String? assignedEmployeeName;
  final String? assignedEquipmentId;
  final String? assignedEquipmentName;
  final DateTime? dispatchedAt;

  BonDePreparation({
    required this.deliveryId,
    required this.items,
    required this.status,
    required this.createdAt,
    this.assignedEmployeeId,
    this.assignedEmployeeName,
    this.assignedEquipmentId,
    this.assignedEquipmentName,
    this.dispatchedAt,
  });

  int get totalUnits {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  int get totalProducts {
    return items.length;
  }

  factory BonDePreparation.fromJson(Map<String, dynamic> json) {
    return BonDePreparation(
      deliveryId: json['delivery_id'] ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => PreparationItem.fromJson(item))
              .toList() ??
          [],
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      assignedEmployeeId: json['assigned_employee_id'],
      assignedEmployeeName: json['assigned_employee_name'],
      assignedEquipmentId: json['assigned_equipment_id'],
      assignedEquipmentName: json['assigned_equipment_name'],
      dispatchedAt: json['dispatched_at'] != null
          ? DateTime.parse(json['dispatched_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delivery_id': deliveryId,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'assigned_employee_id': assignedEmployeeId,
      'assigned_employee_name': assignedEmployeeName,
      'assigned_equipment_id': assignedEquipmentId,
      'assigned_equipment_name': assignedEquipmentName,
      'dispatched_at': dispatchedAt?.toIso8601String(),
    };
  }

  BonDePreparation copyWith({
    String? deliveryId,
    List<PreparationItem>? items,
    String? status,
    DateTime? createdAt,
    String? assignedEmployeeId,
    String? assignedEmployeeName,
    String? assignedEquipmentId,
    String? assignedEquipmentName,
    DateTime? dispatchedAt,
  }) {
    return BonDePreparation(
      deliveryId: deliveryId ?? this.deliveryId,
      items: items ?? this.items,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      assignedEmployeeId: assignedEmployeeId ?? this.assignedEmployeeId,
      assignedEmployeeName: assignedEmployeeName ?? this.assignedEmployeeName,
      assignedEquipmentId: assignedEquipmentId ?? this.assignedEquipmentId,
      assignedEquipmentName:
          assignedEquipmentName ?? this.assignedEquipmentName,
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
    );
  }
}

class PreparationItem {
  final String productIdentifier; // SKU code (e.g., SKU-88291)
  final String? productName;
  final int quantity; // Quantity to be delivered
  final StorageLocation storageLocation; // Current storage location
  final String? zone; // Zone (e.g., Zone A-12)
  final String? shelf; // Shelf (e.g., Shelf 04)

  PreparationItem({
    required this.productIdentifier,
    this.productName,
    required this.quantity,
    required this.storageLocation,
    this.zone,
    this.shelf,
  });

  String get fullLocation {
    if (zone != null && shelf != null) {
      return '$zone • $shelf';
    }
    return storageLocation.toString();
  }

  factory PreparationItem.fromJson(Map<String, dynamic> json) {
    return PreparationItem(
      productIdentifier: json['product_identifier'] ?? json['sku_code'] ?? '',
      productName: json['product_name'],
      quantity: json['quantity'] ?? json['qty'] ?? 0,
      storageLocation: json['storage_location'] != null
          ? StorageLocation.fromJson(json['storage_location'])
          : StorageLocation(
              zone: json['zone'] ?? '',
              shelf: json['shelf'] ?? '',
            ),
      zone: json['zone'],
      shelf: json['shelf'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_identifier': productIdentifier,
      'product_name': productName,
      'quantity': quantity,
      'storage_location': storageLocation.toJson(),
      'zone': zone,
      'shelf': shelf,
    };
  }

  PreparationItem copyWith({
    String? productIdentifier,
    String? productName,
    int? quantity,
    StorageLocation? storageLocation,
    String? zone,
    String? shelf,
  }) {
    return PreparationItem(
      productIdentifier: productIdentifier ?? this.productIdentifier,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      storageLocation: storageLocation ?? this.storageLocation,
      zone: zone ?? this.zone,
      shelf: shelf ?? this.shelf,
    );
  }
}

class StorageLocation {
  final String zone; // Zone (e.g., "Zone Alpha", "Zone Bravo")
  final String shelf; // Shelf (e.g., "Shelf 04")
  final double? fillPercentage; // Fill percentage (e.g., 75.0 for 75%)

  StorageLocation({
    required this.zone,
    required this.shelf,
    this.fillPercentage,
  });

  @override
  String toString() {
    return '$zone • $shelf';
  }

  factory StorageLocation.fromJson(Map<String, dynamic> json) {
    return StorageLocation(
      zone: json['zone'] ?? '',
      shelf: json['shelf'] ?? '',
      fillPercentage: json['fill_percentage'] != null
          ? (json['fill_percentage'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'zone': zone, 'shelf': shelf, 'fill_percentage': fillPercentage};
  }
}

class Employee {
  final String id;
  final String name;
  final String? photoUrl;
  final int tasksActive;
  final int totalStock;

  Employee({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.tasksActive,
    required this.totalStock,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      photoUrl: json['photo_url'],
      tasksActive: json['tasks_active'] ?? 0,
      totalStock: json['total_stock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo_url': photoUrl,
      'tasks_active': tasksActive,
      'total_stock': totalStock,
    };
  }
}

class Equipment {
  final String id;
  final String name;
  final String type; // 'chariot', 'forklift', etc.
  final int batteryPercentage;
  final String status; // 'available', 'in_use', 'maintenance'

  Equipment({
    required this.id,
    required this.name,
    required this.type,
    required this.batteryPercentage,
    required this.status,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'chariot',
      batteryPercentage: json['battery_percentage'] ?? 0,
      status: json['status'] ?? 'available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'battery_percentage': batteryPercentage,
      'status': status,
    };
  }
}

class OverrideReason {
  final String id;
  final String label; // 'Erreur d'inventaire', 'Problème d'équipement', etc.
  final String value; // 'inventory_error', 'equipment_issue', etc.

  OverrideReason({required this.id, required this.label, required this.value});

  factory OverrideReason.fromJson(Map<String, dynamic> json) {
    return OverrideReason(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'label': label, 'value': value};
  }
}

class OverrideAdjustment {
  final String reason;
  final String? details;
  final List<ManualAdjustment> adjustments;
  final StorageLocation? selectedZone;

  OverrideAdjustment({
    required this.reason,
    this.details,
    required this.adjustments,
    this.selectedZone,
  });

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
      'details': details,
      'adjustments': adjustments.map((adj) => adj.toJson()).toList(),
      'selected_zone': selectedZone?.toJson(),
    };
  }
}

class ManualAdjustment {
  final String productIdentifier;
  final String? productName;
  final String? zone;
  final int quantity;

  ManualAdjustment({
    required this.productIdentifier,
    this.productName,
    this.zone,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_identifier': productIdentifier,
      'product_name': productName,
      'zone': zone,
      'quantity': quantity,
    };
  }
}

class ProductReplacement {
  final String originalSku;
  final String replacementSku;
  final String productName;
  final int stock;
  final String zone;

  ProductReplacement({
    required this.originalSku,
    required this.replacementSku,
    required this.productName,
    required this.stock,
    required this.zone,
  });

  factory ProductReplacement.fromJson(Map<String, dynamic> json) {
    return ProductReplacement(
      originalSku: json['original_sku'] ?? '',
      replacementSku: json['replacement_sku'] ?? '',
      productName: json['product_name'] ?? '',
      stock: json['stock'] ?? 0,
      zone: json['zone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original_sku': originalSku,
      'replacement_sku': replacementSku,
      'product_name': productName,
      'stock': stock,
      'zone': zone,
    };
  }
}
