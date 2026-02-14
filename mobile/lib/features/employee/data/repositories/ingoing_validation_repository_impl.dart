import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/ingoing_validation_entity.dart';
import '../../domain/repositories/ingoing_validation_repository.dart';
import '../datasources/ingoing_validation_local_datasource.dart';
import '../datasources/ingoing_validation_remote_datasource.dart';
import '../models/ingoing_validation_model.dart';

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
  Future<Either<Failure, IngoingValidationEntity>> getValidation(
    String orderId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteValidation = await remoteDataSource.getValidation(orderId);
        await localDataSource.cacheValidation(remoteValidation);
        return Right(remoteValidation);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final localValidation = await localDataSource.getValidation(orderId);
        return Right(localValidation);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, IngoingValidationEntity>> validateProduct(
    String orderId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      final updatedValidation = await remoteDataSource.validateProduct(orderId);
      await localDataSource.updateValidation(updatedValidation);
      return Right(updatedValidation);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, IngoingValidationEntity>> validateItem(
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
      await localDataSource.updateValidation(updatedValidation);
      return Right(updatedValidation);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> reportProblem(
    String orderId,
    String description,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      final result = await remoteDataSource.reportProblem(orderId, description);
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

  @override
  Future<Either<Failure, void>> cacheValidation(
    IngoingValidationEntity validation,
  ) async {
    try {
      final model = IngoingValidationModel.fromEntity(validation);
      await localDataSource.cacheValidation(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, IngoingValidationEntity>> getCachedValidation(
    String orderId,
  ) async {
    try {
      final validation = await localDataSource.getValidation(orderId);
      return Right(validation);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
