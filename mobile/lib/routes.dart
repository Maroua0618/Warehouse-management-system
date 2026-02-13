import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart';
import 'features/shared/presentation/pages/splash.dart';
import 'features/shared/presentation/pages/onboarding.dart';
import 'features/employee/presentation/pages/employee.dart';
import 'features/employee/presentation/cubit/order_cubit.dart';
import 'features/supervisor/presentation/pages/supervisor.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String employee = '/employee';
  static const String supervisor = '/supervisor';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      // Employee dashboard wrapped with BlocProvider
      employee: (context) => BlocProvider<OrderCubit>(
        create: (context) => sl<OrderCubit>(),
        child: const EmployeeDashboard(),
      ),
      supervisor: (context) => const SupervisorScreen(),
    };
  }

  static String get initialRoute => splash;
}
