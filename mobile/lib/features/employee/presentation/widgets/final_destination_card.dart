import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget showing the final destination info.
/// Used at the bottom of outgoing execution page before validate button.
class FinalDestinationCard extends StatelessWidget {
  final String locationName;
  final String subtitle;
  final VoidCallback? onValidateDelivery;

  const FinalDestinationCard({
    super.key,
    this.locationName = 'Ground Floor - Expedition Zone',
    this.subtitle = 'Final Destination Milestone',
    this.onValidateDelivery,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Location info row
          Row(
            children: [
              // Location icon with circle background
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.grey.shade600,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              // Text column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locationName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
