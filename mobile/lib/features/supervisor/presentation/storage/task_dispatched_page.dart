import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/storage_move_models.dart';
import '../widgets/action_buttons.dart';

class TaskDispatchedPage extends StatelessWidget {
  final StorageMove move;
  final Employee assignedEmployee;

  const TaskDispatchedPage({
    super.key,
    required this.move,
    required this.assignedEmployee,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () =>
              Navigator.popUntil(context, (route) => route.isFirst),
        ),
        title: Text(
          'Tâche Attribuée',
          style: AppTextStyles.screenTitle.copyWith(
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Success Icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: AppColors.surface,
                          size: 48,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surface,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.check,
                            color: AppColors.surface,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Success Title
                  Text(
                    'Mouvement Attribué',
                    style: AppTextStyles.hero.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    'Mouvement de stock pour ${move.sku?.skuCode ?? move.productId}\nattribué à ${assignedEmployee.name}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Details Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          label: 'DESTINATION',
                          value:
                              move.destinationLocation?.code ??
                              move.destinationLocationId,
                          icon: Icons.location_on,
                          iconColor: AppColors.primary,
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.textSecondary.withOpacity(0.1),
                        ),
                        _DetailRow(
                          label: 'PRIORITÉ',
                          value: _getPriorityLabel(move.priority),
                          icon: Icons.flag,
                          iconColor: _getPriorityColor(move.priority),
                          valueColor: _getPriorityColor(move.priority),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Employee Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            assignedEmployee.name.substring(0, 1).toUpperCase(),
                            style: AppTextStyles.hero.copyWith(
                              color: AppColors.primary,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ATTRIBUÉ À',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                assignedEmployee.name,
                                style: AppTextStyles.cardTitle.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                assignedEmployee.role,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          BottomActionContainer(
            child: Column(
              children: [
                PrimaryButton(
                  label: 'Voir sur la Carte',
                  icon: Icons.map_outlined,
                  onPressed: () {
                    // Navigate to map view
                  },
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Retour à la Liste',
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPriorityLabel(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.HIGH:
        return 'PRIORITÉ ÉLEVÉE';
      case PriorityLevel.MEDIUM:
        return 'MOYENNE';
      case PriorityLevel.LOW:
        return 'FAIBLE';
    }
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.HIGH:
        return AppColors.failure;
      case PriorityLevel.MEDIUM:
        return AppColors.accent;
      case PriorityLevel.LOW:
        return AppColors.textSecondary;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
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
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
