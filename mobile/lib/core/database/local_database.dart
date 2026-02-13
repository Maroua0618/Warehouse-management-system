import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Local SQLite database manager for the BMS application.
class LocalDatabase {
  static Database? _database;
  static const int _version = 3;
  static const String _dbName = 'bms_database.db';

  /// Get database instance (singleton)
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create all tables
  static Future<void> _onCreate(Database db, int version) async {
    // Roles table
    await db.execute('''
      CREATE TABLE roles (
        role_id INTEGER PRIMARY KEY AUTOINCREMENT,
        role_name TEXT NOT NULL UNIQUE,
        description TEXT
      )
    ''');

    // Permissions table
    await db.execute('''
      CREATE TABLE permissions (
        permission_id INTEGER PRIMARY KEY AUTOINCREMENT,
        permission_code TEXT NOT NULL UNIQUE,
        description TEXT
      )
    ''');

    // Role permissions junction table
    await db.execute('''
      CREATE TABLE role_permissions (
        role_id INTEGER NOT NULL,
        permission_id INTEGER NOT NULL,
        PRIMARY KEY (role_id, permission_id),
        FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
        FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE
      )
    ''');

    // Users table
    await db.execute('''
      CREATE TABLE users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role_id INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        last_login TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (role_id) REFERENCES roles(role_id)
      )
    ''');

    // Warehouses table
    await db.execute('''
      CREATE TABLE warehouses (
        warehouse_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        location TEXT,
        description TEXT
      )
    ''');

    // Zones table (optional zones within warehouse)
    await db.execute('''
      CREATE TABLE zones (
        zone_id INTEGER PRIMARY KEY AUTOINCREMENT,
        warehouse_id INTEGER NOT NULL,
        zone_code TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id) ON DELETE CASCADE
      )
    ''');

    // Locations table
    await db.execute('''
      CREATE TABLE locations (
        location_id INTEGER PRIMARY KEY AUTOINCREMENT,
        warehouse_id INTEGER NOT NULL,
        area TEXT,
        rack TEXT,
        slot TEXT,
        location_code TEXT NOT NULL UNIQUE,
        is_storage INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id) ON DELETE CASCADE
      )
    ''');

    // Inventory table (stock ledger)
    await db.execute('''
      CREATE TABLE inventory (
        item_id INTEGER PRIMARY KEY AUTOINCREMENT,
        sku TEXT NOT NULL,
        product_name TEXT NOT NULL,
        lot_number TEXT,
        quantity_on_hand INTEGER NOT NULL DEFAULT 0,
        unit_of_measure TEXT NOT NULL DEFAULT 'pcs',
        location_id INTEGER,
        last_updated TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (location_id) REFERENCES locations(location_id)
      )
    ''');

    // Tasks table (operational tasks)
    await db.execute('''
      CREATE TABLE tasks (
        task_id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_name TEXT NOT NULL,
        description TEXT,
        required_role INTEGER,
        sequence_order INTEGER,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (required_role) REFERENCES roles(role_id)
      )
    ''');

    // Commands table (orders from AI or system)
    await db.execute('''
      CREATE TABLE commands (
        command_id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_number TEXT,
        command_type TEXT NOT NULL,
        location TEXT,
        created_by INTEGER,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        scheduled_time TEXT,
        status TEXT NOT NULL DEFAULT 'PENDING',
        FOREIGN KEY (created_by) REFERENCES users(user_id)
      )
    ''');

    // Command items table (specific items in a command)
    await db.execute('''
      CREATE TABLE command_items (
        command_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
        command_id INTEGER NOT NULL,
        sku TEXT NOT NULL,
        product_name TEXT,
        quantity INTEGER NOT NULL,
        lot_number TEXT,
        location_expected_id INTEGER,
        status TEXT NOT NULL DEFAULT 'PENDING',
        validated_at TEXT,
        validated_by INTEGER,
        FOREIGN KEY (command_id) REFERENCES commands(command_id) ON DELETE CASCADE,
        FOREIGN KEY (location_expected_id) REFERENCES locations(location_id),
        FOREIGN KEY (validated_by) REFERENCES users(user_id)
      )
    ''');

    // Procedures table (AI-assisted steps or SOPs)
    await db.execute('''
      CREATE TABLE procedures (
        procedure_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        applicable_role_id INTEGER,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (applicable_role_id) REFERENCES roles(role_id)
      )
    ''');

    // AI decisions table
    await db.execute('''
      CREATE TABLE ai_decisions (
        ai_decision_id INTEGER PRIMARY KEY AUTOINCREMENT,
        command_id INTEGER NOT NULL,
        decision_type TEXT NOT NULL,
        details TEXT,
        validated_by_user_id INTEGER,
        is_overridden INTEGER NOT NULL DEFAULT 0,
        justification TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (command_id) REFERENCES commands(command_id) ON DELETE CASCADE,
        FOREIGN KEY (validated_by_user_id) REFERENCES users(user_id)
      )
    ''');

    // AI suggestions table (read-only for employees)
    await db.execute('''
      CREATE TABLE ai_suggestions (
        suggestion_id INTEGER PRIMARY KEY AUTOINCREMENT,
        command_item_id INTEGER NOT NULL,
        suggested_value TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (command_item_id) REFERENCES command_items(command_item_id) ON DELETE CASCADE
      )
    ''');

    // Audit log table (full traceability)
    await db.execute('''
      CREATE TABLE audit_log (
        log_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        action TEXT NOT NULL,
        entity TEXT NOT NULL,
        entity_id INTEGER,
        details TEXT,
        timestamp TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(user_id)
      )
    ''');

    // Incidents table (incident handling)
    await db.execute('''
      CREATE TABLE incidents (
        incident_id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        description TEXT,
        location_id INTEGER,
        reported_by INTEGER NOT NULL,
        command_id INTEGER,
        status TEXT NOT NULL DEFAULT 'OPEN',
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        resolved_at TEXT,
        FOREIGN KEY (location_id) REFERENCES locations(location_id),
        FOREIGN KEY (reported_by) REFERENCES users(user_id),
        FOREIGN KEY (command_id) REFERENCES commands(command_id)
      )
    ''');

    // Chariots table (mobility units)
    await db.execute('''
      CREATE TABLE chariots (
        chariot_id INTEGER PRIMARY KEY AUTOINCREMENT,
        identifier TEXT NOT NULL UNIQUE,
        current_location_id INTEGER,
        status TEXT NOT NULL DEFAULT 'IDLE',
        last_maintenance TEXT,
        FOREIGN KEY (current_location_id) REFERENCES locations(location_id)
      )
    ''');

    // Live tracking table (real-time view)
    await db.execute('''
      CREATE TABLE live_tracking (
        tracking_id INTEGER PRIMARY KEY AUTOINCREMENT,
        chariot_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        location_id INTEGER NOT NULL,
        timestamp TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        status TEXT NOT NULL,
        FOREIGN KEY (chariot_id) REFERENCES chariots(chariot_id),
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (location_id) REFERENCES locations(location_id)
      )
    ''');

    // Path steps table (for ingoing validation flow)
    await db.execute('''
      CREATE TABLE path_steps (
        path_step_id INTEGER PRIMARY KEY AUTOINCREMENT,
        command_id INTEGER NOT NULL,
        step_type TEXT NOT NULL,
        floor TEXT,
        location_name TEXT NOT NULL,
        step_order INTEGER NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT,
        item_id INTEGER,
        FOREIGN KEY (command_id) REFERENCES commands(command_id) ON DELETE CASCADE,
        FOREIGN KEY (item_id) REFERENCES command_items(command_item_id)
      )
    ''');

    // Create indexes for frequently queried fields
    await db.execute('CREATE INDEX idx_users_username ON users(username)');
    await db.execute('CREATE INDEX idx_users_role ON users(role_id)');
    await db.execute('CREATE INDEX idx_inventory_sku ON inventory(sku)');
    await db.execute(
      'CREATE INDEX idx_inventory_location ON inventory(location_id)',
    );
    await db.execute(
      'CREATE INDEX idx_command_items_command ON command_items(command_id)',
    );
    await db.execute(
      'CREATE INDEX idx_command_items_sku ON command_items(sku)',
    );
    await db.execute(
      'CREATE INDEX idx_commands_type ON commands(command_type)',
    );
    await db.execute('CREATE INDEX idx_commands_status ON commands(status)');
    await db.execute(
      'CREATE INDEX idx_ai_decisions_command ON ai_decisions(command_id)',
    );
    await db.execute('CREATE INDEX idx_audit_log_user ON audit_log(user_id)');
    await db.execute(
      'CREATE INDEX idx_audit_log_timestamp ON audit_log(timestamp)',
    );
    await db.execute('CREATE INDEX idx_incidents_status ON incidents(status)');
    await db.execute(
      'CREATE INDEX idx_live_tracking_chariot ON live_tracking(chariot_id)',
    );
    await db.execute(
      'CREATE INDEX idx_live_tracking_timestamp ON live_tracking(timestamp)',
    );
    await db.execute(
      'CREATE INDEX idx_path_steps_command ON path_steps(command_id)',
    );

    // Insert default roles
    await db.insert('roles', {
      'role_name': 'Employee',
      'description': 'Warehouse staff operator',
    });
    await db.insert('roles', {
      'role_name': 'Supervisor',
      'description': 'Floor supervisor with override capabilities',
    });

    // Insert default permissions
    final employeePermissions = [
      {
        'permission_code': 'CAN_VIEW_OWN_TASKS',
        'description': 'View assigned tasks',
      },
      {
        'permission_code': 'CAN_VALIDATE_ITEMS',
        'description': 'Validate received items',
      },
      {
        'permission_code': 'CAN_REPORT_INCIDENTS',
        'description': 'Report incidents and problems',
      },
      {
        'permission_code': 'CAN_VIEW_INVENTORY',
        'description': 'View inventory levels',
      },
    ];

    final supervisorPermissions = [
      {
        'permission_code': 'CAN_VIEW_AI_SUGGESTIONS',
        'description': 'View AI decision suggestions',
      },
      {
        'permission_code': 'CAN_OVERRIDE_AI',
        'description': 'Override AI decisions',
      },
      {
        'permission_code': 'CAN_APPROVE_AI_DECISIONS',
        'description': 'Approve AI storage decisions',
      },
      {
        'permission_code': 'CAN_MONITOR_REAL_TIME',
        'description': 'Monitor live warehouse state',
      },
      {
        'permission_code': 'CAN_ASSIGN_CHARIOTS',
        'description': 'Assign chariots to operators',
      },
      {
        'permission_code': 'CAN_VIEW_OVERRIDE_HISTORY',
        'description': 'View AI override history',
      },
      {
        'permission_code': 'CAN_HANDLE_INCIDENTS',
        'description': 'Handle and resolve incidents',
      },
      {
        'permission_code': 'CAN_VIEW_ALL_TASKS',
        'description': 'View all employee tasks',
      },
    ];

    for (final perm in [...employeePermissions, ...supervisorPermissions]) {
      await db.insert('permissions', perm);
    }

    // Link Employee role to employee permissions (role_id = 1)
    for (int i = 1; i <= employeePermissions.length; i++) {
      await db.insert('role_permissions', {'role_id': 1, 'permission_id': i});
    }

    // Link Supervisor role to all permissions (role_id = 2)
    for (
      int i = 1;
      i <= employeePermissions.length + supervisorPermissions.length;
      i++
    ) {
      await db.insert('role_permissions', {'role_id': 2, 'permission_id': i});
    }

    // Insert sample warehouse
    await db.insert('warehouses', {
      'name': 'Entrepôt Principal',
      'location': 'Zone Industrielle Nord',
      'description': 'Entrepôt principal de stockage',
    });

    // Insert sample locations
    final locations = [
      {
        'warehouse_id': 1,
        'area': 'Étage 1',
        'rack': 'A',
        'slot': '1',
        'location_code': 'E1-A1',
        'is_storage': 1,
      },
      {
        'warehouse_id': 1,
        'area': 'Étage 1',
        'rack': 'A',
        'slot': '2',
        'location_code': 'E1-A2',
        'is_storage': 1,
      },
      {
        'warehouse_id': 1,
        'area': 'Étage 1',
        'rack': 'B',
        'slot': '1',
        'location_code': 'E1-B1',
        'is_storage': 1,
      },
      {
        'warehouse_id': 1,
        'area': 'Étage 2',
        'rack': 'A',
        'slot': '1',
        'location_code': 'E2-A1',
        'is_storage': 1,
      },
      {
        'warehouse_id': 1,
        'area': 'Étage 2',
        'rack': 'B',
        'slot': '1',
        'location_code': 'E2-B1',
        'is_storage': 1,
      },
      {
        'warehouse_id': 1,
        'area': 'Étage 3',
        'rack': 'A',
        'slot': '1',
        'location_code': 'E3-A1',
        'is_storage': 1,
      },
      {
        'warehouse_id': 1,
        'area': 'Zone Réception',
        'rack': 'R',
        'slot': '1',
        'location_code': 'ZR-R1',
        'is_storage': 0,
      },
      {
        'warehouse_id': 1,
        'area': 'Zone Expédition',
        'rack': 'E',
        'slot': '1',
        'location_code': 'ZE-E1',
        'is_storage': 0,
      },
    ];
    for (final loc in locations) {
      await db.insert('locations', loc);
    }

    // Insert sample users
    await db.insert('users', {
      'username': 'employee',
      'password_hash': 'employee123',
      'full_name': 'Jean Dupont',
      'role_id': 1,
      'status': 'active',
    });

    await db.insert('users', {
      'username': 'supervisor',
      'password_hash': 'supervisor123',
      'full_name': 'Marie Martin',
      'role_id': 2,
      'status': 'active',
    });
  }

  /// Handle database upgrades
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration from version 1 to 2: Add order_number, location, scheduled_time to commands table
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE commands ADD COLUMN order_number TEXT');
      await db.execute('ALTER TABLE commands ADD COLUMN location TEXT');
      await db.execute('ALTER TABLE commands ADD COLUMN scheduled_time TEXT');
    }

    // Migration from version 2 to 3: Add sample users (employee & supervisor)
    if (oldVersion < 3) {
      // Clear existing users and add new sample users
      await db.delete('users');
      await db.insert('users', {
        'username': 'employee',
        'password_hash': 'employee123',
        'full_name': 'Jean Dupont',
        'role_id': 1,
        'status': 'active',
      });
      await db.insert('users', {
        'username': 'supervisor',
        'password_hash': 'supervisor123',
        'full_name': 'Marie Martin',
        'role_id': 2,
        'status': 'active',
      });
    }
  }

  /// Close the database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Delete entire database (for testing/reset)
  static Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
