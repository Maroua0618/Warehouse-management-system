class EmployeeStatsModel {
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int pendingTasks;
  final double completionRate;
  final int totalItemsHandled;

  EmployeeStatsModel({
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.pendingTasks,
    required this.completionRate,
    required this.totalItemsHandled,
  });

  factory EmployeeStatsModel.fromJson(Map<String, dynamic> json) {
    return EmployeeStatsModel(
      totalTasks: json['total_tasks'] as int,
      completedTasks: json['completed_tasks'] as int,
      inProgressTasks: json['in_progress_tasks'] as int,
      pendingTasks: json['pending_tasks'] as int,
      completionRate: (json['completion_rate'] as num).toDouble(),
      totalItemsHandled: json['total_items_handled'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_tasks': totalTasks,
      'completed_tasks': completedTasks,
      'in_progress_tasks': inProgressTasks,
      'pending_tasks': pendingTasks,
      'completion_rate': completionRate,
      'total_items_handled': totalItemsHandled,
    };
  }
}
