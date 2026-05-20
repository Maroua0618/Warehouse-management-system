import 'package:sqflite/sqflite.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/ingoing_validation_model.dart';

/// Local data source for caching ingoing validation data.
abstract class IngoingValidationLocalDataSource {
  /// Gets cached validation data for an order.
  Future<IngoingValidationModel> getValidation(String orderId);

  /// Caches validation data locally.
  Future<void> cacheValidation(IngoingValidationModel validation);

  /// Updates validation data in the local cache.
  Future<void> updateValidation(IngoingValidationModel validation);

  /// Deletes cached validation data.
  Future<void> deleteValidation(String orderId);
}

/// Stub implementation of IngoingValidationLocalDataSource.
/// TODO: Implement actual SQLite caching when needed.
class IngoingValidationLocalDataSourceStub
    implements IngoingValidationLocalDataSource {
  IngoingValidationLocalDataSourceStub();

  @override
  Future<IngoingValidationModel> getValidation(String orderId) async {
    throw const CacheException('Local caching not implemented');
  }

  @override
  Future<void> cacheValidation(IngoingValidationModel validation) async {
    // No-op for now
  }

  @override
  Future<void> updateValidation(IngoingValidationModel validation) async {
    // No-op for now
  }

  @override
  Future<void> deleteValidation(String orderId) async {
    // No-op for now
  }
}

/// Implementation of IngoingValidationLocalDataSource using SQLite.
class IngoingValidationLocalDataSourceImpl
    implements IngoingValidationLocalDataSource {
  final Database database;
  static const String tableName = 'ingoing_validations';

  IngoingValidationLocalDataSourceImpl({required this.database});

  /// Creates the table if it doesn't exist.
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        order_number TEXT NOT NULL,
        status TEXT NOT NULL,
        product_type TEXT NOT NULL,
        total_quantity INTEGER NOT NULL,
        validated_quantity INTEGER DEFAULT 0,
        items TEXT,
        path_steps TEXT,
        start_floor TEXT NOT NULL,
        end_floor TEXT NOT NULL,
        is_product_validated INTEGER DEFAULT 0,
        problem_description TEXT,
        cached_at INTEGER NOT NULL
      )
    ''');
  }

  @override
  Future<IngoingValidationModel> getValidation(String orderId) async {
    final results = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [orderId],
    );

    if (results.isEmpty) {
      throw const CacheException('Validation not found in cache');
    }

    return IngoingValidationModel.fromJson(results.first);
  }

  @override
  Future<void> cacheValidation(IngoingValidationModel validation) async {
    final data = validation.toJson();
    data['cached_at'] = DateTime.now().millisecondsSinceEpoch;

    await database.insert(
      tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateValidation(IngoingValidationModel validation) async {
    final data = validation.toJson();
    data['cached_at'] = DateTime.now().millisecondsSinceEpoch;

    await database.update(
      tableName,
      data,
      where: 'id = ?',
      whereArgs: [validation.id],
    );
  }

  @override
  Future<void> deleteValidation(String orderId) async {
    await database.delete(tableName, where: 'id = ?', whereArgs: [orderId]);
  }
}
