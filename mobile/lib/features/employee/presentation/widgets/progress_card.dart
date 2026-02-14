import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ingoing_validation_entity.dart';

/// Widget showing the overall progress of item validation - matches Figma design.
class ProgressCard extends StatelessWidget {
  final IngoingValidationEntity validation;

  const ProgressCard({super.key, required this.validation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header label
          Text(
            'Overall Progress',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 8),

          // Items count and percentage row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${validation.validatedItemCount} / ${validation.totalItemCount} Items Received',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${validation.progressPercentage}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: validation.progressPercentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
            ),
          ),

          const SizedBox(height: 14),

          // Current path row
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                'Current Path: ',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                '${validation.startFloor} → ${validation.endFloor}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor() {
    final progress = validation.progressPercentage;
    if (progress >= 100) {
      return AppColors.success;
    } else if (progress >= 75) {
      return AppColors.primary;
    } else {
      return AppColors.accent;
    }
  }
}
