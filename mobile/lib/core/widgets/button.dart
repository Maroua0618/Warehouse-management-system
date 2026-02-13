import 'package:flutter/material.dart';

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
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? borderRadius;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
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
          backgroundColor: backgroundColor ?? const Color(0xFF0A6E85),
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
          elevation: 0,
          disabledBackgroundColor: (backgroundColor ?? const Color(0xFF0A6E85))
              .withOpacity(0.6),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
  final VoidCallback onPressed;
  final Color? borderColor;
  final Color? textColor;
  final double? height;
  final double? borderRadius;

  const SecondaryButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.borderColor,
    this.textColor,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? const Color(0xFF0A6E85);
    final effectiveTextColor = textColor ?? const Color(0xFF0A6E85);

    return SizedBox(
      width: double.infinity,
      height: height ?? 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveTextColor,
          side: BorderSide(color: effectiveBorderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
      color: backgroundColor ?? const Color(0xFF0A6E85),
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
