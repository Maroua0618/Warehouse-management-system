import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Abstract repository interface for Authentication operations.
/// This defines the contract that the data layer must implement.
///
/// The repository coordinates between remote and local data sources:
/// - If online: Authenticate with remote API
/// - If offline: Authenticate with local database
abstract class AuthRepository {
  /// Authenticates a user with username and password.
  ///
  /// Parameters:
  /// - [username]: The user's username
  /// - [password]: The user's password
  ///
  /// Returns:
  /// - [Right(UserEntity)]: Success with authenticated user
  /// - [Left(Failure)]: Error with failure details
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  });

  /// Logs out the current user.
  Future<Either<Failure, void>> logout();

  /// Gets the currently logged-in user.
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Checks if user is currently logged in.
  Future<bool> isLoggedIn();
}
