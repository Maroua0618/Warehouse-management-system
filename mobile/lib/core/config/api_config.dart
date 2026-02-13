import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Read from .env file - just update API_BASE_URL in .env when IP changes
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.80.25.251:8000';

  // Supervisor endpoints
  static const String dashboard = '/supervisor/dashboard';
  static const String recentActivity = '/supervisor/recent-activity';
  static const String operationalIssues = '/supervisor/operational-issues';
}
