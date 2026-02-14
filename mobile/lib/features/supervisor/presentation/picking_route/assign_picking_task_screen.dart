import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/action_buttons.dart';
import '../../data/models/picking_route_models.dart';

/// Screen to assign worker and equipment to a picking task
class AssignPickingTaskScreen extends StatefulWidget {
  final PickingTask pickingTask;

  const AssignPickingTaskScreen({Key? key, required this.pickingTask})
    : super(key: key);

  @override
  State<AssignPickingTaskScreen> createState() =>
      _AssignPickingTaskScreenState();
}

class _AssignPickingTaskScreenState extends State<AssignPickingTaskScreen> {
  Worker? _selectedWorker;
  Equipment? _selectedEquipment;
  late List<Worker> _availableWorkers;
  late List<Equipment> _availableEquipment;

  @override
  void initState() {
    super.initState();
    _loadAvailableResources();
  }

  void _loadAvailableResources() {
    // TODO: Replace with actual Supabase query
    _availableWorkers = [
      Worker(
        id: '1',
        name: 'Felix Mendelssohn',
        role: 'Senior Picker',
        isAvailable: true,
      ),
      Worker(
        id: '2',
        name: 'Clara Schumann',
        role: 'Warehouse Staff A',
        isAvailable: true,
      ),
      Worker(
        id: '3',
        name: 'Robert Franz',
        role: 'Warehouse Staff B',
        isAvailable: true,
      ),
    ];

    _availableEquipment = [
      Equipment(
        id: '1',
        name: 'Chariot X-04',
        type: 'Standard Cart',
        isAvailable: true,
      ),
      Equipment(
        id: '2',
        name: 'Heavy Pallet',
        type: 'Pallet Jack',
        isAvailable: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDeliveryInfoCard(),
                    const SizedBox(height: 24),
                    _buildSelectRouteSection(),
                    const SizedBox(height: 24),
                    _buildWorkerSelectionSection(),
                    const SizedBox(height: 24),
                    _buildEquipmentSelectionSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Assign Picking Task',
              style: AppTextStyles.screenTitle.copyWith(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
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
                      widget.pickingTask.deliveryId,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.pickingTask.pathType,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
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
                child: _buildInfoChip(
                  icon: Icons.inventory_2_outlined,
                  label: '${widget.pickingTask.totalItems} items',
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.timer_outlined,
                  label: widget.pickingTask.estimatedTime,
                  color: const Color(0xFF0891B2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectRouteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT ROUTE',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRouteOption(
                label: 'AI Optimized',
                isSelected: true,
                icon: Icons.psychology_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRouteOption(
                label: 'Manual',
                isSelected: false,
                icon: Icons.edit_road_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteOption({
    required String label,
    required bool isSelected,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        // TODO: Implement route selection
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT WORKER',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ..._availableWorkers.map((worker) {
          final isSelected = _selectedWorker?.id == worker.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildWorkerCard(worker, isSelected),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildWorkerCard(Worker worker, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedWorker = worker;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                worker.name[0],
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Worker info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    worker.role,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 16, color: AppColors.surface),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ASSIGN EQUIPMENT',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _availableEquipment.map((equipment) {
            final isSelected = _selectedEquipment?.id == equipment.id;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: equipment == _availableEquipment.last ? 0 : 12,
                ),
                child: _buildEquipmentCard(equipment, isSelected),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEquipmentCard(Equipment equipment, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedEquipment = equipment;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              equipment.name,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              equipment.type,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    final canConfirm = _selectedWorker != null && _selectedEquipment != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: 'Confirm & Dispatch',
            icon: Icons.check,
            onPressed: canConfirm
                ? () {
                    _confirmAssignment();
                  }
                : null,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            borderRadius: 8,
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Cancel Changes',
            onPressed: () {
              Navigator.pop(context);
            },
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            borderRadius: 8,
          ),
        ],
      ),
    );
  }

  void _confirmAssignment() {
    // TODO: Implement assignment confirmation
    // Save to Supabase and dispatch task
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Task assigned to ${_selectedWorker!.name} with ${_selectedEquipment!.name}',
        ),
        backgroundColor: AppColors.success,
      ),
    );

    // Navigate back to tasks list
    Navigator.pop(context);
  }
}
