import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order_entity.dart';
import 'order_state.dart';

/// Mock cubit for testing the UI with static data.
/// This bypasses the repository and database to allow UI testing.
class MockOrderCubit extends Cubit<OrderState> {
  MockOrderCubit() : super(const OrderInitial());

  /// Static mock orders for testing
  static List<OrderEntity> get _mockOutgoingOrders => [
    OrderEntity(
      id: '1',
      orderNumber: 'ORD-2023-8842',
      status: 'pending',
      type: 'outgoing',
      location: 'Zone A-14',
      itemCount: 12,
      createdAt: DateTime.now(),
      scheduledTime: DateTime(2023, 10, 24, 9, 30),
      zone: 'A-14',
    ),
    OrderEntity(
      id: '2',
      orderNumber: 'ORD-2023-8845',
      status: 'validated',
      type: 'outgoing',
      location: 'Zone B-03',
      itemCount: 8,
      createdAt: DateTime.now(),
      scheduledTime: DateTime(2023, 10, 24, 10, 45),
      zone: 'A-14',
    ),
    OrderEntity(
      id: '3',
      orderNumber: 'ORD-2023-8851',
      status: 'pending',
      type: 'outgoing',
      location: 'Zone C-07',
      itemCount: 24,
      createdAt: DateTime.now(),
      scheduledTime: DateTime(2023, 10, 24, 11, 15),
      zone: 'A-14',
    ),
    OrderEntity(
      id: '4',
      orderNumber: 'ORD-2023-8860',
      status: 'validated',
      type: 'outgoing',
      location: 'Zone A-02',
      itemCount: 5,
      createdAt: DateTime.now(),
      scheduledTime: DateTime(2023, 10, 24, 12, 0),
      zone: 'A-14',
    ),
  ];

  static List<OrderEntity> get _mockIncomingOrders => [
    OrderEntity(
      id: '5',
      orderNumber: 'INC-2023-1001',
      status: 'pending',
      type: 'incoming',
      location: 'Quai B',
      itemCount: 50,
      createdAt: DateTime.now(),
      scheduledTime: DateTime(2023, 10, 24, 14, 0),
      zone: 'B-02',
    ),
    OrderEntity(
      id: '6',
      orderNumber: 'INC-2023-1002',
      status: 'validated',
      type: 'incoming',
      location: 'Quai A',
      itemCount: 30,
      createdAt: DateTime.now(),
      scheduledTime: DateTime(2023, 10, 24, 15, 30),
      zone: 'B-02',
    ),
  ];

  /// Loads mock orders of the specified type.
  Future<void> loadOrders(String type) async {
    emit(const OrderLoading());

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final orders = type == 'outgoing'
        ? _mockOutgoingOrders
        : _mockIncomingOrders;

    emit(OrderLoaded(orders: orders, currentType: type, isFromCache: false));
  }

  /// Switches to a different order type.
  Future<void> switchOrderType(String type) async {
    await loadOrders(type);
  }

  /// Mock refresh.
  Future<void> refreshOrders() async {
    final currentState = state;
    if (currentState is OrderLoaded) {
      emit(
        OrderRefreshing(
          currentOrders: currentState.orders,
          currentType: currentState.currentType,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      emit(
        OrderLoaded(
          orders: currentState.orders,
          currentType: currentState.currentType,
          isFromCache: false,
        ),
      );
    }
  }
}
