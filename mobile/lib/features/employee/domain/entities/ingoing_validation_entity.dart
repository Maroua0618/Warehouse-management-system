import 'package:equatable/equatable.dart';
import 'path_step_entity.dart';
import 'validation_item_entity.dart';

/// Status of the ingoing order validation process.
enum ValidationStatus { notStarted, inProgress, completed, hasIssue }

/// Represents the complete ingoing order validation process.
class IngoingValidationEntity extends Equatable {
  final String id;
  final String orderNumber;
  final ValidationStatus status;
  final String productType;
  final int totalQuantity;
  final int validatedQuantity;
  final List<ValidationItemEntity> items;
  final List<PathStepEntity> pathSteps;
  final String startFloor;
  final String endFloor;
  final bool isProductValidated;
  final String? problemDescription;

  const IngoingValidationEntity({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.productType,
    required this.totalQuantity,
    this.validatedQuantity = 0,
    required this.items,
    required this.pathSteps,
    required this.startFloor,
    required this.endFloor,
    this.isProductValidated = false,
    this.problemDescription,
  });

  /// Progress percentage (0-100)
  int get progressPercentage {
    if (items.isEmpty) return 0;
    final validated = items.where((i) => i.isValidated).length;
    return ((validated / items.length) * 100).round();
  }

  /// Number of validated items
  int get validatedItemCount => items.where((i) => i.isValidated).length;

  /// Total number of items
  int get totalItemCount => items.length;

  /// Current path (e.g., "Floor 1 > Floor 3")
  String get currentPath => '$startFloor > $endFloor';

  /// Status label
  String get statusLabel {
    switch (status) {
      case ValidationStatus.notStarted:
        return 'NOT STARTED';
      case ValidationStatus.inProgress:
        return 'IN PROGRESS';
      case ValidationStatus.completed:
        return 'COMPLETED';
      case ValidationStatus.hasIssue:
        return 'ISSUE';
    }
  }

  IngoingValidationEntity copyWith({
    String? id,
    String? orderNumber,
    ValidationStatus? status,
    String? productType,
    int? totalQuantity,
    int? validatedQuantity,
    List<ValidationItemEntity>? items,
    List<PathStepEntity>? pathSteps,
    String? startFloor,
    String? endFloor,
    bool? isProductValidated,
    String? problemDescription,
  }) {
    return IngoingValidationEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      productType: productType ?? this.productType,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      validatedQuantity: validatedQuantity ?? this.validatedQuantity,
      items: items ?? this.items,
      pathSteps: pathSteps ?? this.pathSteps,
      startFloor: startFloor ?? this.startFloor,
      endFloor: endFloor ?? this.endFloor,
      isProductValidated: isProductValidated ?? this.isProductValidated,
      problemDescription: problemDescription ?? this.problemDescription,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    status,
    productType,
    totalQuantity,
    validatedQuantity,
    items,
    pathSteps,
    startFloor,
    endFloor,
    isProductValidated,
    problemDescription,
  ];
}
