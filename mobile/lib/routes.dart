import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart';
import 'features/shared/presentation/pages/splash.dart';
import 'features/shared/presentation/pages/onboarding.dart';
import 'features/shared/presentation/pages/login.dart';
import 'features/shared/data/datasources/auth_local_datasource.dart';
import 'features/employee/presentation/pages/employee.dart';
import 'features/employee/logic/cubit.dart';
import 'features/employee/presentation/cubit/mock_order_cubit.dart';
import 'features/employee/presentation/cubit/mock_ingoing_validation_cubit.dart';
import 'features/supervisor/presentation/pages/supervisor.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String employee = '/employee';
  static const String supervisor = '/supervisor';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      // Login page - uses Supabase auth directly
      login: (context) => const LoginPage(),
      // Employee dashboard with all required cubits
      employee: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<EmployeeCubit>(
            create: (context) {
              // Get current user ID from auth datasource, default to 1
              final authDataSource = sl<AuthLocalDataSource>();
              final userId = authDataSource.currentUserId ?? 1;
              return sl<EmployeeCubit>(param1: userId)..initialize();
            },
          ),
          BlocProvider<MockOrderCubit>(create: (context) => MockOrderCubit()),
          BlocProvider<MockIngoingValidationCubit>(
            create: (context) => MockIngoingValidationCubit(),
          ),
        ],
        child: const EmployeeDashboard(),
      ),
      supervisor: (context) => const SupervisorScreen(),
    };
  }

  static String get initialRoute => splash;
}
