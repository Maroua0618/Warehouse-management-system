import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/command_entity.dart';
import '../../domain/repositories/ingoing_validation_repository.dart';
import '../datasources/ingoing_validation_local_datasource.dart';
import '../datasources/ingoing_validation_remote_datasource.dart';

/// Implementation of IngoingValidationRepository.
/// Coordinates between remote and local data sources.
class IngoingValidationRepositoryImpl implements IngoingValidationRepository {
  final IngoingValidationRemoteDataSource remoteDataSource;
  final IngoingValidationLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  IngoingValidationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, CommandEntity>> getValidation(String orderId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteValidation = await remoteDataSource.getValidation(orderId);
        // TODO: Caching logic might need to be updated for CommandEntity
        // await localDataSource.cacheValidation(remoteValidation as IngoingValidationModel);
        return Right(remoteValidation);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      // TODO: Local data source logic for CommandEntity
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, CommandEntity>> validateProduct(String orderId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      final updatedValidation = await remoteDataSource.validateProduct(orderId);
      // TODO: Caching logic might need to be updated for CommandEntity
      // await localDataSource.updateValidation(updatedValidation);
      return Right(updatedValidation);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CommandEntity>> validateTask(
    String orderId, {
    List<String>? validatedItems,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      final updatedValidation = await remoteDataSource.validateTask(
        orderId,
        validatedItems: validatedItems,
      );
      return Right(updatedValidation);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CommandEntity>> validateItem(
    String orderId,
    String itemId,
    String pathStepId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      final updatedValidation = await remoteDataSource.validateItem(
        orderId,
        itemId,
        pathStepId,
      );
      // TODO: Caching logic might need to be updated for CommandEntity
      // await localDataSource.updateValidation(updatedValidation);
      return Right(updatedValidation);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> reportProblem(
    String orderId,
    String category,
    String description,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      final result = await remoteDataSource.reportProblem(
        orderId,
        category,
        description,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> completeValidation(String orderId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      final result = await remoteDataSource.completeValidation(orderId);
      if (result) {
        await localDataSource.deleteValidation(orderId);
      }
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // TODO: Implement caching and local data source logic
  @override
  Future<Either<Failure, void>> cacheValidation(
    CommandEntity validation,
  ) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, CommandEntity>> getCachedValidation(
    String orderId,
  ) async {
    return const Left(CacheFailure('Not implemented'));
  }
}
