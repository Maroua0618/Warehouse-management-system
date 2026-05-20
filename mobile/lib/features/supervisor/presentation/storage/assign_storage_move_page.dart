import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/storage_move_models.dart';
import '../widgets/action_buttons.dart';
import 'task_dispatched_page.dart';

class AssignStorageMovePage extends StatefulWidget {
  final StorageMove move;

  const AssignStorageMovePage({super.key, required this.move});

  @override
  State<AssignStorageMovePage> createState() => _AssignStorageMovePageState();
}

class _AssignStorageMovePageState extends State<AssignStorageMovePage> {
  Employee? _selectedEmployee;

  // Sample employees - replace with actual API call
  final List<Employee> _employees = [
    Employee(
      id: '1',
      name: 'Marcus Thorne',
      email: 'marcus.thorne@example.com',
      role: 'Warehouse A',
      status: 'ACTIVE',
      currentZone: 'Zone A',
      isAvailable: true,
    ),
    Employee(
      id: '2',
      name: 'Sarah Jenkins',
      email: 'sarah.jenkins@example.com',
      role: 'Warehouse A',
      status: 'ACTIVE',
      currentZone: 'Zone A-02',
      isAvailable: true,
    ),
    Employee(
      id: '3',
      name: 'Jackson Lee',
      email: 'jackson.lee@example.com',
      role: 'Finishing Move',
      status: 'ACTIVE',
      currentZone: 'Zone B',
      isAvailable: false,
    ),
  ];

  List<Employee> get _availableEmployees {
    return _employees.where((e) => e.isAvailable).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Attribuer Mouvement de Stock',
          style: AppTextStyles.screenTitle.copyWith(
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Move Summary
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RÉSUMÉ DU MOUVEMENT',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID PRODUIT',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.move.sku?.skuCode ?? widget.move.productId,
                            style: AppTextStyles.sku.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        label: 'SOURCE',
                        value:
                            widget.move.sourceLocation?.code ??
                            widget.move.sourceLocationId,
                        icon: Icons.warehouse_outlined,
                        iconColor: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        label: 'DESTINATION',
                        value:
                            widget.move.destinationLocation?.code ??
                            widget.move.destinationLocationId,
                        icon: Icons.location_on_outlined,
                        iconColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Employee Selection Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SÉLECTIONNER EMPLOYÉ',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_availableEmployees.length} DISPONIBLE(S)',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _employees.length,
                      itemBuilder: (context, index) {
                        final employee = _employees[index];
                        return _EmployeeCard(
                          employee: employee,
                          isSelected: _selectedEmployee?.id == employee.id,
                          onTap: employee.isAvailable
                              ? () {
                                  setState(() {
                                    _selectedEmployee = employee;
                                  });
                                }
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confirm Button
          BottomActionContainer(
            child: PrimaryButton(
              label: 'Confirmer & Attribuer',
              icon: Icons.check_circle,
              onPressed: _selectedEmployee != null ? _handleConfirm : null,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  void _handleConfirm() {
    if (_selectedEmployee == null) return;

    final updatedMove = widget.move.copyWith(
      assignedToUserId: _selectedEmployee!.id,
      assignedEmployee: _selectedEmployee,
      status: TaskStatus.IN_PROGRESS,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDispatchedPage(
          move: updatedMove,
          assignedEmployee: _selectedEmployee!,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final Employee employee;
  final bool isSelected;
  final VoidCallback? onTap;

  const _EmployeeCard({
    required this.employee,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = employee.isAvailable;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.textSecondary.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isAvailable
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.textSecondary.withOpacity(0.1),
                  child: Text(
                    employee.name.substring(0, 1).toUpperCase(),
                    style: AppTextStyles.cardTitle.copyWith(
                      color: isAvailable
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: isAvailable
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAvailable
                            ? '${employee.role} • ${employee.currentZone ?? "Disponible"}'
                            : '⏰ Occupé • ${employee.role}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: AppColors.surface,
                      size: 16,
                    ),
                  )
                else if (!isAvailable)
                  Icon(
                    Icons.schedule,
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
}
