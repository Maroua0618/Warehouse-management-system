import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/action_buttons.dart';
import '../../data/models/picking_route_models.dart';
import '../../logic/picking_route_cubit.dart';
import '../../logic/picking_route_state.dart';

/// Screen to override/view the optimized picking route
class OverridePickingRouteScreen extends StatelessWidget {
  final PickingTask pickingTask;

  const OverridePickingRouteScreen({Key? key, required this.pickingTask})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PickingRouteCubit(originalTask: pickingTask),
      child: const _OverridePickingRouteScreenContent(),
    );
  }
}

class _OverridePickingRouteScreenContent extends StatelessWidget {
  const _OverridePickingRouteScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<PickingRouteCubit, PickingRouteState>(
      listener: (context, state) {
        if (state is PickingRouteSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else if (state is PickingRouteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.failure,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<PickingRouteCubit, PickingRouteState>(
            builder: (context, state) {
              if (state is PickingRouteLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0891B2)),
                );
              }

              if (state is! PickingRouteLoaded) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDeliveryInfoCard(context),
                          const SizedBox(height: 16),
                          _buildPickingSequenceCard(context, state),
                          const SizedBox(height: 16),
                          _buildMetricsCard(context, state),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomActions(context, state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              'Modifier l\'Itinéraire',
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

  Widget _buildDeliveryInfoCard(BuildContext context) {
    final cubit = context.read<PickingRouteCubit>();
    final task = cubit.originalTask;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
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
                  task.deliveryId,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.pathType,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickingSequenceCard(
    BuildContext context,
    PickingRouteLoaded state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.route, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Séquence Préventive',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showAddLocationDialog(context),
                  icon: Icon(Icons.add, size: 18, color: AppColors.primary),
                  label: Text(
                    'Ajouter',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),

          // Sequence items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.sequence.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final location = state.sequence[index];
              final isFirst = index == 0;
              final isLast = index == state.sequence.length - 1;

              return _buildSequenceItem(
                context: context,
                location: location,
                index: index,
                position: index + 1,
                isFirst: isFirst,
                isLast: isLast,
                totalLength: state.sequence.length,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceItem({
    required BuildContext context,
    required PickingLocation location,
    required int index,
    required int position,
    required bool isFirst,
    required bool isLast,
    required int totalLength,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Position indicator
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isFirst
                  ? AppColors.success
                  : isLast
                  ? AppColors.failure
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: isFirst
                  ? Icon(Icons.flag, color: AppColors.surface, size: 16)
                  : isLast
                  ? Icon(Icons.flag, color: AppColors.surface, size: 16)
                  : Text(
                      '$position',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Location details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.code,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location.warehousePosition,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Move up button
              if (index > 0)
                IconButton(
                  icon: Icon(
                    Icons.arrow_upward,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                  onPressed: () => context
                      .read<PickingRouteCubit>()
                      .moveLocation(index, index - 1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32),
                ),
              // Move down button
              if (index < totalLength - 1)
                IconButton(
                  icon: Icon(
                    Icons.arrow_downward,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                  onPressed: () => context
                      .read<PickingRouteCubit>()
                      .moveLocation(index, index + 1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32),
                ),
              // Edit button
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: () =>
                    _showEditLocationDialog(context, index, location),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32),
              ),
              // Delete button
              if (totalLength > 2)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppColors.failure,
                    size: 20,
                  ),
                  onPressed: () =>
                      context.read<PickingRouteCubit>().deleteLocation(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditLocationDialog(
    BuildContext context,
    int index,
    PickingLocation location,
  ) {
    final codeController = TextEditingController(text: location.code);
    final positionController = TextEditingController(
      text: location.warehousePosition,
    );
    final distanceController = TextEditingController(
      text: location.estimatedDistance,
    );
    final cubit = context.read<PickingRouteCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Modifier l\'Emplacement',
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Code',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  hintText: 'Ex: A1-92',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Position d\'Entrepôt',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: positionController,
                decoration: InputDecoration(
                  hintText: 'Ex: North End',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Distance Estimée',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: distanceController,
                decoration: InputDecoration(
                  hintText: 'Ex: 312m',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          SecondaryButton(
            label: 'Annuler',
            onPressed: () => Navigator.pop(dialogContext),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            borderRadius: 8,
          ),
          PrimaryButton(
            label: 'Enregistrer',
            onPressed: () {
              cubit.updateLocation(
                index,
                PickingLocation(
                  code: codeController.text,
                  warehousePosition: positionController.text,
                  estimatedDistance: distanceController.text,
                ),
              );
              Navigator.pop(dialogContext);
            },
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            borderRadius: 8,
          ),
        ],
      ),
    );
  }

  void _showAddLocationDialog(BuildContext context) {
    final codeController = TextEditingController();
    final positionController = TextEditingController();
    final distanceController = TextEditingController();
    final cubit = context.read<PickingRouteCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Ajouter un Emplacement',
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Code',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  hintText: 'Ex: A1-92',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Position d\'Entrepôt',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: positionController,
                decoration: InputDecoration(
                  hintText: 'Ex: North End',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Distance Estimée',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: distanceController,
                decoration: InputDecoration(
                  hintText: 'Ex: 312m',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          SecondaryButton(
            label: 'Annuler',
            onPressed: () => Navigator.pop(dialogContext),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            borderRadius: 8,
          ),
          PrimaryButton(
            label: 'Ajouter',
            onPressed: () {
              if (codeController.text.isNotEmpty &&
                  positionController.text.isNotEmpty) {
                cubit.addLocation(
                  PickingLocation(
                    code: codeController.text,
                    warehousePosition: positionController.text,
                    estimatedDistance: distanceController.text.isEmpty
                        ? '0m'
                        : distanceController.text,
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            borderRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCard(BuildContext context, PickingRouteLoaded state) {
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
          Text(
            'MÉTRIQUES',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.straighten_outlined,
                  label: 'Distance Totale',
                  value: state.totalDistance,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Articles',
                  value: '${state.totalItems}',
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.sectionHeader.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, PickingRouteLoaded state) {
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
            label: 'Confirmer l\'Itinéraire Manuel',
            icon: Icons.check,
            onPressed: () => context.read<PickingRouteCubit>().saveRoute(),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            borderRadius: 8,
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Réinitialiser à l\'IA',
            onPressed: () =>
                context.read<PickingRouteCubit>().resetToAIOptimization(),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            borderRadius: 8,
          ),
        ],
      ),
    );
  }
}
