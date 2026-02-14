import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/action_buttons.dart';
import '../../data/models/picking_route_models.dart';
import 'override_picking_route_screen.dart';
import 'assign_picking_task_screen.dart';

/// Main screen for Picking Tasks (Itinéraire de Prélèvement)
/// Displays picking tasks with route optimization
class PickingTasksScreen extends StatefulWidget {
  const PickingTasksScreen({Key? key}) : super(key: key);

  @override
  State<PickingTasksScreen> createState() => _PickingTasksScreenState();
}

class _PickingTasksScreenState extends State<PickingTasksScreen> {
  bool _isLoading = false;
  late List<PickingTask> _pickingTasks;

  @override
  void initState() {
    super.initState();
    _loadPickingTasks();
  }

  Future<void> _loadPickingTasks() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Replace with actual Supabase query
    await Future.delayed(const Duration(milliseconds: 500));

    _pickingTasks = _getMockPickingTasks();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<PickingTask> _getMockPickingTasks() {
    return [
      PickingTask(
        deliveryId: '#DLV-2026-0842',
        pathType: 'Residential Path',
        startLocation: 'SKU-442 → N-00B',
        endLocation: 'SKU-192 → R-210',
        timeRemaining: 280,
        estimatedTime: '3 mins',
        totalItems: 4,
        status: 'pending',
        route: PickingRoute(
          deliveryId: '#DLV-2026-0842',
          sequence: [
            PickingLocation(
              code: 'A1-92',
              warehousePosition: 'North End',
              estimatedDistance: '5 mins, 540m',
            ),
            PickingLocation(
              code: 'B4-R1',
              warehousePosition: 'Central Zone',
              estimatedDistance: '312m',
            ),
            PickingLocation(
              code: 'C7-L3',
              warehousePosition: 'West Wing',
              estimatedDistance: '280m',
            ),
            PickingLocation(
              code: 'D2-R5',
              warehousePosition: 'South End',
              estimatedDistance: '280m',
            ),
          ],
          totalDistance: '312m',
          totalItems: 4,
        ),
      ),
      PickingTask(
        deliveryId: '#DLV-2026-0845',
        pathType: 'Commercial Path',
        startLocation: 'SKU-992 → A-04B',
        endLocation: 'SKU-341 → C-WP',
        timeRemaining: 410,
        estimatedTime: '2 mins',
        totalItems: 2,
        status: 'pending',
        route: PickingRoute(
          deliveryId: '#DLV-2026-0845',
          sequence: [
            PickingLocation(
              code: 'A2-04',
              warehousePosition: 'North End',
              estimatedDistance: '3 mins, 340m',
            ),
            PickingLocation(
              code: 'C3-WP',
              warehousePosition: 'West Wing',
              estimatedDistance: '240m',
            ),
          ],
          totalDistance: '240m',
          totalItems: 2,
        ),
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
              child: _isLoading
                  ? _buildLoadingState()
                  : _pickingTasks.isEmpty
                  ? _buildEmptyState()
                  : _buildTasksList(),
            ),
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
              'Picking Tasks',
              style: AppTextStyles.screenTitle.copyWith(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadPickingTasks,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF0891B2)),
          const SizedBox(height: 16),
          Text(
            'Loading picking tasks...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.route_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Picking Tasks',
              style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No picking tasks available at this time.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pickingTasks.length,
      itemBuilder: (context, index) {
        final task = _pickingTasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildTaskCard(task),
        );
      },
    );
  }

  Widget _buildTaskCard(PickingTask task) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with delivery ID
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.deliveryId,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Starts at Back R-12 (North End)',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Task details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(
                  icon: Icons.map_outlined,
                  label: 'Residential Path',
                  value: '${task.totalItems} items',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.schedule_outlined,
                  label: 'Task sequence',
                  value: task.startLocation,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.timer_outlined,
                  label: 'Time remaining',
                  value: '${task.timeRemaining}s',
                  valueColor: const Color(0xFFFF9500),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Action Buttons
          ButtonRow(
            padding: const EdgeInsets.all(16),
            primaryButton: PrimaryButton(
              label: 'Validate',
              icon: Icons.check,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AssignPickingTaskScreen(pickingTask: task),
                  ),
                );
              },
              padding: const EdgeInsets.symmetric(vertical: 12),
              borderRadius: 8,
            ),
            secondaryButton: SecondaryButton(
              label: 'Override',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OverridePickingRouteScreen(pickingTask: task),
                  ),
                );
              },
              padding: const EdgeInsets.symmetric(vertical: 12),
              borderRadius: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
