import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Read from .env file - just update API_BASE_URL in .env when IP changes
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.80.25.251:8000';

  // Supervisor endpoints
  static const String dashboard = '/supervisor/dashboard';
  static const String recentActivity = '/supervisor/recent-activity';
  static const String operationalIssues = '/supervisor/operational-issues';

  // Storage Moves endpoints
  static const String storageMoves = '/supervisor/storage-moves';

  // Picking Tasks endpoints
  static const String pickingTasks = '/supervisor/picking-tasks';
  static const String pickingWorkers = '/supervisor/picking-tasks/workers';
  static const String pickingEquipment = '/supervisor/picking-tasks/equipment';

  // Bon de Préparation endpoints
  static const String bonDePreparation = '/supervisor/bon-de-preparation';

  // Operational Monitor endpoints
  static const String employeeTracking = '/supervisor/employee-tracking';
  static const String operationalAlerts = '/supervisor/operational-alerts';
  static const String operationalStats = '/supervisor/operational-stats';
}
