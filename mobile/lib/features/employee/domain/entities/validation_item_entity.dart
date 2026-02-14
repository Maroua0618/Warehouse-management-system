import 'package:equatable/equatable.dart';

/// Represents an item to be validated/picked during order validation.
class ValidationItemEntity extends Equatable {
  final String id;
  final String sku;
  final String name;
  final int quantity;
  final bool isValidated;
  final String? slotLocation;

  const ValidationItemEntity({
    required this.id,
    required this.sku,
    required this.name,
    required this.quantity,
    this.isValidated = false,
    this.slotLocation,
  });

  ValidationItemEntity copyWith({
    String? id,
    String? sku,
    String? name,
    int? quantity,
    bool? isValidated,
    String? slotLocation,
  }) {
    return ValidationItemEntity(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isValidated: isValidated ?? this.isValidated,
      slotLocation: slotLocation ?? this.slotLocation,
    );
  }

  @override
  List<Object?> get props => [
    id,
    sku,
    name,
    quantity,
    isValidated,
    slotLocation,
  ];
}
