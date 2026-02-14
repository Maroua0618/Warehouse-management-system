import 'dart:convert';
import '../../domain/entities/ingoing_validation_entity.dart';
import '../../domain/entities/path_step_entity.dart';
import '../../domain/entities/validation_item_entity.dart';
import 'path_step_model.dart';
import 'validation_item_model.dart';

/// Data model for IngoingValidationEntity with JSON/DB serialization.
class IngoingValidationModel extends IngoingValidationEntity {
  const IngoingValidationModel({
    required super.id,
    required super.orderNumber,
    required super.status,
    required super.productType,
    required super.totalQuantity,
    super.validatedQuantity,
    required super.items,
    required super.pathSteps,
    required super.startFloor,
    required super.endFloor,
    super.isProductValidated,
    super.problemDescription,
  });

  factory IngoingValidationModel.fromJson(Map<String, dynamic> json) {
    // Parse items
    List<ValidationItemEntity> items = [];
    if (json['items'] != null) {
      final itemsData = json['items'] is String
          ? jsonDecode(json['items']) as List
          : json['items'] as List;
      items = itemsData
          .map((i) => ValidationItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    // Parse path steps
    List<PathStepEntity> pathSteps = [];
    if (json['path_steps'] != null) {
      final stepsData = json['path_steps'] is String
          ? jsonDecode(json['path_steps']) as List
          : json['path_steps'] as List;
      pathSteps = stepsData
          .map((s) => PathStepModel.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    return IngoingValidationModel(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      status: ValidationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ValidationStatus.notStarted,
      ),
      productType: json['product_type'] as String,
      totalQuantity: json['total_quantity'] as int,
      validatedQuantity: json['validated_quantity'] as int? ?? 0,
      items: items,
      pathSteps: pathSteps,
      startFloor: json['start_floor'] as String,
      endFloor: json['end_floor'] as String,
      isProductValidated:
          json['is_product_validated'] == 1 ||
          json['is_product_validated'] == true,
      problemDescription: json['problem_description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status.name,
      'product_type': productType,
      'total_quantity': totalQuantity,
      'validated_quantity': validatedQuantity,
      'items': jsonEncode(
        items.map((i) => ValidationItemModel.fromEntity(i).toJson()).toList(),
      ),
      'path_steps': jsonEncode(
        pathSteps.map((s) => PathStepModel.fromEntity(s).toJson()).toList(),
      ),
      'start_floor': startFloor,
      'end_floor': endFloor,
      'is_product_validated': isProductValidated ? 1 : 0,
      'problem_description': problemDescription,
    };
  }

  factory IngoingValidationModel.fromEntity(IngoingValidationEntity entity) {
    return IngoingValidationModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      status: entity.status,
      productType: entity.productType,
      totalQuantity: entity.totalQuantity,
      validatedQuantity: entity.validatedQuantity,
      items: entity.items,
      pathSteps: entity.pathSteps,
      startFloor: entity.startFloor,
      endFloor: entity.endFloor,
      isProductValidated: entity.isProductValidated,
      problemDescription: entity.problemDescription,
    );
  }
}
