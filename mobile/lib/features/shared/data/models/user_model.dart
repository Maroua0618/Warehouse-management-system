import '../../domain/entities/user_entity.dart';

/// Data model for User that extends UserEntity.
/// Handles serialization/deserialization from database and JSON.
class UserModel extends UserEntity {
  const UserModel({
    required super.userId,
    required super.email,
    required super.fullName,
    required super.role,
    required super.status,
    super.backendToken,
    super.supabaseToken,
  });

  /// Creates a UserModel from a database map.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['id'] as String? ?? map['user_id'] as String,
      email: map['email'] as String,
      fullName: map['name'] as String? ?? map['full_name'] as String,
      role: map['role'] as String,
      status: map['status'] as String,
      backendToken: map['backend_token'] as String?,
      supabaseToken: map['supabase_token'] as String?,
    );
  }

  /// Converts user model to database map.
  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'email': email,
      'name': fullName,
      'role': role,
      'status': status,
      'backend_token': backendToken,
      'supabase_token': supabaseToken,
    };
  }

  /// Creates a UserModel from a JSON map (API response).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['id'] as String? ?? json['user_id'] as String,
      email: json['email'] as String,
      fullName: json['name'] as String? ?? json['full_name'] as String,
      role: json['role'] as String,
      status: json['status'] as String? ?? 'ACTIVE',
      backendToken: json['backend_token'] as String?,
      supabaseToken: json['supabase_token'] as String?,
    );
  }

  /// Converts user model to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'email': email,
      'name': fullName,
      'role': role,
      'status': status,
      'backend_token': backendToken,
      'supabase_token': supabaseToken,
    };
  }
}
