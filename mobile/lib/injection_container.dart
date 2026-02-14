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
import 'features/shared/data/repositories/auth_repository_impl.dart';
import 'features/shared/domain/repositories/auth_repository.dart';
import 'features/shared/presentation/cubit/auth_cubit.dart';

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

    // Add interceptors for logging, auth, etc.
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

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl<AuthLocalDataSource>(),
      useLocalOnly: true, // Always use local database for now
    ),
  );

  // Cubit (Factory - new instance each time)
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(authRepository: sl<AuthRepository>()),
  );

  // ==================== Features - Employee Dashboard ====================

  // Data Sources
  sl.registerLazySingleton<EmployeeLocalDatasource>(
    () => EmployeeLocalDatasource(),
  );

  // Cubit (Factory - takes userId parameter)
  // Default to userId 1 (employee user from sample data)
  sl.registerFactoryParam<EmployeeCubit, int, void>(
    (userId, _) => EmployeeCubit(
      datasource: sl<EmployeeLocalDatasource>(),
      currentUserId: userId,
    ),
  );
}
