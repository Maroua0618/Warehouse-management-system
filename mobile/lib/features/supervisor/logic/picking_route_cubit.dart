import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/picking_route_models.dart';
import 'picking_route_state.dart';

/// Cubit to manage the picking route override functionality
class PickingRouteCubit extends Cubit<PickingRouteState> {
  final PickingTask originalTask;

  PickingRouteCubit({required this.originalTask})
    : super(const PickingRouteInitial()) {
    _loadRoute();
  }

  /// Load the initial route from the picking task
  void _loadRoute() {
    emit(const PickingRouteLoading());

    final route =
        originalTask.route ??
        PickingRoute(
          deliveryId: originalTask.deliveryId,
          sequence: [],
          totalDistance: '0m',
          totalItems: 0,
        );

    emit(
      PickingRouteLoaded(
        sequence: List.from(route.sequence),
        totalDistance: route.totalDistance,
        totalItems: route.totalItems,
        isModified: false,
      ),
    );
  }

  /// Add a new location to the sequence
  void addLocation(PickingLocation location) {
    final currentState = state;
    if (currentState is PickingRouteLoaded) {
      final newSequence = List<PickingLocation>.from(currentState.sequence)
        ..add(location);

      emit(
        currentState.copyWith(
          sequence: newSequence,
          totalItems: newSequence.length,
          isModified: true,
        ),
      );
    }
  }

  /// Update an existing location in the sequence
  void updateLocation(int index, PickingLocation location) {
    final currentState = state;
    if (currentState is PickingRouteLoaded) {
      final newSequence = List<PickingLocation>.from(currentState.sequence);
      if (index >= 0 && index < newSequence.length) {
        newSequence[index] = location;

        emit(currentState.copyWith(sequence: newSequence, isModified: true));
      }
    }
  }

  /// Delete a location from the sequence
  void deleteLocation(int index) {
    final currentState = state;
    if (currentState is PickingRouteLoaded) {
      // Don't allow deletion if there are less than 3 locations
      if (currentState.sequence.length <= 2) {
        emit(
          const PickingRouteError(
            'La séquence doit contenir au moins 2 emplacements',
          ),
        );
        // Restore the loaded state
        emit(currentState);
        return;
      }

      final newSequence = List<PickingLocation>.from(currentState.sequence);
      if (index >= 0 && index < newSequence.length) {
        newSequence.removeAt(index);

        emit(
          currentState.copyWith(
            sequence: newSequence,
            totalItems: newSequence.length,
            isModified: true,
          ),
        );
      }
    }
  }

  /// Move a location to a different position in the sequence
  void moveLocation(int fromIndex, int toIndex) {
    final currentState = state;
    if (currentState is PickingRouteLoaded) {
      final newSequence = List<PickingLocation>.from(currentState.sequence);
      if (fromIndex >= 0 &&
          fromIndex < newSequence.length &&
          toIndex >= 0 &&
          toIndex < newSequence.length) {
        final location = newSequence.removeAt(fromIndex);
        newSequence.insert(toIndex, location);

        emit(currentState.copyWith(sequence: newSequence, isModified: true));
      }
    }
  }

  /// Reset the route to the original AI-optimized version
  void resetToAIOptimization() {
    _loadRoute();
  }

  /// Save the modified route (TODO: implement Supabase integration)
  Future<void> saveRoute() async {
    final currentState = state;
    if (currentState is PickingRouteLoaded) {
      emit(const PickingRouteLoading());

      try {
        // TODO: Implement Supabase save
        // await _pickingRouteRepository.saveRoute(...)

        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 500));

        emit(const PickingRouteSaved('Itinéraire manuel confirmé avec succès'));

        // Return to loaded state
        emit(currentState.copyWith(isModified: false));
      } catch (e) {
        emit(
          PickingRouteError('Erreur lors de la sauvegarde: ${e.toString()}'),
        );
        emit(currentState);
      }
    }
  }

  /// Update the total distance (can be calculated or manually entered)
  void updateTotalDistance(String distance) {
    final currentState = state;
    if (currentState is PickingRouteLoaded) {
      emit(currentState.copyWith(totalDistance: distance, isModified: true));
    }
  }
}
