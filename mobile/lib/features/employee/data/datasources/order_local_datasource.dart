import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/order_model.dart';

/// Abstract interface for local data source.
/// Defines the contract for caching orders in local database.
abstract class OrderLocalDataSource {
  /// Fetches cached orders from local database.
  /// Throws [CacheException] on failure.
  Future<List<OrderModel>> getOrders({
    required String type,
    String? employeeId,
  });

  /// Fetches a single cached order by ID.
  Future<OrderModel> getOrderById(String orderId);

  /// Caches orders in local database.
  Future<void> cacheOrders(List<OrderModel> orders);

  /// Updates a single order in local database.
  Future<void> updateOrder(OrderModel order);

  /// Clears all cached orders.
  Future<void> clearOrders();
}

/// Implementation of OrderLocalDataSource using SQLite (sqflite).
class OrderLocalDataSourceImpl implements OrderLocalDataSource {
  static const String _tableName = 'orders';
  Database? _database;

  /// Lazily initializes and returns the database instance.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the SQLite database with orders table.
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'mobai_orders.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create orders table
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            order_number TEXT NOT NULL,
            status TEXT NOT NULL,
            type TEXT NOT NULL,
            location TEXT NOT NULL,
            item_count INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            scheduled_time TEXT,
            assigned_to TEXT,
            zone TEXT,
            cached_at TEXT NOT NULL
          )
        ''');

        // Create indexes for faster queries
        await db.execute('CREATE INDEX idx_type ON $_tableName(type)');
        await db.execute('CREATE INDEX idx_status ON $_tableName(status)');
        await db.execute(
          'CREATE INDEX idx_assigned_to ON $_tableName(assigned_to)',
        );
      },
    );
  }

  @override
  Future<List<OrderModel>> getOrders({
    required String type,
    String? employeeId,
  }) async {
    try {
      final db = await database;

      // Build WHERE clause
      String whereClause = 'type = ?';
      List<dynamic> whereArgs = [type];

      if (employeeId != null) {
        whereClause += ' AND assigned_to = ?';
        whereArgs.add(employeeId);
      }

      // Query database
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
      );

      // Convert maps to OrderModel list
      return maps.map((map) => OrderModel.fromDatabase(map)).toList();
    } catch (e) {
      throw CacheException(
        'Failed to fetch orders from cache: ${e.toString()}',
      );
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [orderId],
        limit: 1,
      );

      if (maps.isEmpty) {
        throw const CacheException('Order not found in cache');
      }

      return OrderModel.fromDatabase(maps.first);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to fetch order from cache: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheOrders(List<OrderModel> orders) async {
    try {
      final db = await database;

      // Use batch for better performance
      final batch = db.batch();

      for (final order in orders) {
        batch.insert(
          _tableName,
          order.toDatabase(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw CacheException('Failed to cache orders: ${e.toString()}');
    }
  }

  @override
  Future<void> updateOrder(OrderModel order) async {
    try {
      final db = await database;

      await db.update(
        _tableName,
        order.toDatabase(),
        where: 'id = ?',
        whereArgs: [order.id],
      );
    } catch (e) {
      throw CacheException('Failed to update order: ${e.toString()}');
    }
  }

  @override
  Future<void> clearOrders() async {
    try {
      final db = await database;
      await db.delete(_tableName);
    } catch (e) {
      throw CacheException('Failed to clear orders: ${e.toString()}');
    }
  }

  /// Closes the database connection.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
