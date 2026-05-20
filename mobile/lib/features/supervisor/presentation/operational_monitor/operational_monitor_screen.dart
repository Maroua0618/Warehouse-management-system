import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/operational_monitor_models.dart';
import '../widgets/bottom_nav_bar.dart';
import '../pages/supervisor_dashboard.dart';
import '../pages/calendar.dart';
import 'detailed_map_screen.dart';

/// Screen showing live operational monitoring with employee tracking
class OperationalMonitorScreen extends StatefulWidget {
  const OperationalMonitorScreen({Key? key}) : super(key: key);

  @override
  State<OperationalMonitorScreen> createState() =>
      _OperationalMonitorScreenState();
}

class _OperationalMonitorScreenState extends State<OperationalMonitorScreen> {
  String selectedFloor = 'RDC';

  // Mock data - will be replaced with real-time data from Supabase
  late List<Employee> _employees;
  late List<OperationalAlert> _alerts;
  late OperationalStats _stats;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  String _getFloorImage(String floor) {
    switch (floor) {
      case 'RDC':
        return 'assets/picking floor.png';
      case 'Floor 1':
      case 'Floor 2':
        return 'assets/First and second storage floors.png';
      case 'Floor 3':
      case 'Floor 4':
        return 'assets/Third and fourth storage floors.png';
      default:
        return 'assets/picking floor.png';
    }
  }

