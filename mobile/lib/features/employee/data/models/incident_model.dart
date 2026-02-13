import '../../domain/entities/incident_entity.dart';

/// Data model for Incident with JSON/DB serialization.
class IncidentModel extends IncidentEntity {
  const IncidentModel({
    required super.id,
    required super.type,
    required super.description,
    super.locationId,
    super.locationName,
    required super.reportedBy,
    super.reporterName,
    super.commandId,
    required super.status,
    required super.createdAt,
    super.resolvedAt,
  });

  /// Parse incident type from string
  static IncidentType _parseType(String type) {
    switch (type.toUpperCase()) {
      case 'WORKFLOW_BOTTLENECK':
        return IncidentType.workflowBottleneck;
      case 'WRONG_QUANTITY':
        return IncidentType.wrongQuantity;
      case 'WRONG_SKU':
        return IncidentType.wrongSku;
      case 'DELIVERY_NOT_VALIDATED':
        return IncidentType.deliveryNotValidated;
      case 'WRONG_STORAGE_ASSIGNMENT':
        return IncidentType.wrongStorageAssignment;
      case 'STOCK_AVAILABILITY_PROBLEM':
        return IncidentType.stockAvailabilityProblem;
      case 'DAMAGED_PRODUCTS':
        return IncidentType.damagedProducts;
      default:
        return IncidentType.other;
    }
  }

  /// Parse incident status from string
  static IncidentStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return IncidentStatus.open;
      case 'IN_PROGRESS':
        return IncidentStatus.inProgress;
      case 'RESOLVED':
        return IncidentStatus.resolved;
      case 'CLOSED':
        return IncidentStatus.closed;
      default:
        return IncidentStatus.open;
    }
  }

  /// Convert type to string
  static String _typeToString(IncidentType type) {
    switch (type) {
      case IncidentType.workflowBottleneck:
        return 'WORKFLOW_BOTTLENECK';
      case IncidentType.wrongQuantity:
        return 'WRONG_QUANTITY';
      case IncidentType.wrongSku:
        return 'WRONG_SKU';
      case IncidentType.deliveryNotValidated:
        return 'DELIVERY_NOT_VALIDATED';
      case IncidentType.wrongStorageAssignment:
        return 'WRONG_STORAGE_ASSIGNMENT';
      case IncidentType.stockAvailabilityProblem:
        return 'STOCK_AVAILABILITY_PROBLEM';
      case IncidentType.damagedProducts:
        return 'DAMAGED_PRODUCTS';
      case IncidentType.other:
        return 'OTHER';
    }
  }

  /// Convert status to string
  static String _statusToString(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.open:
        return 'OPEN';
      case IncidentStatus.inProgress:
        return 'IN_PROGRESS';
      case IncidentStatus.resolved:
        return 'RESOLVED';
      case IncidentStatus.closed:
        return 'CLOSED';
    }
  }

  /// Create from database row
  factory IncidentModel.fromMap(Map<String, dynamic> map) {
    return IncidentModel(
      id: map['incident_id'] as int,
      type: _parseType(map['type'] as String),
      description: map['description'] as String? ?? '',
      locationId: map['location_id'] as int?,
      locationName: map['location_name'] as String?,
      reportedBy: map['reported_by'] as int,
      reporterName: map['reporter_name'] as String?,
      commandId: map['command_id'] as int?,
      status: _parseStatus(map['status'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      resolvedAt: map['resolved_at'] != null
          ? DateTime.parse(map['resolved_at'] as String)
          : null,
    );
  }

  /// Convert to database map (for insert)
  Map<String, dynamic> toMap() {
    return {
      'type': _typeToString(type),
      'description': description,
      'location_id': locationId,
      'reported_by': reportedBy,
      'command_id': commandId,
      'status': _statusToString(status),
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['incident_id'] as int,
      type: _parseType(json['type'] as String),
      description: json['description'] as String? ?? '',
      locationId: json['location_id'] as int?,
      locationName: json['location_name'] as String?,
      reportedBy: json['reported_by'] as int,
      reporterName: json['reporter_name'] as String?,
      commandId: json['command_id'] as int?,
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final map = toMap();
    map['incident_id'] = id;
    return map;
  }

  /// Create from entity
  factory IncidentModel.fromEntity(IncidentEntity entity) {
    return IncidentModel(
      id: entity.id,
      type: entity.type,
      description: entity.description,
      locationId: entity.locationId,
      locationName: entity.locationName,
      reportedBy: entity.reportedBy,
      reporterName: entity.reporterName,
      commandId: entity.commandId,
      status: entity.status,
      createdAt: entity.createdAt,
      resolvedAt: entity.resolvedAt,
    );
  }

  /// Parse incident type from display name (supports both English and French)
  static IncidentType parseFromDisplayName(String name) {
    switch (name) {
      case 'Flow Bottlenecks':
      case 'Goulots d\'étranglement du flux':
        return IncidentType.workflowBottleneck;
      case 'Wrong Quantity Delivered':
      case 'Problèmes de livraison: Mauvaise quantité livrée':
        return IncidentType.wrongQuantity;
      case 'Wrong SKU Delivered':
      case 'Problèmes de livraison: Mauvais SKU livré':
        return IncidentType.wrongSku;
      case 'Delivery Not Validated':
      case 'Problèmes de livraison: Livraison non validée':
        return IncidentType.deliveryNotValidated;
      case 'Wrong Storage Assignment':
      case 'Mauvaise affectation de stockage':
        return IncidentType.wrongStorageAssignment;
      case 'Stock Availability Issue':
      case 'Problème de disponibilité du stock':
        return IncidentType.stockAvailabilityProblem;
      case 'Damaged Products':
      case 'Produits endommagés':
        return IncidentType.damagedProducts;
      default:
        return IncidentType.other;
    }
  }
}
