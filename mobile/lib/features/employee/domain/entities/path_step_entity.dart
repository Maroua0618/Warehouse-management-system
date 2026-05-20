import 'package:equatable/equatable.dart';
import 'validation_item_entity.dart';

/// Types of path steps in the transport path.
enum PathStepType {
  pickup, // Starting pickup location
  transit, // Transit node where items may need to be picked
  dropoff, // Final drop-off location
}

/// Represents a step in the transport path during order validation.
class PathStepEntity extends Equatable {
  final String id;
  final PathStepType type;
  final String floor;
  final String locationName;
  final String? row;
  final String? transit;
  final String? slot;
  final int? quantity;
  final ValidationItemEntity? itemToPick;
  final bool isCompleted;
  final bool isCurrent;

  const PathStepEntity({
    required this.id,
    required this.type,
    required this.floor,
    required this.locationName,
    this.row,
    this.transit,
    this.slot,
    this.quantity,
    this.itemToPick,
    this.isCompleted = false,
    this.isCurrent = false,
  });

  PathStepEntity copyWith({
    String? id,
    PathStepType? type,
    String? floor,
    String? locationName,
    String? row,
    String? transit,
    String? slot,
    int? quantity,
    ValidationItemEntity? itemToPick,
    bool? isCompleted,
    bool? isCurrent,
  }) {
    return PathStepEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      floor: floor ?? this.floor,
      locationName: locationName ?? this.locationName,
      row: row ?? this.row,
      transit: transit ?? this.transit,
      slot: slot ?? this.slot,
      quantity: quantity ?? this.quantity,
      itemToPick: itemToPick ?? this.itemToPick,
      isCompleted: isCompleted ?? this.isCompleted,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  String get typeLabel {
    switch (type) {
      case PathStepType.pickup:
        return 'PICKUP LOCATION';
      case PathStepType.transit:
        return 'TRANSIT NODE';
      case PathStepType.dropoff:
        return 'FINAL DROPOFF';
    }
  }

  @override
  List<Object?> get props => [
    id,
    type,
    floor,
    locationName,
    row,
    transit,
    slot,
    quantity,
    itemToPick,
    isCompleted,
    isCurrent,
  ];
}
