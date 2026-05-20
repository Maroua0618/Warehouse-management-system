import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

/// Base state for the Orders feature.
/// All order states extend this class.
abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the cubit is first created.
class OrderInitial extends OrderState {
  const OrderInitial();
}

/// State emitted while orders are being loaded.
class OrderLoading extends OrderState {
  const OrderLoading();
}

/// State emitted when orders are successfully loaded.
class OrderLoaded extends OrderState {
  /// List of orders
  final List<OrderEntity> orders;

  /// Current order type filter ('outgoing' or 'incoming')
  final String currentType;

  /// Whether the data was loaded from cache (offline mode)
  final bool isFromCache;

  const OrderLoaded({
    required this.orders,
    required this.currentType,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [orders, currentType, isFromCache];

  /// Creates a copy with updated fields.
  OrderLoaded copyWith({
    List<OrderEntity>? orders,
    String? currentType,
    bool? isFromCache,
  }) {
    return OrderLoaded(
      orders: orders ?? this.orders,
      currentType: currentType ?? this.currentType,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

/// State emitted when an error occurs.
class OrderError extends OrderState {
  /// Error message to display
  final String message;

  /// Previous orders (if any) to show while displaying error
  final List<OrderEntity>? previousOrders;

  /// Previous order type
  final String? previousType;

  const OrderError({
    required this.message,
    this.previousOrders,
    this.previousType,
  });

  @override
  List<Object?> get props => [message, previousOrders, previousType];
}

/// State emitted while refreshing orders (pull-to-refresh).
class OrderRefreshing extends OrderState {
  /// Current orders being displayed while refreshing
  final List<OrderEntity> currentOrders;

  /// Current order type
  final String currentType;

  const OrderRefreshing({
    required this.currentOrders,
    required this.currentType,
  });

  @override
  List<Object?> get props => [currentOrders, currentType];
}
