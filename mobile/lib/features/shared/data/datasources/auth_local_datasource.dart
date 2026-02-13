import '../../../../core/database/local_database.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Local data source for authentication using SQLite database.
abstract class AuthLocalDataSource {
  /// Authenticates user against local database.
  Future<UserModel> login({required String username, required String password});

  /// Saves the current logged-in user ID.
  Future<void> cacheCurrentUser(int userId);

  /// Gets the cached current user ID.
  int? get currentUserId;

  /// Gets the cached current user.
  Future<UserModel?> getCachedCurrentUser();

  /// Clears the cached current user (logout).
  Future<void> clearCurrentUser();
}

/// Implementation of AuthLocalDataSource using SQLite.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  // Store current user ID in memory (could be SharedPreferences)
  int? _currentUserId;

  @override
  int? get currentUserId => _currentUserId;

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final db = await LocalDatabase.database;

      // Query user by username and password
      final users = await db.query(
        'users',
        where: 'username = ? AND password_hash = ? AND status = ?',
        whereArgs: [username, password, 'active'],
      );

      if (users.isEmpty) {
        throw const AuthException(
          'Nom d\'utilisateur ou mot de passe incorrect',
        );
      }

      final user = users.first;

      // Update last_login
      await db.update(
        'users',
        {'last_login': DateTime.now().toIso8601String()},
        where: 'user_id = ?',
        whereArgs: [user['user_id']],
      );

      return UserModel.fromMap(user);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw CacheException('Erreur de base de données: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheCurrentUser(int userId) async {
    _currentUserId = userId;
  }

  @override
  Future<UserModel?> getCachedCurrentUser() async {
    if (_currentUserId == null) return null;

    try {
      final db = await LocalDatabase.database;
      final users = await db.query(
        'users',
        where: 'user_id = ?',
        whereArgs: [_currentUserId],
      );

      if (users.isEmpty) return null;
      return UserModel.fromMap(users.first);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCurrentUser() async {
    _currentUserId = null;
  }
}
