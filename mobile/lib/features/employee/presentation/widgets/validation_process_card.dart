import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ingoing_validation_entity.dart';

/// Card showing the validation process information matching Figma design.
/// Order section and Product Validation section are SEPARATE containers.
class ValidationProcessCard extends StatelessWidget {
  final IngoingValidationEntity validation;
  final VoidCallback? onValidateProduct;
  final VoidCallback? onFlagIssue;
  final VoidCallback? onQuantityTap;
  final VoidCallback? onProductTypeTap;
  final bool isQuantityValidated;
  final bool isProductTypeValidated;

  const ValidationProcessCard({
    super.key,
    required this.validation,
    this.onValidateProduct,
    this.onFlagIssue,
    this.onQuantityTap,
    this.onProductTypeTap,
    this.isQuantityValidated = false,
    this.isProductTypeValidated = false,
  });

  // Cream/beige background color from design
  static const Color _cardBackground = Color(0xFFFEF9F3);
  // Coral/salmon color for IN PROGRESS badge
  static const Color _inProgressColor = Color(0xFFE57373);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ORDER SECTION - Cream background card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // VALIDATION PROCESS label
                Text(
                  'PROCESSUS DE VALIDATION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                // Order number and status row
                Row(
                  children: [
                    Text(
                      'Commande ${validation.orderNumber}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusBackgroundColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        validation.statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusTextColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // PRODUCT VALIDATION SECTION - Separate from order card
          Row(
            children: [
              // Teal clipboard/checklist icon
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.checklist_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Validation Produit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // FLAG ISSUE button - coral/red color
              InkWell(
                onTap: onFlagIssue,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag, size: 16, color: _inProgressColor),
                      const SizedBox(width: 4),
                      Text(
                        'SIGNALER',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _inProgressColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quantity row - white card with circular checkbox (clickable)
          _buildCheckItemCard(
            'Quantité (${validation.totalQuantity} unités)',
            isValidated: isQuantityValidated,
            onTap: onQuantityTap,
          ),

          const SizedBox(height: 12),

          // Product Type row - white card with circular checkbox (clickable)
          _buildCheckItemCard(
            'Type de Produit (${validation.productType})',
            isValidated: isProductTypeValidated,
            onTap: onProductTypeTap,
          ),
        ],
      ),
    );
  }

  /// Builds a white card row with text and circular checkbox on right (clickable)
  Widget _buildCheckItemCard(
    String text, {
    required bool isValidated,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Circular checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isValidated ? AppColors.success : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isValidated ? AppColors.success : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isValidated
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusBackgroundColor() {
    switch (validation.status) {
      case ValidationStatus.notStarted:
        return Colors.grey.shade200;
      case ValidationStatus.inProgress:
        return _inProgressColor.withOpacity(0.15);
      case ValidationStatus.completed:
        return AppColors.success.withOpacity(0.15);
      case ValidationStatus.hasIssue:
        return AppColors.failure.withOpacity(0.15);
    }
  }

  Color _getStatusTextColor() {
    switch (validation.status) {
      case ValidationStatus.notStarted:
        return AppColors.textSecondary;
      case ValidationStatus.inProgress:
        return _inProgressColor;
      case ValidationStatus.completed:
        return AppColors.success;
      case ValidationStatus.hasIssue:
        return AppColors.failure;
    }
  }
}
