import 'package:equatable/equatable.dart';
import '../data/models/picking_route_models.dart';

/// Base class for all picking route states
abstract class PickingRouteState extends Equatable {
  const PickingRouteState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the route is first loaded
class PickingRouteInitial extends PickingRouteState {
  const PickingRouteInitial();
}

/// State when the route is being loaded or processed
class PickingRouteLoading extends PickingRouteState {
  const PickingRouteLoading();
}

/// State when the route has been loaded and can be edited
class PickingRouteLoaded extends PickingRouteState {
  final List<PickingLocation> sequence;
  final String totalDistance;
  final int totalItems;
  final bool isModified;

  const PickingRouteLoaded({
    required this.sequence,
    required this.totalDistance,
    required this.totalItems,
    this.isModified = false,
  });

  @override
  List<Object?> get props => [sequence, totalDistance, totalItems, isModified];

  PickingRouteLoaded copyWith({
    List<PickingLocation>? sequence,
    String? totalDistance,
    int? totalItems,
    bool? isModified,
  }) {
    return PickingRouteLoaded(
      sequence: sequence ?? this.sequence,
      totalDistance: totalDistance ?? this.totalDistance,
      totalItems: totalItems ?? this.totalItems,
      isModified: isModified ?? this.isModified,
    );
  }
}

/// State when an error occurs
class PickingRouteError extends PickingRouteState {
  final String message;

  const PickingRouteError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when the route has been successfully saved
class PickingRouteSaved extends PickingRouteState {
  final String message;

  const PickingRouteSaved(this.message);

  @override
  List<Object?> get props => [message];
}
