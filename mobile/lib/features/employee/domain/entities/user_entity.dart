import 'package:equatable/equatable.dart';

/// Domain entity representing a user in the system.
class UserEntity extends Equatable {
  final int id;
  final String username;
  final String fullName;
  final int roleId;
  final String roleName;
  final String status;
  final DateTime? lastLogin;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.username,
    required this.fullName,
    required this.roleId,
    required this.roleName,
    required this.status,
    this.lastLogin,
    required this.createdAt,
  });

  bool get isEmployee => roleId == 1;
  bool get isSupervisor => roleId == 2;
  bool get isActive => status == 'active';

  /// Get initials from full name
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, 2).toUpperCase();
  }

  UserEntity copyWith({
    int? id,
    String? username,
    String? fullName,
    int? roleId,
    String? roleName,
    String? status,
    DateTime? lastLogin,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      status: status ?? this.status,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    fullName,
    roleId,
    roleName,
    status,
    lastLogin,
    createdAt,
  ];
}
