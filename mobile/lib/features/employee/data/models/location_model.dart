import '../../domain/entities/location_entity.dart';

/// Data model for Location with JSON/DB serialization.
class LocationModel extends LocationEntity {
  const LocationModel({
    required super.id,
    required super.warehouseId,
    required super.area,
    super.rack,
    super.slot,
    required super.locationCode,
    super.isStorage,
  });

  /// Create from database row
  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['location_id'] as int,
      warehouseId: map['warehouse_id'] as int,
      area: map['area'] as String? ?? '',
      rack: map['rack'] as String?,
      slot: map['slot'] as String?,
      locationCode: map['location_code'] as String,
      isStorage: (map['is_storage'] as int?) == 1,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'location_id': id,
      'warehouse_id': warehouseId,
      'area': area,
      'rack': rack,
      'slot': slot,
      'location_code': locationCode,
      'is_storage': isStorage ? 1 : 0,
    };
  }

  /// Create from JSON
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['location_id'] as int,
      warehouseId: json['warehouse_id'] as int,
      area: json['area'] as String? ?? '',
      rack: json['rack'] as String?,
      slot: json['slot'] as String?,
      locationCode: json['location_code'] as String,
      isStorage: json['is_storage'] == true || json['is_storage'] == 1,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => toMap();

  /// Create from entity
  factory LocationModel.fromEntity(LocationEntity entity) {
    return LocationModel(
      id: entity.id,
      warehouseId: entity.warehouseId,
      area: entity.area,
      rack: entity.rack,
      slot: entity.slot,
      locationCode: entity.locationCode,
      isStorage: entity.isStorage,
    );
  }
}
