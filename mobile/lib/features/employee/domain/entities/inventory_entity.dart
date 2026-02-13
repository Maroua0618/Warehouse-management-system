import 'package:equatable/equatable.dart';

/// Domain entity representing an inventory item.
class InventoryEntity extends Equatable {
  final int id;
  final String sku;
  final String productName;
  final String? lotNumber;
  final int quantityOnHand;
  final String unitOfMeasure;
  final int? locationId;
  final String? locationCode;
  final DateTime lastUpdated;

  const InventoryEntity({
    required this.id,
    required this.sku,
    required this.productName,
    this.lotNumber,
    required this.quantityOnHand,
    required this.unitOfMeasure,
    this.locationId,
    this.locationCode,
    required this.lastUpdated,
  });

  /// Check if stock is low (below 10 units)
  bool get isLowStock => quantityOnHand < 10;

  /// Check if out of stock
  bool get isOutOfStock => quantityOnHand <= 0;

  /// Display quantity with unit
  String get quantityDisplay => '$quantityOnHand $unitOfMeasure';

  InventoryEntity copyWith({
    int? id,
    String? sku,
    String? productName,
    String? lotNumber,
    int? quantityOnHand,
    String? unitOfMeasure,
    int? locationId,
    String? locationCode,
    DateTime? lastUpdated,
  }) {
    return InventoryEntity(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      productName: productName ?? this.productName,
      lotNumber: lotNumber ?? this.lotNumber,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      locationId: locationId ?? this.locationId,
      locationCode: locationCode ?? this.locationCode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
    id,
    sku,
    productName,
    lotNumber,
    quantityOnHand,
    unitOfMeasure,
    locationId,
    locationCode,
    lastUpdated,
  ];
}
