import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/command_entity.dart';
import '../../logic/cubit.dart';
import '../cubit/mock_ingoing_validation_cubit.dart';
import 'outgoing_execution_page.dart';
import 'ingoing_validation_page.dart';
import 'order_already_validated_page.dart';
import 'profile_page.dart';

/// Employee Task Dashboard - Main screen for employees
/// Shows current zone and today's tasks (ingoing/outgoing orders)
class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  bool _showOutgoingOrders = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeCubit, EmployeeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(state),
                Expanded(child: _buildBody(state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(EmployeeState state) {
    if (state is EmployeeLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is EmployeeError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.failure),
            const SizedBox(height: 16),
            Text(state.message, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<EmployeeCubit>().initialize(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildCurrentZone(), _buildTodaysTasks(state)],
      ),
    );
  }

  Widget _buildHeader(EmployeeState state) {
    // Get user info from state
    String initials = 'EM';
    String userName = 'Employé';

    if (state is EmployeeLoaded) {
      final fullName = state.currentUser.fullName;
      userName = fullName;
      // Get initials from full name
      final nameParts = fullName.split(' ');
      if (nameParts.length >= 2) {
        initials = '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      } else if (nameParts.isNotEmpty) {
        initials = nameParts[0].substring(0, 2).toUpperCase();
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar - clickable for profile
              GestureDetector(
                onTap: () => _navigateToProfile(),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Employee info - clickable for profile
              Expanded(
                child: GestureDetector(
                  onTap: () => _navigateToProfile(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMPLOYÉ',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textOnPrimary.withOpacity(0.8),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userName,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Notification icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Tab switcher
          _buildTabSwitcher(),
        ],
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmployeeProfileScreen()),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              label: 'COMMANDES SORTANTES',
              isSelected: _showOutgoingOrders,
              onTap: () => setState(() => _showOutgoingOrders = true),
            ),
          ),
          Expanded(
            child: _buildTab(
              label: 'COMMANDES ENTRANTES',
              isSelected: !_showOutgoingOrders,
              onTap: () => setState(() => _showOutgoingOrders = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? AppColors.primary : Colors.white,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0.3,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentZone() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zone Actuelle',
            style: AppTextStyles.sectionHeader.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Background image
                  Positioned.fill(
                    child: SvgPicture.asset(
                      'assets/Warehouse shelves abstract.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Light overlay for better contrast
                  Positioned.fill(
                    child: Container(color: Colors.white.withOpacity(0.1)),
                  ),
                  // Zone badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
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
                          Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Zone A-14',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysTasks(EmployeeState state) {
    final now = DateTime.now();
    final dateStr = '${_getMonthName(now.month)} ${now.day}, ${now.year}';

    // Get orders from state
    List<CommandEntity> orders = [];
    if (state is EmployeeLoaded) {
      orders = _showOutgoingOrders
          ? state.outgoingOrders
          : state.incomingOrders;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "Tâches du Jour",
                style: AppTextStyles.sectionHeader.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                dateStr,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (orders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucune commande pour le moment',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...orders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTaskCard(
                  orderId: order.displayOrderId,
                  location: order.displayLocation,
                  itemCount: order.totalItems,
                  status: order.frenchStatus,
                  time: order.displayTime,
                  isValidated: order.isValidated,
                  isOutgoing: _showOutgoingOrders,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return months[month - 1];
  }

  Widget _buildTaskCard({
    required String orderId,
    required String location,
    required int itemCount,
    required String status,
    required String time,
    required bool isValidated,
    bool isOutgoing = false,
  }) {
    final statusColor = isValidated ? AppColors.success : AppColors.accent;
    final icon = isValidated
        ? Icons.check_circle_outline
        : Icons.inventory_2_outlined;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToTask(orderId),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                // Order info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderId,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isOutgoing ? Icons.location_on : Icons.access_time,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOutgoing ? location : time,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.grid_view,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$itemCount Articles',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.badge.copyWith(
                      color: statusColor,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Arrow icon
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToTask(String orderId) async {
    // Get current state to access orders
    final state = context.read<EmployeeCubit>().state;
    if (state is! EmployeeLoaded) return;

    if (_showOutgoingOrders) {
      // Find the order from loaded state
      final orders = state.outgoingOrders;
      final order = orders
          .where((o) => o.displayOrderId == orderId)
          .firstOrNull;

      if (order?.isValidated == true) {
        // Show already validated page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderAlreadyValidatedPage(
              orderId: orderId,
              isOutgoing: true,
              deliveryId: 'WH-88293',
              skuReference: orderId,
            ),
          ),
        );
        return;
      }

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => OutgoingExecutionPage(orderId: orderId),
        ),
      );

      // If validated, refresh from database
      if (result == true) {
        context.read<EmployeeCubit>().refresh();
      }
    } else {
      // Find the order from loaded state
      final orders = state.incomingOrders;
      final order = orders
          .where((o) => o.displayOrderId == orderId)
          .firstOrNull;

      if (order?.isValidated == true) {
        // Show already validated page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderAlreadyValidatedPage(
              orderId: orderId,
              isOutgoing: false,
              deliveryId: 'WH-88293',
              skuReference: 'SKU-9902-BX',
            ),
          ),
        );
        return;
      }

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => MockIngoingValidationCubit(),
            child: IngoingValidationPage(orderId: orderId),
          ),
        ),
      );

      // If validated, refresh from database
      if (result == true) {
        context.read<EmployeeCubit>().refresh();
      }
    }
  }
}
