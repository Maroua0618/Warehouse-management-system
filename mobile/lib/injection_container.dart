import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'core/constants/app_constants.dart';
import 'core/network/network_info.dart';
import 'features/employee/data/datasources/employee_local_datasource.dart';
import 'features/employee/data/datasources/order_local_datasource.dart';
import 'features/employee/data/datasources/order_remote_datasource.dart';
import 'features/employee/data/repositories/order_repository_impl.dart';
import 'features/employee/domain/repositories/order_repository.dart';
import 'features/employee/logic/cubit.dart';
import 'features/employee/presentation/cubit/order_cubit.dart';
import 'features/shared/data/datasources/auth_local_datasource.dart';
import 'features/shared/data/datasources/auth_remote_datasource.dart';
import 'features/shared/data/repositories/auth_repository_impl.dart';
import 'features/shared/domain/repositories/auth_repository.dart';
import 'features/shared/presentation/cubit/auth_cubit.dart';
import 'features/shared/presentation/cubit/auth_state.dart';
import 'features/employee/data/datasources/ingoing_validation_local_datasource.dart';
import 'features/employee/data/datasources/ingoing_validation_remote_datasource.dart';
import 'features/employee/data/repositories/ingoing_validation_repository_impl.dart';
import 'features/employee/domain/repositories/ingoing_validation_repository.dart';
import 'features/employee/presentation/cubit/ingoing_validation_cubit.dart';
import 'features/employee/data/datasources/outgoing_execution_remote_datasource.dart';
import 'features/employee/data/repositories/outgoing_execution_repository_impl.dart';
import 'features/employee/domain/repositories/outgoing_execution_repository.dart';
import 'features/employee/presentation/cubit/outgoing_execution_cubit.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initializes all dependencies.
/// Call this before running the app.
Future<void> initDependencies() async {
  // ==================== Core ====================

  // Network Info
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  // Dio HTTP Client
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add auth interceptor to inject Bearer token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Get auth token from AuthCubit if available
          if (sl.isRegistered<AuthCubit>()) {
            final authState = sl<AuthCubit>().state;
            if (authState is AuthAuthenticated) {
              final token = authState.user.backendToken;
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            }
          }
          return handler.next(options);
        },
      ),
    );

    // Add interceptors for logging
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[DIO] $obj'),
      ),
    );

    return dio;
  });

  // ==================== Features - Employee Orders ====================

  // Data Sources
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<OrderLocalDataSource>(
    () => OrderLocalDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      remoteDataSource: sl<OrderRemoteDataSource>(),
      localDataSource: sl<OrderLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Cubit (Factory - new instance each time)
  sl.registerFactory<OrderCubit>(
    () => OrderCubit(
      orderRepository: sl<OrderRepository>(),
      // employeeId can be passed from auth/user service
    ),
  );

  // ==================== Features - Authentication ====================

  // Data Sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl<AuthLocalDataSource>(),
      remoteDataSource: sl<AuthRemoteDataSource>(),
      useRemote: true, // Use remote backend API
    ),
  );

  // Cubit (Singleton - shared instance across app to preserve auth state)
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(authRepository: sl<AuthRepository>()),
  );

  // ==================== Features - Employee Dashboard ====================

  // Data Sources
  sl.registerLazySingleton<EmployeeLocalDatasource>(
    () => EmployeeLocalDatasource(),
  );

  // Cubit (Factory - takes userId parameter)
  // Default to userId 1 (employee user from sample data)
  sl.registerFactory<EmployeeCubit>(
    () => EmployeeCubit(
      datasource: sl<EmployeeLocalDatasource>(),
      authCubit: sl<AuthCubit>(),
    ),
  );

  // ==================== Features - Ingoing Validation ====================

  // Data Sources
  sl.registerLazySingleton<IngoingValidationRemoteDataSource>(
    () => IngoingValidationRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<IngoingValidationLocalDataSource>(
    () => IngoingValidationLocalDataSourceStub(),
  );

  // Repository
  sl.registerLazySingleton<IngoingValidationRepository>(
    () => IngoingValidationRepositoryImpl(
      remoteDataSource: sl<IngoingValidationRemoteDataSource>(),
      localDataSource: sl<IngoingValidationLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Cubit
  sl.registerFactory<IngoingValidationCubit>(
    () => IngoingValidationCubit(repository: sl<IngoingValidationRepository>()),
  );

  // ==================== Features - Outgoing Execution ====================

  // Data Sources
  sl.registerLazySingleton<OutgoingExecutionRemoteDataSource>(
    () => OutgoingExecutionRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<OutgoingExecutionRepository>(
    () => OutgoingExecutionRepositoryImpl(
      remoteDataSource: sl<OutgoingExecutionRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Cubit
  sl.registerFactory<OutgoingExecutionCubit>(
    () => OutgoingExecutionCubit(repository: sl<OutgoingExecutionRepository>()),
  );
}
