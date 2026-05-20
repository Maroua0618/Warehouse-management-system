import '../../domain/entities/user_entity.dart';

/// Data model for User with JSON/DB serialization.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.fullName,
    required super.roleId,
    required super.roleName,
    required super.status,
    super.lastLogin,
    required super.createdAt,
  });

  /// Create from database row
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['user_id'] as int,
      username: map['username'] as String,
      fullName: map['full_name'] as String,
      roleId: map['role_id'] as int,
      roleName: map['role_name'] as String? ?? 'Employee',
      status: map['status'] as String,
      lastLogin: map['last_login'] != null
          ? DateTime.parse(map['last_login'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'user_id': id,
      'username': username,
      'full_name': fullName,
      'role_id': roleId,
      'status': status,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] as int,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      roleId: json['role_id'] as int,
      roleName: json['role_name'] as String? ?? 'Employee',
      status: json['status'] as String,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => toMap();

  /// Create from entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      fullName: entity.fullName,
      roleId: entity.roleId,
      roleName: entity.roleName,
      status: entity.status,
      lastLogin: entity.lastLogin,
      createdAt: entity.createdAt,
    );
  }
}
