import 'package:equatable/equatable.dart';

/// Domain entity representing a user in the system.
class UserEntity extends Equatable {
  final int userId;
  final String username;
  final String fullName;
  final int roleId;
  final String status;
  final DateTime? lastLogin;
  final DateTime createdAt;

  const UserEntity({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.roleId,
    required this.status,
    this.lastLogin,
    required this.createdAt,
  });

  /// Returns the role name based on roleId
  String get roleName {
    switch (roleId) {
      case 1:
        return 'employee';
      case 2:
        return 'supervisor';
      default:
        return 'unknown';
    }
  }

  /// Check if user is an employee
  bool get isEmployee => roleId == 1;

  /// Check if user is a supervisor
  bool get isSupervisor => roleId == 2;

  @override
  List<Object?> get props => [
    userId,
    username,
    fullName,
    roleId,
    status,
    lastLogin,
    createdAt,
  ];
}
