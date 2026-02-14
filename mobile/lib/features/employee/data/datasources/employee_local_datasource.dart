import 'package:sqflite/sqflite.dart';
import '../../../../core/database/local_database.dart';
import '../models/command_model.dart';
import '../models/incident_model.dart';
import '../models/inventory_model.dart';
import '../models/location_model.dart';
import '../models/user_model.dart';

/// Local datasource for employee-related database operations.
class EmployeeLocalDatasource {
  /// Get the database instance
  Future<Database> get _db async => await LocalDatabase.database;

  // ============== USER OPERATIONS ==============

  /// Get current logged-in user
  Future<UserModel?> getCurrentUser(int userId) async {
    final db = await _db;
    final result = await db.rawQuery(
      '''
      SELECT u.*, r.role_name 
      FROM users u 
      JOIN roles r ON u.role_id = r.role_id 
      WHERE u.user_id = ?
    ''',
      [userId],
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  /// Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    final db = await _db;
    final result = await db.rawQuery(
      '''
      SELECT u.*, r.role_name 
      FROM users u 
      JOIN roles r ON u.role_id = r.role_id 
      WHERE u.username = ?
    ''',
      [username],
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  /// Update user last login
  Future<void> updateLastLogin(int userId) async {
    final db = await _db;
    await db.update(
      'users',
      {'last_login': DateTime.now().toIso8601String()},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // ============== COMMAND OPERATIONS ==============

  /// Get all commands assigned to employee (by type)
  Future<List<CommandModel>> getCommands({
    String? type,
    String? status,
    int? limit,
  }) async {
    final db = await _db;
    String query = 'SELECT * FROM commands WHERE 1=1';
    final args = <dynamic>[];

    if (type != null) {
      query += ' AND command_type = ?';
      args.add(type);
    }
    if (status != null) {
      query += ' AND status = ?';
      args.add(status);
    }
    query += ' ORDER BY created_at DESC';
    if (limit != null) {
      query += ' LIMIT ?';
      args.add(limit);
    }

    final result = await db.rawQuery(query, args);
    final commands = <CommandModel>[];

    for (final row in result) {
      final items = await getCommandItems(row['command_id'] as int);
      commands.add(CommandModel.fromMap(row, items: items));
    }
    return commands;
  }

  /// Get command by ID with items
  Future<CommandModel?> getCommandById(int commandId) async {
    final db = await _db;
    final result = await db.query(
      'commands',
      where: 'command_id = ?',
      whereArgs: [commandId],
    );
    if (result.isEmpty) return null;

    final items = await getCommandItems(commandId);
    return CommandModel.fromMap(result.first, items: items);
  }

  /// Get command items for a command
  Future<List<CommandItemModel>> getCommandItems(int commandId) async {
    final db = await _db;
    final result = await db.query(
      'command_items',
      where: 'command_id = ?',
      whereArgs: [commandId],
      orderBy: 'command_item_id',
    );
    return result.map((row) => CommandItemModel.fromMap(row)).toList();
  }

  /// Update command item status
  Future<void> updateCommandItemStatus(
    int itemId,
    String status, {
    int? validatedBy,
  }) async {
    final db = await _db;
    final updateData = <String, dynamic>{
      'status': status,
      'validated_at': DateTime.now().toIso8601String(),
    };
    if (validatedBy != null) {
      updateData['validated_by'] = validatedBy;
    }
    await db.update(
      'command_items',
      updateData,
      where: 'command_item_id = ?',
      whereArgs: [itemId],
    );
  }

  /// Update command status based on items completion
  Future<void> updateCommandStatus(int commandId) async {
    final db = await _db;
    final items = await getCommandItems(commandId);

    String newStatus;
    if (items.every((item) => item.status == 'COMPLETED')) {
      newStatus = 'COMPLETED';
    } else if (items.any((item) => item.status == 'COMPLETED')) {
      newStatus = 'IN_PROGRESS';
    } else {
      newStatus = 'PENDING';
    }

    await db.update(
      'commands',
      {'status': newStatus},
      where: 'command_id = ?',
      whereArgs: [commandId],
    );
  }

  // ============== INCIDENT OPERATIONS ==============

  /// Create a new incident report
  Future<int> createIncident({
    required String type,
    required String description,
    required int reportedBy,
    int? locationId,
    int? commandId,
  }) async {
    final db = await _db;
    return await db.insert('incidents', {
      'type': type,
      'description': description,
      'reported_by': reportedBy,
      'location_id': locationId,
      'command_id': commandId,
      'status': 'OPEN',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get incidents reported by user
  Future<List<IncidentModel>> getIncidentsByUser(int userId) async {
    final db = await _db;
    final result = await db.rawQuery(
      '''
      SELECT i.*, l.location_code as location_name, u.full_name as reporter_name
      FROM incidents i
      LEFT JOIN locations l ON i.location_id = l.location_id
      LEFT JOIN users u ON i.reported_by = u.user_id
      WHERE i.reported_by = ?
      ORDER BY i.created_at DESC
    ''',
      [userId],
    );
    return result.map((row) => IncidentModel.fromMap(row)).toList();
  }

  /// Get all open incidents
  Future<List<IncidentModel>> getOpenIncidents() async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT i.*, l.location_code as location_name, u.full_name as reporter_name
      FROM incidents i
      LEFT JOIN locations l ON i.location_id = l.location_id
      LEFT JOIN users u ON i.reported_by = u.user_id
      WHERE i.status = 'OPEN'
      ORDER BY i.created_at DESC
    ''');
    return result.map((row) => IncidentModel.fromMap(row)).toList();
  }

  // ============== LOCATION OPERATIONS ==============

  /// Get all locations
  Future<List<LocationModel>> getLocations({int? warehouseId}) async {
    final db = await _db;
    String query = 'SELECT * FROM locations';
    final args = <dynamic>[];

    if (warehouseId != null) {
      query += ' WHERE warehouse_id = ?';
      args.add(warehouseId);
    }
    query += ' ORDER BY area, rack, slot';

    final result = await db.rawQuery(query, args);
    return result.map((row) => LocationModel.fromMap(row)).toList();
  }

  /// Get location by ID
  Future<LocationModel?> getLocationById(int locationId) async {
    final db = await _db;
    final result = await db.query(
      'locations',
      where: 'location_id = ?',
      whereArgs: [locationId],
    );
    if (result.isEmpty) return null;
    return LocationModel.fromMap(result.first);
  }

  /// Get storage locations only
  Future<List<LocationModel>> getStorageLocations() async {
    final db = await _db;
    final result = await db.query(
      'locations',
      where: 'is_storage = 1',
      orderBy: 'area, rack, slot',
    );
    return result.map((row) => LocationModel.fromMap(row)).toList();
  }

  // ============== INVENTORY OPERATIONS ==============

  /// Get inventory items
  Future<List<InventoryModel>> getInventory({
    int? locationId,
    String? sku,
    bool? lowStockOnly,
  }) async {
    final db = await _db;
    String query = '''
      SELECT i.*, l.location_code 
      FROM inventory i 
      LEFT JOIN locations l ON i.location_id = l.location_id
      WHERE 1=1
    ''';
    final args = <dynamic>[];

    if (locationId != null) {
      query += ' AND i.location_id = ?';
      args.add(locationId);
    }
    if (sku != null) {
      query += ' AND i.sku LIKE ?';
      args.add('%$sku%');
    }
    if (lowStockOnly == true) {
      query += ' AND i.quantity_on_hand < 10';
    }
    query += ' ORDER BY i.product_name';

    final result = await db.rawQuery(query, args);
    return result.map((row) => InventoryModel.fromMap(row)).toList();
  }

  /// Update inventory quantity
  Future<void> updateInventoryQuantity(int itemId, int newQuantity) async {
    final db = await _db;
    await db.update(
      'inventory',
      {
        'quantity_on_hand': newQuantity,
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
  }

  // ============== PATH STEPS OPERATIONS ==============

  /// Get path steps for a command
  Future<List<Map<String, dynamic>>> getPathSteps(int commandId) async {
    final db = await _db;
    final result = await db.rawQuery(
      '''
      SELECT ps.*, ci.sku, ci.product_name, ci.quantity as item_quantity, ci.status as item_status
      FROM path_steps ps
      LEFT JOIN command_items ci ON ps.item_id = ci.command_item_id
      WHERE ps.command_id = ?
      ORDER BY ps.step_order
    ''',
      [commandId],
    );
    return result;
  }

  /// Update path step completion
  Future<void> completePathStep(int pathStepId) async {
    final db = await _db;
    await db.update(
      'path_steps',
      {'is_completed': 1, 'completed_at': DateTime.now().toIso8601String()},
      where: 'path_step_id = ?',
      whereArgs: [pathStepId],
    );
  }

  // ============== AUDIT LOG OPERATIONS ==============

  /// Log an action for audit trail
  Future<void> logAction({
    required int userId,
    required String action,
    required String entity,
    int? entityId,
    String? details,
  }) async {
    final db = await _db;
    await db.insert('audit_log', {
      'user_id': userId,
      'action': action,
      'entity': entity,
      'entity_id': entityId,
      'details': details,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ============== STATISTICS FOR DASHBOARD ==============

  /// Get employee dashboard statistics
  Future<Map<String, dynamic>> getEmployeeStats(int userId) async {
    final db = await _db;

    // Count pending commands
    final pendingResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM commands WHERE status = 'PENDING'
    ''');
    final pendingCount = pendingResult.first['count'] as int;

    // Count in-progress commands
    final inProgressResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM commands WHERE status = 'IN_PROGRESS'
    ''');
    final inProgressCount = inProgressResult.first['count'] as int;

    // Count completed commands today
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final completedTodayResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM commands 
      WHERE status = 'COMPLETED' AND created_at LIKE ?
    ''',
      ['$today%'],
    );
    final completedTodayCount = completedTodayResult.first['count'] as int;

    // Count user's reported incidents
    final incidentsResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM incidents WHERE reported_by = ?
    ''',
      [userId],
    );
    final incidentsCount = incidentsResult.first['count'] as int;

    return {
      'pendingCommands': pendingCount,
      'inProgressCommands': inProgressCount,
      'completedToday': completedTodayCount,
      'reportedIncidents': incidentsCount,
    };
  }

  // ============== SAMPLE DATA OPERATIONS ==============

  /// Insert sample commands for testing
  Future<void> insertSampleCommands() async {
    final db = await _db;

    // Check if commands already exist
    final existing = await db.query('commands', limit: 1);
    if (existing.isNotEmpty) return;

    final now = DateTime.now();

    // Insert RECEIPT commands (ingoing orders) - location format: B7-N1-C2
    final ingoingLocations = ['B7-N1-C2', 'E4-W3-S4', 'F1-N2-E5'];
    for (int i = 1; i <= 3; i++) {
      final status = i == 1
          ? 'IN_PROGRESS'
          : (i == 2 ? 'COMPLETED' : 'PENDING');
      final scheduledTime = now.add(Duration(hours: i)).toIso8601String();

      final commandId = await db.insert('commands', {
        'order_number': 'ING-99${30 + i}',
        'command_type': 'RECEIPT',
        'location': ingoingLocations[i - 1],
        'created_by': 1,
        'status': status,
        'created_at': now.subtract(Duration(hours: i)).toIso8601String(),
        'scheduled_time': scheduledTime,
      });

      // Add items to each command
      final itemCount = 10 + (i * 8);
      for (int j = 1; j <= 4; j++) {
        await db.insert('command_items', {
          'command_id': commandId,
          'sku': 'SKU-${1000 + (i * 10) + j}',
          'product_name': 'Article ${String.fromCharCode(64 + j)}',
          'quantity': (itemCount / 4).round(),
          'status': (status == 'COMPLETED')
              ? 'COMPLETED'
              : ((i == 1 && j == 1) ? 'COMPLETED' : 'PENDING'),
        });
      }

      // Add path steps for ingoing
      final pathSteps = [
        {
          'step_type': 'PICKUP',
          'floor': 'Floor 1',
          'location_name': 'Zone de Réception',
          'step_order': 1,
        },
        {
          'step_type': 'TRANSIT',
          'floor': 'Floor 1',
          'location_name': 'Zone Tampon',
          'step_order': 2,
        },
        {
          'step_type': 'TRANSIT',
          'floor': 'Floor 2',
          'location_name': 'Zone de Stockage',
          'step_order': 3,
        },
        {
          'step_type': 'DROPOFF',
          'floor': 'Floor 2',
          'location_name': ingoingLocations[i - 1],
          'step_order': 4,
        },
      ];

      for (final step in pathSteps) {
        await db.insert('path_steps', {
          'command_id': commandId,
          ...step,
          'is_completed': status == 'COMPLETED' ? 1 : 0,
        });
      }
    }

    // Insert DELIVERY commands (outgoing orders) - location format: B7-0A-XX-YY
    final outgoingLocations = [
      'B7-0A-01-05',
      'A3-0A-02-08',
      'C2-0A-03-12',
      'D5-0A-04-03',
    ];
    for (int i = 1; i <= 4; i++) {
      final status = (i == 2 || i == 4) ? 'COMPLETED' : 'PENDING';
      final scheduledTime = now.add(Duration(hours: i + 2)).toIso8601String();

      final commandId = await db.insert('commands', {
        'order_number': 'ORD-2023-88${40 + i}',
        'command_type': 'DELIVERY',
        'location': outgoingLocations[i - 1],
        'created_by': 1,
        'status': status,
        'created_at': now.subtract(Duration(hours: i + 1)).toIso8601String(),
        'scheduled_time': scheduledTime,
      });

      // Add items
      final itemCount = 5 + (i * 5);
      for (int j = 1; j <= 3; j++) {
        await db.insert('command_items', {
          'command_id': commandId,
          'sku': 'SKU-${3000 + (i * 10) + j}',
          'product_name': 'Produit Sortant ${String.fromCharCode(64 + j)}',
          'quantity': (itemCount / 3).round(),
          'status': status == 'COMPLETED' ? 'COMPLETED' : 'PENDING',
        });
      }

      // Add path steps for outgoing
      final pathSteps = [
        {
          'step_type': 'PICKUP',
          'floor': 'Floor 2',
          'location_name': outgoingLocations[i - 1],
          'step_order': 1,
        },
        {
          'step_type': 'TRANSIT',
          'floor': 'Floor 2',
          'location_name': 'Zone de Préparation',
          'step_order': 2,
        },
        {
          'step_type': 'TRANSIT',
          'floor': 'Floor 1',
          'location_name': 'Zone de Validation',
          'step_order': 3,
        },
        {
          'step_type': 'DROPOFF',
          'floor': 'Floor 1',
          'location_name': 'Quai de Chargement',
          'step_order': 4,
        },
      ];

      for (final step in pathSteps) {
        await db.insert('path_steps', {
          'command_id': commandId,
          ...step,
          'is_completed': status == 'COMPLETED' ? 1 : 0,
        });
      }
    }
  }

  /// Insert sample inventory for testing
  Future<void> insertSampleInventory() async {
    final db = await _db;

    // Check if inventory already exists
    final existing = await db.query('inventory', limit: 1);
    if (existing.isNotEmpty) return;

    final items = [
      {
        'sku': 'SKU-1001',
        'product_name': 'Widget A',
        'quantity_on_hand': 150,
        'location_id': 1,
      },
      {
        'sku': 'SKU-1002',
        'product_name': 'Widget B',
        'quantity_on_hand': 75,
        'location_id': 2,
      },
      {
        'sku': 'SKU-1003',
        'product_name': 'Gadget C',
        'quantity_on_hand': 8,
        'location_id': 3,
      },
      {
        'sku': 'SKU-1004',
        'product_name': 'Gadget D',
        'quantity_on_hand': 200,
        'location_id': 4,
      },
      {
        'sku': 'SKU-2001',
        'product_name': 'Component X',
        'quantity_on_hand': 50,
        'location_id': 5,
      },
      {
        'sku': 'SKU-2002',
        'product_name': 'Component Y',
        'quantity_on_hand': 3,
        'location_id': 6,
      },
    ];

    for (final item in items) {
      await db.insert('inventory', {
        ...item,
        'unit_of_measure': 'pcs',
        'last_updated': DateTime.now().toIso8601String(),
      });
    }
  }
}
