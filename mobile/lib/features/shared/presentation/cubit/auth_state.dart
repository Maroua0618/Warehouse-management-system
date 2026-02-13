import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Base state for authentication.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - checking if user is already logged in.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - login in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state - user is logged in.
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state - no user logged in.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error state - authentication failed.
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
