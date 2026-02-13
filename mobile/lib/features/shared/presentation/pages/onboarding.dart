import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/button.dart';
import '../../../../routes.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Warehouse illustration
                  Image.asset(
                    'assets/Container.png',
                    height: 280,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 40),

                  // Title and description
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTextStyles.hero.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.2,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                      children: [
                        const TextSpan(text: 'Gestion Intelligente\n'),
                        TextSpan(
                          text: 'd\'Entrepôt',
                          style: AppTextStyles.hero.copyWith(
                            color: AppColors.primary,
                            height: 1.2,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Optimisez vos opérations avec l\'orchestration\nde tâches pilotée par l\'IA et suivi en temps réel.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Feature highlights
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _FeatureBadge(icon: Icons.speed_rounded, label: 'Rapide'),
                      _FeatureBadge(
                        icon: Icons.security_rounded,
                        label: 'Sécurisé',
                      ),
                      _FeatureBadge(
                        icon: Icons.insights_rounded,
                        label: 'Intelligent',
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Get Started button
                  PrimaryButton(
                    text: 'Commencer',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Feature badge widget
class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
