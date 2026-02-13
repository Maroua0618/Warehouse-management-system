import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

/// Implementation of AuthRepository.
/// Currently always uses local database for authentication.
/// Can be extended to support remote authentication when needed.
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  // final AuthRemoteDataSource remoteDataSource; // For future remote auth
  // final NetworkInfo networkInfo; // For future network check

  /// When true, always use local database regardless of network.
  /// Set to false when remote authentication is implemented.
  final bool useLocalOnly;

  AuthRepositoryImpl({
    required this.localDataSource,
    this.useLocalOnly = true, // Default to local-only for now
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  }) async {
    // For now, always use local database
    // In the future, check useLocalOnly and networkInfo.isConnected
    // to decide between remote and local authentication

    if (useLocalOnly) {
      return _loginLocal(username: username, password: password);
    }

    // Future implementation for remote auth:
    // if (await networkInfo.isConnected) {
    //   return _loginRemote(username: username, password: password);
    // } else {
    //   return _loginLocal(username: username, password: password);
    // }

    return _loginLocal(username: username, password: password);
  }

  /// Authenticate using local SQLite database.
  Future<Either<Failure, UserEntity>> _loginLocal({
    required String username,
    required String password,
  }) async {
    try {
      final user = await localDataSource.login(
        username: username,
        password: password,
      );

      // Cache the logged-in user
      await localDataSource.cacheCurrentUser(user.userId);

      return Right(user);
    } on AuthException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erreur inattendue: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearCurrentUser();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erreur de déconnexion: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(CacheFailure('Erreur de récupération: ${e.toString()}'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final result = await getCurrentUser();
    return result.fold((_) => false, (user) => user != null);
  }
}
