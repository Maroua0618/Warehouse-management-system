class DashboardStats {
  final int activeEmployees;
  final int pendingViolations;
  final int ordersToday;
  final int aiOverrides;
  final double savedTodayMeters;
  final double performancePercentage;

  DashboardStats({
    required this.activeEmployees,
    required this.pendingViolations,
    required this.ordersToday,
    required this.aiOverrides,
    required this.savedTodayMeters,
    required this.performancePercentage,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      activeEmployees: json['active_employees'] as int,
      pendingViolations: json['pending_violations'] as int,
      ordersToday: json['orders_today'] as int,
      aiOverrides: json['ai_overrides'] as int,
      savedTodayMeters: (json['saved_today_meters'] as num).toDouble(),
      performancePercentage: (json['performance_percentage'] as num).toDouble(),
    );
  }
}

class RecentActivity {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? status;

  RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.status,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String?,
    );
  }
}

class OperationalIssue {
  final String id;
  final String issueType;
  final String priority;
  final String status;
  final String employeeName;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  OperationalIssue({
    required this.id,
    required this.issueType,
    required this.priority,
    required this.status,
    required this.employeeName,
    required this.title,
    required this.description,
    required this.createdAt,
    this.resolvedAt,
  });

  factory OperationalIssue.fromJson(Map<String, dynamic> json) {
    return OperationalIssue(
      id: json['id'] as String,
      issueType: json['issue_type'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      employeeName: json['employee_name'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }
}
