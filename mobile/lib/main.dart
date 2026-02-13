import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/database/local_database.dart';
import 'core/theme/app_theme.dart';
import 'features/employee/data/datasources/employee_local_datasource.dart';
import 'features/employee/logic/cubit.dart';
import 'features/employee/presentation/cubit/mock_order_cubit.dart';
import 'features/employee/presentation/cubit/mock_ingoing_validation_cubit.dart';
import 'features/employee/presentation/pages/employee.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for desktop platforms
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize the local database
  await LocalDatabase.database;

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const BmsApp());
}

/// Main BMS application with database-backed cubits
class BmsApp extends StatelessWidget {
  const BmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMS - Warehouse Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: MultiBlocProvider(
        providers: [
          // Main employee cubit with database
          BlocProvider<EmployeeCubit>(
            create: (context) => EmployeeCubit(
              datasource: EmployeeLocalDatasource(),
              currentUserId: 1, // Default employee user
            )..initialize(),
          ),
          // Mock cubits for order display (temporarily kept for compatibility)
          BlocProvider<MockOrderCubit>(create: (context) => MockOrderCubit()),
          BlocProvider<MockIngoingValidationCubit>(
            create: (context) => MockIngoingValidationCubit(),
          ),
        ],
        child: const EmployeeDashboard(),
      ),
    );
  }
}
