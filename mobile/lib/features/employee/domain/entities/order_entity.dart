import 'package:equatable/equatable.dart';

/// Domain entity representing an Order in the warehouse system.
/// This is the core business object used throughout the application.
///
/// Order types:
/// - 'outgoing': Orders to be shipped out
/// - 'incoming': Orders being received into the warehouse
///
/// Order statuses:
/// - 'pending': Awaiting processing
/// - 'validated': Verified and ready
/// - 'in_progress': Currently being processed
/// - 'completed': Finished
class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String status;
  final String type;
  final String location;
  final int itemCount;
  final DateTime createdAt;
  final DateTime? scheduledTime;
  final String? assignedTo;
  final String? zone;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.type,
    required this.location,
    required this.itemCount,
    required this.createdAt,
    this.scheduledTime,
    this.assignedTo,
    this.zone,
  });

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    status,
    type,
    location,
    itemCount,
    createdAt,
    scheduledTime,
    assignedTo,
    zone,
  ];

  /// Returns true if the order is pending (supports EN/FR)
  bool get isPending =>
      status.toLowerCase() == 'pending' || status.toLowerCase() == 'en attente';

  /// Returns true if the order is validated (supports EN/FR)
  bool get isValidated =>
      status.toLowerCase() == 'validated' || status.toLowerCase() == 'validé';

  /// Returns true if the order is an outgoing order
  bool get isOutgoing => type.toLowerCase() == 'outgoing';

  /// Returns true if the order is an incoming order
  bool get isIncoming => type.toLowerCase() == 'incoming';
}
