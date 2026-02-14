import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Reusable Primary Button Component
///
/// Usage:
/// ```dart
/// PrimaryButton(
///   text: 'Get Started',
///   icon: Icons.arrow_forward,
///   onPressed: () {
///     // Your action here
///   },
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final double? height;
  final double? borderRadius;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.height,
    this.borderRadius,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height ?? 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.textSecondary.withOpacity(0.3),
          disabledForegroundColor: AppColors.textSecondary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.5),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: AppTextStyles.button.copyWith(color: Colors.white),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Secondary Button (Outlined)
///
/// Usage:
/// ```dart
/// SecondaryButton(
///   text: 'Cancel',
///   onPressed: () {
///     // Your action here
///   },
/// )
/// ```
class SecondaryButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final double? height;
  final double? borderRadius;
  final bool isLoading;

  const SecondaryButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.borderColor,
    this.height,
    this.borderRadius,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.primary;

    return SizedBox(
      width: double.infinity,
      height: height ?? 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textSecondary.withOpacity(0.5),
          side: BorderSide(
            color: onPressed == null
                ? AppColors.textSecondary.withOpacity(0.3)
                : effectiveBorderColor,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary.withOpacity(0.5),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: AppTextStyles.button.copyWith(
                      color: onPressed == null
                          ? AppColors.textSecondary.withOpacity(0.5)
                          : AppColors.primary,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Icon Button with Background
///
/// Usage:
/// ```dart
/// IconButtonWithBackground(
///   icon: Icons.add,
///   onPressed: () {
///     // Your action here
///   },
/// )
/// ```
class IconButtonWithBackground extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;

  const IconButtonWithBackground({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: size ?? 48,
          height: size ?? 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: iconColor ?? Colors.white,
            size: (size ?? 48) * 0.5,
          ),
        ),
      ),
    );
  }
}
