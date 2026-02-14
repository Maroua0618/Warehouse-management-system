import 'package:equatable/equatable.dart';

/// Domain entity representing a user in the system.
class UserEntity extends Equatable {
  final String userId;
  final String email;
  final String fullName;
  final String role;
  final String status;
  final String? backendToken;
  final String? supabaseToken;

  const UserEntity({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    required this.status,
    this.backendToken,
    this.supabaseToken,
  });

  /// Returns the role name (already a string)
  String get roleName => role.toLowerCase();

  /// Check if user is an employee
  bool get isEmployee => role.toUpperCase() == 'EMPLOYEE';

  /// Check if user is a supervisor
  bool get isSupervisor => role.toUpperCase() == 'SUPERVISOR';

  /// Backward compatibility - username is email
  String get username => email;

  /// Get initials from full name
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1)
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  List<Object?> get props => [
    userId,
    email,
    fullName,
    role,
    status,
    backendToken,
    supabaseToken,
  ];
}
