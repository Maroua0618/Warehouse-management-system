import 'package:flutter/material.dart';
import 'features/shared/presentation/pages/splash.dart';
import 'features/shared/presentation/pages/onboarding.dart';
import 'features/shared/presentation/pages/login.dart';
import 'features/employee/presentation/pages/employee.dart';
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
      login: (context) => const LoginPage(),
      employee: (context) => const EmployeeScreen(),
      supervisor: (context) => const SupervisorScreen(),
    };
  }

  static String get initialRoute => splash;
}
