import 'package:equatable/equatable.dart';

/// Domain entity representing a warehouse location.
class LocationEntity extends Equatable {
  final int id;
  final int warehouseId;
  final String area;
  final String? rack;
  final String? slot;
  final String locationCode;
  final bool isStorage;

  const LocationEntity({
    required this.id,
    required this.warehouseId,
    required this.area,
    this.rack,
    this.slot,
    required this.locationCode,
    this.isStorage = true,
  });

  /// Full display name for the location
  String get displayName {
    final parts = <String>[area];
    if (rack != null) parts.add('Rack $rack');
    if (slot != null) parts.add('Slot $slot');
    return parts.join(' - ');
  }

  LocationEntity copyWith({
    int? id,
    int? warehouseId,
    String? area,
    String? rack,
    String? slot,
    String? locationCode,
    bool? isStorage,
  }) {
    return LocationEntity(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      area: area ?? this.area,
      rack: rack ?? this.rack,
      slot: slot ?? this.slot,
      locationCode: locationCode ?? this.locationCode,
      isStorage: isStorage ?? this.isStorage,
    );
  }

  @override
  List<Object?> get props => [
    id,
    warehouseId,
    area,
    rack,
    slot,
    locationCode,
    isStorage,
  ];
}
