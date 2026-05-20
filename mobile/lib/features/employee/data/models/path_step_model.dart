import '../../domain/entities/path_step_entity.dart';
import '../../domain/entities/validation_item_entity.dart';
import 'validation_item_model.dart';

/// Data model for PathStepEntity with JSON/DB serialization.
class PathStepModel extends PathStepEntity {
  const PathStepModel({
    required super.id,
    required super.type,
    required super.floor,
    required super.locationName,
    super.row,
    super.transit,
    super.slot,
    super.quantity,
    super.itemToPick,
    super.isCompleted,
    super.isCurrent,
  });

  factory PathStepModel.fromJson(Map<String, dynamic> json) {
    ValidationItemEntity? item;
    if (json['item_to_pick'] != null) {
      item = ValidationItemModel.fromJson(
        json['item_to_pick'] as Map<String, dynamic>,
      );
    }

    return PathStepModel(
      id: json['id'] as String,
      type: PathStepType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PathStepType.transit,
      ),
      floor: json['floor'] as String,
      locationName: json['location_name'] as String,
      row: json['row'] as String?,
      transit: json['transit'] as String?,
      slot: json['slot'] as String?,
      quantity: json['quantity'] as int?,
      itemToPick: item,
      isCompleted: json['is_completed'] == 1 || json['is_completed'] == true,
      isCurrent: json['is_current'] == 1 || json['is_current'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'floor': floor,
      'location_name': locationName,
      'row': row,
      'transit': transit,
      'slot': slot,
      'quantity': quantity,
      'item_to_pick': itemToPick != null
          ? ValidationItemModel.fromEntity(itemToPick!).toJson()
          : null,
      'is_completed': isCompleted ? 1 : 0,
      'is_current': isCurrent ? 1 : 0,
    };
  }

  factory PathStepModel.fromEntity(PathStepEntity entity) {
    return PathStepModel(
      id: entity.id,
      type: entity.type,
      floor: entity.floor,
      locationName: entity.locationName,
      row: entity.row,
      transit: entity.transit,
      slot: entity.slot,
      quantity: entity.quantity,
      itemToPick: entity.itemToPick,
      isCompleted: entity.isCompleted,
      isCurrent: entity.isCurrent,
    );
  }
}
