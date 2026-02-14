import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/command_entity.dart';
import '../../domain/repositories/outgoing_execution_repository.dart';
import '../datasources/outgoing_execution_remote_datasource.dart';

/// Implementation of OutgoingExecutionRepository.
class OutgoingExecutionRepositoryImpl implements OutgoingExecutionRepository {
  final OutgoingExecutionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OutgoingExecutionRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, CommandEntity>> getExecution(String orderId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteExecution = await remoteDataSource.getExecution(orderId);
        return Right(remoteExecution);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, CommandEntity>> pickItem(
    String orderId,
    String itemId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      final updatedExecution = await remoteDataSource.pickItem(orderId, itemId);
      return Right(updatedExecution);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CommandEntity>> confirmDelivery(String orderId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      final updatedExecution = await remoteDataSource.confirmDelivery(orderId);
      return Right(updatedExecution);
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
  Future<Either<Failure, bool>> completeExecution(String orderId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      final result = await remoteDataSource.completeExecution(orderId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
