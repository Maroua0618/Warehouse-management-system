import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget showing "Path Resolved" section with chariot info and path visualization.
/// Used in both Ingoing Validation and Outgoing Execution pages.
class PathResolvedCard extends StatelessWidget {
  final String chariotName;
  final List<String> chariotCodes;
  final int estimatedDelaySaved;

  const PathResolvedCard({
    super.key,
    this.chariotName = 'Take Chariot Name',
    this.chariotCodes = const ['C-04', 'C-09', 'C-12'],
    this.estimatedDelaySaved = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Green checkmark icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: AppColors.success, size: 36),
          ),

          const SizedBox(height: 16),

          // "Path Resolved" title
          const Text(
            'Chemin Résolu',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          // Chariot name with codes
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(text: 'Chariot $chariotName '),
                TextSpan(
                  text: '(${chariotCodes.join(', ')})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Path visualization with SVG
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SvgPicture.asset('assets/path.svg', fit: BoxFit.contain),
            ),
          ),

          const SizedBox(height: 20),

          // Estimated delay saved - teal pill background
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'DÉLAI ESTIMÉ ÉCONOMISÉ:  ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '$estimatedDelaySaved min',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
