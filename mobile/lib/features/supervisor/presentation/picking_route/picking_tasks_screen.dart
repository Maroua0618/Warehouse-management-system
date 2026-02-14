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
        pathType: 'Résidentiel',
        startLocation: 'SKU-442 → N-00B',
        endLocation: 'SKU-192 → R-210',
        timeRemaining: 280,
        estimatedTime: '3 mins',
        totalItems: 4,
        status: 'pending',
        destinationRack: 'Rack R-12 (North End)',
        optimizedDistance: '280m',
        optimizedStops: 3,
        steps: [
          PickingStep(stepNumber: 1, sku: 'SKU-442', location: 'R-12(N)'),
          PickingStep(stepNumber: 2, sku: 'SKU-089', location: 'R-05(A)'),
          PickingStep(stepNumber: 3, sku: 'SKU-112', location: 'R-22(c)'),
        ],
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
          ],
          totalDistance: '280m',
          totalItems: 3,
        ),
      ),
      PickingTask(
        deliveryId: '#DLV-2026-0845',
        pathType: 'Commercial',
        startLocation: 'SKU-992 → A-04B',
        endLocation: 'SKU-341 → C-WP',
        timeRemaining: 410,
        estimatedTime: '2 mins',
        totalItems: 2,
        status: 'pending',
        destinationRack: 'Rack R-04 (East Gate)',
        optimizedDistance: '240m',
        optimizedStops: 2,
        steps: [
          PickingStep(stepNumber: 1, sku: 'SKU-992', location: 'A-04B'),
          PickingStep(stepNumber: 2, sku: 'SKU-341', location: 'C-WP'),
        ],
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
            'Chargement des tâches de prélèvement...',
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
              'Aucune Tâche de Prélèvement',
              style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune tâche de prélèvement disponible pour le moment.',
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
          // Optimized Steps Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'ÉTAPES OPTIMISÉES RÉSIDENTIEL',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery ID
                Text(
                  task.deliveryId,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),

                // Path Type Label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'CHEMIN RÉSIDENTIEL',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Steps
                ...task.steps.map((step) => _buildStepItem(step)).toList(),

                const SizedBox(height: 16),

                // Destination Picking Route
                _buildDestinationSection(task),

                const SizedBox(height: 16),

                // AI Metrics
                _buildAIMetrics(task),
              ],
            ),
          ),

          const Divider(height: 1),

          // Action Buttons
          ButtonRow(
            padding: const EdgeInsets.all(16),
            primaryButton: PrimaryButton(
              label: 'Valider',
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
              label: 'Modifier',
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

  Widget _buildStepItem(PickingStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.location_on,
                size: 12,
                color: AppColors.surface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ÉTAPE ${step.stepNumber}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.formattedStep,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationSection(PickingTask task) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DESTINATION ITINÉRAIRE PRÉLÈVEMENT',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  task.destinationRack,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIMetrics(PickingTask task) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MÉTRIQUES IA',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  value: task.optimizedDistance,
                  label: 'ÉTAPES OPTIMISÉES',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  value: '${task.optimizedStops} arrêts',
                  label: 'ÉTAPES OPTIMISÉES',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({required String value, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
