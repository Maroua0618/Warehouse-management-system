import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/path_step_entity.dart';

/// Widget displaying a single step in the transport path - matches Figma design.
class PathStepCard extends StatelessWidget {
  final PathStepEntity step;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onValidateItem;
  final VoidCallback? onArrivedAtDestination;
  final bool isValidating;
  final String? previousStepName;
  final String? nextStepName;

  const PathStepCard({
    super.key,
    required this.step,
    this.isFirst = false,
    this.isLast = false,
    this.onValidateItem,
    this.onArrivedAtDestination,
    this.isValidating = false,
    this.previousStepName,
    this.nextStepName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline indicator
            _buildTimelineIndicator(),

            const SizedBox(width: 14),

            // Step content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: step.type == PathStepType.dropoff && step.isCurrent
                    ? _buildDropoffStepCard()
                    : step.isCurrent
                    ? _buildCurrentStepCard()
                    : _buildNormalStepContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineIndicator() {
    final Color circleColor = step.isCompleted
        ? AppColors.success
        : step.isCurrent
        ? AppColors.accent
        : Colors.grey.shade400;

    return SizedBox(
      width: 24,
      child: Column(
        children: [
          // Top line
          if (!isFirst)
            Expanded(
              flex: 0,
              child: Container(
                width: 2,
                height: 8,
                color: step.isCompleted
                    ? AppColors.success
                    : Colors.grey.shade300,
              ),
            ),

          // Circle indicator
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              step.isCompleted
                  ? Icons.check
                  : step.isCurrent
                  ? Icons.circle
                  : Icons.circle_outlined,
              size: step.isCompleted ? 12 : 8,
              color: Colors.white,
            ),
          ),

          // Bottom line
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                color: step.isCompleted
                    ? AppColors.success
                    : Colors.grey.shade300,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNormalStepContent() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: step.isCompleted ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: step.isCompleted ? Colors.grey.shade200 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type label and timestamp row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getTypeLabel(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getLabelColor(),
                  letterSpacing: 0.3,
                ),
              ),
              if (step.isCompleted)
                Text(
                  '09:42 AM',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary.withOpacity(0.6),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Floor and location name
          Text(
            '${step.floor}: ${step.locationName}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: step.isCompleted
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
          ),

          // Row and Slot info
          if (step.row != null || step.slot != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (step.row != null) ...[
                  _buildInfoLabel('ROW', step.row!),
                  const SizedBox(width: 24),
                ],
                if (step.slot != null) _buildInfoLabel('SLOT', step.slot!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropoffStepCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9F3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location name (main title)
          Text(
            '${step.locationName} - ${step.floor}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          // Final Destination subtitle
          Text(
            'Final Destination',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
          ),

          const SizedBox(height: 16),

          // Arrived at Destination button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onArrivedAtDestination,
              icon: const Icon(Icons.flag, size: 18),
              label: const Text(
                'Arrived at Destination',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getTypeLabel(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              // Circle indicator for current
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Floor and location name
          Text(
            '${step.floor}: ${step.locationName}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          // Row and Slot info
          if (step.row != null || step.slot != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (step.row != null) ...[
                  _buildInfoLabel('ROW', step.row!, isHighlighted: true),
                  const SizedBox(width: 24),
                ],
                if (step.slot != null)
                  _buildInfoLabel('SLOT', step.slot!, isHighlighted: true),
              ],
            ),
          ],

          // Item to pick section
          if (step.itemToPick != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SKU row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SKU',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step.itemToPick!.sku,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${step.itemToPick!.quantity} Units',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Validate Item button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isValidating ? null : onValidateItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isValidating) ...[
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Validating...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else ...[
                            const Icon(Icons.check, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              'Validate Item',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoLabel(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: isHighlighted
                ? AppColors.accent.withOpacity(0.8)
                : AppColors.textSecondary.withOpacity(0.6),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isHighlighted
                ? AppColors.textPrimary
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _getTypeLabel() {
    switch (step.type) {
      case PathStepType.pickup:
        return 'PICKUP LOCATION';
      case PathStepType.transit:
        return 'TRANSIT NODE';
      case PathStepType.dropoff:
        return 'FINAL DROP-OFF';
    }
  }

  Color _getLabelColor() {
    switch (step.type) {
      case PathStepType.pickup:
        return AppColors.primary;
      case PathStepType.transit:
        return AppColors.accent;
      case PathStepType.dropoff:
        return AppColors.success;
    }
  }
}
