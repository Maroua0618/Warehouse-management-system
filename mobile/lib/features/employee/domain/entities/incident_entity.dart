import 'package:equatable/equatable.dart';

/// Status of an incident.
enum IncidentStatus { open, inProgress, resolved, closed }

/// Types of incidents that can be reported.
enum IncidentType {
  workflowBottleneck,
  wrongQuantity,
  wrongSku,
  deliveryNotValidated,
  wrongStorageAssignment,
  stockAvailabilityProblem,
  damagedProducts,
  other,
}

/// Domain entity representing an incident report.
class IncidentEntity extends Equatable {
  final int id;
  final IncidentType type;
  final String description;
  final int? locationId;
  final String? locationName;
  final int reportedBy;
  final String? reporterName;
  final int? commandId;
  final IncidentStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const IncidentEntity({
    required this.id,
    required this.type,
    required this.description,
    this.locationId,
    this.locationName,
    required this.reportedBy,
    this.reporterName,
    this.commandId,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
  });

  /// Get incident type display name in French
  String get typeDisplayName {
    switch (type) {
      case IncidentType.workflowBottleneck:
        return 'Flow Bottlenecks';
      case IncidentType.wrongQuantity:
        return 'Wrong Quantity Delivered';
      case IncidentType.wrongSku:
        return 'Wrong SKU Delivered';
      case IncidentType.deliveryNotValidated:
        return 'Delivery Not Validated';
      case IncidentType.wrongStorageAssignment:
        return 'Wrong Storage Assignment';
      case IncidentType.stockAvailabilityProblem:
        return 'Stock Availability Issue';
      case IncidentType.damagedProducts:
        return 'Damaged Products';
      case IncidentType.other:
        return 'Other';
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case IncidentStatus.open:
        return 'Open';
      case IncidentStatus.inProgress:
        return 'In Progress';
      case IncidentStatus.resolved:
        return 'Resolved';
      case IncidentStatus.closed:
        return 'Closed';
    }
  }

  bool get isOpen => status == IncidentStatus.open;
  bool get isResolved =>
      status == IncidentStatus.resolved || status == IncidentStatus.closed;

  IncidentEntity copyWith({
    int? id,
    IncidentType? type,
    String? description,
    int? locationId,
    String? locationName,
    int? reportedBy,
    String? reporterName,
    int? commandId,
    IncidentStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return IncidentEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      reportedBy: reportedBy ?? this.reportedBy,
      reporterName: reporterName ?? this.reporterName,
      commandId: commandId ?? this.commandId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    description,
    locationId,
    locationName,
    reportedBy,
    reporterName,
    commandId,
    status,
    createdAt,
    resolvedAt,
  ];
}
