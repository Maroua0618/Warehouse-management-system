import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of AuthRepository.
/// Uses remote backend API for authentication.
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;

  /// When true, uses remote backend API; false uses local database.
  final bool useRemote;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    this.useRemote = true, // Default to remote backend
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  }) async {
    if (useRemote) {
      return _loginRemote(email: username, password: password);
    } else {
      return _loginLocal(username: username, password: password);
    }
  }

  /// Authenticate using remote backend API.
  Future<Either<Failure, UserEntity>> _loginRemote({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await remoteDataSource.login(
        email: email,
        password: password,
      );

      final user = UserEntity(
        userId: authResponse.userId,
        email: authResponse.email,
        fullName: authResponse.name,
        role: authResponse.role,
        status: 'ACTIVE',
        backendToken: authResponse.backendToken,
        supabaseToken: authResponse.supabaseToken,
      );

      return Right(user);
    } on AuthException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erreur de connexion: ${e.toString()}'));
    }
  }

  /// Authenticate using local SQLite database (fallback).
  Future<Either<Failure, UserEntity>> _loginLocal({
    required String username,
    required String password,
  }) async {
    try {
      final user = await localDataSource.login(
        username: username,
        password: password,
      );

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
      if (useRemote) {
        await remoteDataSource.logout();
      } else {
        await localDataSource.clearCurrentUser();
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erreur de déconnexion: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      if (useRemote) {
        final authResponse = await remoteDataSource.getCurrentUser();
        if (authResponse == null) return const Right(null);

        final user = UserEntity(
          userId: authResponse.userId,
          email: authResponse.email,
          fullName: authResponse.name,
          role: authResponse.role,
          status: 'ACTIVE',
          backendToken: authResponse.backendToken,
          supabaseToken: authResponse.supabaseToken,
        );
        return Right(user);
      } else {
        final user = await localDataSource.getCachedCurrentUser();
        return Right(user);
      }
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
