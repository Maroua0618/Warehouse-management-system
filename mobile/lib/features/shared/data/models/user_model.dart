import '../../domain/entities/user_entity.dart';

/// Data model for User that extends UserEntity.
/// Handles serialization/deserialization from database and JSON.
class UserModel extends UserEntity {
  const UserModel({
    required super.userId,
    required super.username,
    required super.fullName,
    required super.roleId,
    required super.status,
    super.lastLogin,
    required super.createdAt,
  });

  /// Creates a UserModel from a database map.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] as int,
      username: map['username'] as String,
      fullName: map['full_name'] as String,
      roleId: map['role_id'] as int,
      status: map['status'] as String,
      lastLogin: map['last_login'] != null
          ? DateTime.tryParse(map['last_login'] as String)
          : null,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Converts user model to database map.
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'username': username,
      'full_name': fullName,
      'role_id': roleId,
      'status': status,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a UserModel from a JSON map (API response).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      roleId: json['role_id'] ?? json['roleId'] ?? 0,
      status: json['status'] ?? 'active',
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'] as String)
          : null,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Converts user model to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'full_name': fullName,
      'role_id': roleId,
      'status': status,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