  void _initializeMockData() {
    _employees = [
      Employee(
        id: 'EMP-01',
        name: 'Alice Martin',
        status: EmployeeStatus.active,
        role: 'Picker',
        location: EmployeeLocation(
          x: 0.2,
          y: 0.3,
          aisle: 'Aisle 04',
          destination: 'Dock B',
        ),
        assignedTask: 'Picking Order #2345',
        path: [
          EmployeeLocation(x: 0.15, y: 0.25, aisle: 'Aisle 03'),
          EmployeeLocation(x: 0.2, y: 0.3, aisle: 'Aisle 04'),
        ],
      ),
      Employee(
        id: 'EMP-02',
        name: 'Bob Wilson',
        status: EmployeeStatus.idle,
        role: 'Forklift Operator',
        location: EmployeeLocation(
          x: 0.5,
          y: 0.6,
          aisle: 'Aisle 12',
          destination: 'Station A',
        ),
        assignedTask: 'Idle',
      ),
      Employee(
        id: 'EMP-03',
        name: 'Carol Davis',
        status: EmployeeStatus.standby,
        role: 'Warehouse Associate',
        location: EmployeeLocation(x: 0.7, y: 0.4, aisle: 'Station A-4'),
        assignedTask: 'Standby',
      ),
      Employee(
        id: 'EMP-04',
        name: 'David Chen',
        status: EmployeeStatus.active,
        role: 'Delivery Driver',
        location: EmployeeLocation(
          x: 0.4,
          y: 0.7,
          aisle: 'Aisle 08',
          destination: 'Dock A',
        ),
        assignedTask: 'Delivery Run #1234',
        path: [
          EmployeeLocation(x: 0.35, y: 0.65, aisle: 'Aisle 07'),
          EmployeeLocation(x: 0.4, y: 0.7, aisle: 'Aisle 08'),
        ],
      ),
    ];

    _alerts = [
      OperationalAlert(
        type: AlertType.trafficJam,
        title: 'Traffic Jam: Aisle 4',
        description: '3 employees converging in narrow section',
        employeeId: 'EMP-01',
        canResolve: true,
      ),
      OperationalAlert(
        type: AlertType.delayedTask,
        title: 'Delayed Task: EMP-12',
        description: 'Task running 20 minutes behind schedule',
        employeeId: 'EMP-12',
        canResolve: false,
      ),
    ];

    _stats = OperationalStats(
      activeEmployees: 7,
      completedOrders: 2,
      zoneEfficiency: 94,
      currentFloor: selectedFloor,
      executionProgress: [
        ExecutionProgress(
          label: 'RECEIPT',
          percentage: 85,
          completed: 17,
          total: 20,
        ),
        ExecutionProgress(
          label: 'STORAGE',
          percentage: 60,
          completed: 12,
          total: 20,
        ),
        ExecutionProgress(
          label: 'PICKING',
          percentage: 42,
          completed: 8,
          total: 19,
        ),
        ExecutionProgress(
          label: 'DELIVERY',
          percentage: 11,
          completed: 2,
          total: 18,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildStatsCards(),
              _buildFloorSelector(),
              _buildMiniMap(),
              _buildAlertsSection(),
              _buildExecutionProgress(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2, onTap: _onNavBarTap),
    );
  }

  void _onNavBarTap(int index) {
    if (index == 0) {
      // Navigate to Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SupervisorDashboardScreen(),
        ),
      );
    } else if (index == 1) {
      // Navigate to Calendar
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AIDecisionsEmptyScreen()),
      );
    }
    // index 2 = Map (current page)
    // index 3 = Profile
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Carte - Suivi en Direct',
            style: AppTextStyles.screenTitle.copyWith(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              label: 'ACTIVE\nEMPLOYEES',
              value: '${_stats.activeEmployees}',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              label: 'COMPLETED\nORDERS',
              value: '${_stats.completedOrders}',
              color: const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              label: 'ZONE\nEFFICIENCY',
              value: '${_stats.zoneEfficiency}%',
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.sectionHeader.copyWith(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorSelector() {
    final floors = ['RDC', 'Floor 1', 'Floor 2', 'Floor 3', 'Floor 4'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'FLOOR:',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: floors.map((floor) {
                  final isSelected = floor == selectedFloor;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => selectedFloor = floor),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          floor,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMap() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: Stack(
          children: [
            // Map background
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                _getFloorImage(selectedFloor),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.3),
              ),
            ),

            // Employee markers
            ..._employees.map(
              (employee) => _buildEmployeeMarker(employee, isMini: true),
            ),

            // View detailed map button
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailedMapScreen(
                        employees: _employees,
                        floor: selectedFloor,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'VIEW DETAILED MAP',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.primary,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeMarker(Employee employee, {bool isMini = false}) {
    Color markerColor;
    switch (employee.status) {
      case EmployeeStatus.active:
        markerColor = const Color(0xFF10B981);
        break;
      case EmployeeStatus.idle:
        markerColor = const Color(0xFFF59E0B);
        break;
      case EmployeeStatus.standby:
        markerColor = const Color(0xFF3B82F6);
        break;
      case EmployeeStatus.offline:
        markerColor = const Color(0xFFEF4444);
        break;
    }

    return Positioned(
      left: employee.location.x * (isMini ? 300 : 350),
      top: employee.location.y * (isMini ? 180 : 450),
      child: Container(
        width: isMini ? 24 : 32,
        height: isMini ? 24 : 32,
        decoration: BoxDecoration(
          color: markerColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: markerColor.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: isMini ? 14 : 18,
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Alerts & Issues',
                style: AppTextStyles.sectionHeader.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.add_circle_outline,
                color: AppColors.failure,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._alerts.map((alert) => _buildAlertCard(alert)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(OperationalAlert alert) {
    Color alertColor;
    IconData alertIcon;

    switch (alert.type) {
      case AlertType.trafficJam:
        alertColor = const Color(0xFFEF4444);
        alertIcon = Icons.traffic;
        break;
      case AlertType.lowBattery:
        alertColor = const Color(0xFFF59E0B);
        alertIcon = Icons.battery_alert;
        break;
      case AlertType.delayedTask:
        alertColor = const Color(0xFFF59E0B);
        alertIcon = Icons.schedule;
        break;
      case AlertType.equipmentMalfunction:
        alertColor = const Color(0xFFEF4444);
        alertIcon = Icons.warning;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alertColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: alertColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(alertIcon, color: alertColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (alert.canResolve)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Resolve',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExecutionProgress() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Execution Progress',
                style: AppTextStyles.sectionHeader.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'VIEW FULL REPORT',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, color: AppColors.primary, size: 14),
            ],
          ),
          const SizedBox(height: 16),
          ..._stats.executionProgress.map(
            (progress) => _buildProgressBar(progress),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ExecutionProgress progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progress.label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                '${progress.percentage}%',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.percentage / 100,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
