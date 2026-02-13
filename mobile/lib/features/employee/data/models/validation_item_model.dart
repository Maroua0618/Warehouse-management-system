import '../../domain/entities/validation_item_entity.dart';

/// Data model for ValidationItemEntity with JSON/DB serialization.
class ValidationItemModel extends ValidationItemEntity {
  const ValidationItemModel({
    required super.id,
    required super.sku,
    required super.name,
    required super.quantity,
    super.isValidated,
    super.slotLocation,
  });

  factory ValidationItemModel.fromJson(Map<String, dynamic> json) {
    return ValidationItemModel(
      id: json['id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      isValidated: json['is_validated'] == 1 || json['is_validated'] == true,
      slotLocation: json['slot_location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'quantity': quantity,
      'is_validated': isValidated ? 1 : 0,
      'slot_location': slotLocation,
    };
  }

  factory ValidationItemModel.fromEntity(ValidationItemEntity entity) {
    return ValidationItemModel(
      id: entity.id,
      sku: entity.sku,
      name: entity.name,
      quantity: entity.quantity,
      isValidated: entity.isValidated,
      slotLocation: entity.slotLocation,
    );
  }
}
