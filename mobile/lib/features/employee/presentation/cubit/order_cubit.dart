import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_state.dart';

/// Cubit that manages the state of the Orders feature.
///
/// Handles:
/// - Loading orders (outgoing/incoming)
/// - Switching between order types
/// - Refreshing orders
/// - Error handling
class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _orderRepository;

  /// Current employee ID for filtering orders
  final String? employeeId;

  OrderCubit({required OrderRepository orderRepository, this.employeeId})
    : _orderRepository = orderRepository,
      super(const OrderInitial());

  /// Loads orders of the specified type.
  ///
  /// [type] should be either 'outgoing' or 'incoming'.
  Future<void> loadOrders(String type) async {
    // Emit loading state
    emit(const OrderLoading());

    // Call repository to fetch orders
    final result = await _orderRepository.getOrders(
      type: type,
      employeeId: employeeId,
    );

    // Handle result using fold (Either pattern)
    result.fold(
      // On failure: emit error state
      (failure) => emit(OrderError(message: failure.message)),
      // On success: emit loaded state
      (orders) => emit(
        OrderLoaded(orders: orders, currentType: type, isFromCache: false),
      ),
    );
  }

  /// Switches to a different order type.
  /// Convenience method that calls loadOrders.
  Future<void> switchOrderType(String type) async {
    await loadOrders(type);
  }

  /// Refreshes the current orders from the remote server.
  /// Shows a refreshing indicator while keeping current data visible.
  Future<void> refreshOrders() async {
    final currentState = state;

    // Get current type from state, default to 'outgoing'
    String currentType = 'outgoing';
    List<dynamic> currentOrders = [];

    if (currentState is OrderLoaded) {
      currentType = currentState.currentType;
      currentOrders = currentState.orders;

      // Emit refreshing state with current data
      emit(
        OrderRefreshing(
          currentOrders: currentState.orders,
          currentType: currentType,
        ),
      );
    } else {
      emit(const OrderLoading());
    }

    // Call repository to refresh orders
    final result = await _orderRepository.refreshOrders(
      type: currentType,
      employeeId: employeeId,
    );

    result.fold(
      (failure) {
        // On failure: show error but keep previous data if available
        if (currentOrders.isNotEmpty) {
          emit(
            OrderError(
              message: failure.message,
              previousOrders: currentOrders.cast(),
              previousType: currentType,
            ),
          );
        } else {
          emit(OrderError(message: failure.message));
        }
      },
      (orders) => emit(
        OrderLoaded(
          orders: orders,
          currentType: currentType,
          isFromCache: false,
        ),
      ),
    );
  }

  /// Updates the status of a specific order.
  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    final currentState = state;

    if (currentState is! OrderLoaded) return;

    final result = await _orderRepository.updateOrderStatus(
      orderId: orderId,
      newStatus: newStatus,
    );

    result.fold(
      (failure) => emit(
        OrderError(
          message: failure.message,
          previousOrders: currentState.orders,
          previousType: currentState.currentType,
        ),
      ),
      (updatedOrder) {
        // Update the order in the current list
        final updatedOrders = currentState.orders.map((order) {
          return order.id == updatedOrder.id ? updatedOrder : order;
        }).toList();

        emit(currentState.copyWith(orders: updatedOrders));
      },
    );
  }
}
