import '../../domain/entities/inventory_entity.dart';

/// Data model for Inventory with JSON/DB serialization.
class InventoryModel extends InventoryEntity {
  const InventoryModel({
    required super.id,
    required super.sku,
    required super.productName,
    super.lotNumber,
    required super.quantityOnHand,
    required super.unitOfMeasure,
    super.locationId,
    super.locationCode,
    required super.lastUpdated,
  });

  /// Create from database row
  factory InventoryModel.fromMap(Map<String, dynamic> map) {
    return InventoryModel(
      id: map['item_id'] as int,
      sku: map['sku'] as String,
      productName: map['product_name'] as String,
      lotNumber: map['lot_number'] as String?,
      quantityOnHand: map['quantity_on_hand'] as int,
      unitOfMeasure: map['unit_of_measure'] as String? ?? 'pcs',
      locationId: map['location_id'] as int?,
      locationCode: map['location_code'] as String?,
      lastUpdated: DateTime.parse(map['last_updated'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'item_id': id,
      'sku': sku,
      'product_name': productName,
      'lot_number': lotNumber,
      'quantity_on_hand': quantityOnHand,
      'unit_of_measure': unitOfMeasure,
      'location_id': locationId,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  /// Create from JSON
  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['item_id'] as int,
      sku: json['sku'] as String,
      productName: json['product_name'] as String,
      lotNumber: json['lot_number'] as String?,
      quantityOnHand: json['quantity_on_hand'] as int,
      unitOfMeasure: json['unit_of_measure'] as String? ?? 'pcs',
      locationId: json['location_id'] as int?,
      locationCode: json['location_code'] as String?,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => toMap();

  /// Create from entity
  factory InventoryModel.fromEntity(InventoryEntity entity) {
    return InventoryModel(
      id: entity.id,
      sku: entity.sku,
      productName: entity.productName,
      lotNumber: entity.lotNumber,
      quantityOnHand: entity.quantityOnHand,
      unitOfMeasure: entity.unitOfMeasure,
      locationId: entity.locationId,
      locationCode: entity.locationCode,
      lastUpdated: entity.lastUpdated,
    );
  }
}
