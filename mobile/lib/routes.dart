import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart';
import 'features/shared/presentation/pages/splash.dart';
import 'features/shared/presentation/pages/onboarding.dart';
import 'features/shared/presentation/pages/login.dart';
import 'features/employee/presentation/pages/employee.dart';
import 'features/employee/logic/cubit.dart';
import 'features/employee/presentation/cubit/mock_order_cubit.dart';
import 'features/supervisor/presentation/pages/supervisor_dashboard.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String employee = '/employee';
  static const String supervisor = '/supervisor';
  static const String bonDeCommande = '/bon-de-commande';
  static const String pickingTasks = '/picking-tasks';
  static const String operationalMonitor = '/operational-monitor';

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
              return sl<EmployeeCubit>()..initialize();
            },
          ),
          BlocProvider<MockOrderCubit>(create: (context) => MockOrderCubit()),
        ],
        child: const EmployeeDashboard(),
      ),
      supervisor: (context) => const SupervisorDashboardScreen(),
    };
  }

  static String get initialRoute =>
      splash; // Change this to splash or onboarding as needed
}
