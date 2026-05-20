/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'MobAI WMS';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://localhost:8000/api';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Database
  static const String dbName = 'mobai_wms.db';
  static const int dbVersion = 1;

  // Offline Support
  static const Duration offlineSyncInterval = Duration(minutes: 5);
  static const Duration minOfflineTime = Duration(hours: 4);

  // Warehouse Constants
  static const String warehouseCode = 'B7';
  static const int maxStorageFloors = 4;
  static const String pickingFloorCode = '0A';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const Duration cacheExpiration = Duration(hours: 24);
}
