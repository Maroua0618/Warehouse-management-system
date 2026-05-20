import '../datasources/employee_api_client.dart';
import '../models/employee_profile_model.dart';
import '../models/employee_stats_model.dart';

class EmployeeRepository {
  final EmployeeApiClient apiClient;

  EmployeeRepository({required this.apiClient});

  Future<EmployeeProfileModel> getProfile() async {
    return await apiClient.getProfile();
  }

  Future<EmployeeStatsModel> getStats() async {
    return await apiClient.getStats();
  }

  Future<List<dynamic>> getTasks({String? taskType, String? status}) async {
    return await apiClient.getTasks(taskType: taskType, status: status);
  }

  Future<Map<String, dynamic>> getTaskDetail(String taskId) async {
    return await apiClient.getTaskDetail(taskId);
  }

  Future<Map<String, dynamic>> updateTaskStatus({
    required String taskId,
    required String status,
    String? notes,
  }) async {
    return await apiClient.updateTaskStatus(
      taskId: taskId,
      status: status,
      notes: notes,
    );
  }

  Future<Map<String, dynamic>> validateTask(String taskId) async {
    return await apiClient.validateTask(taskId);
  }

  Future<Map<String, dynamic>> reportIssue({
    required String taskId,
    required String category,
    required String description,
    String severity = 'MEDIUM',
  }) async {
    return await apiClient.reportIssue(
      taskId: taskId,
      category: category,
      description: description,
      severity: severity,
    );
  }
}
