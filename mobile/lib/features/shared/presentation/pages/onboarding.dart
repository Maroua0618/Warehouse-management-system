import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Warehouse illustration with efficiency badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Main warehouse container
                  Image.asset(
                    'assets/Container.png',
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Title and description
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.hero.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                  children: [
                    const TextSpan(text: 'Gestion Intelligente\n'),
                    TextSpan(
                      text: 'd\'Entrepôt',
                      style: AppTextStyles.hero.copyWith(
                        color: AppColors.primary,
                        height: 1.2,
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
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // Get Started button - using reusable component
              PrimaryButton(
                text: 'Commencer',
                icon: Icons.arrow_forward,
                onPressed: () {
                  // Navigate to next screen
                },
              ),

              const SizedBox(height: 16),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Vous avez déjà un compte? ',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to login
                    },
                    child: Text(
                      'Se connecter',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
