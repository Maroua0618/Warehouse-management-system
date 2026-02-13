import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget displaying the target destination with location verification badge.
/// Used in the ingoing validation page.
class TargetDestinationCard extends StatelessWidget {
  final String destinationCode;
  final bool isVerified;

  const TargetDestinationCard({
    super.key,
    this.destinationCode = 'B7-N1-C2',
    this.isVerified = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location pin icon as section marker
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Icon(Icons.location_on, color: AppColors.primary, size: 24),
        ),
        // Main card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // "TARGET DESTINATION" label
              Text(
                'TARGET DESTINATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              // Destination code
              Text(
                destinationCode,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 16),

              // Location Verified badge
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Location Verified',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
