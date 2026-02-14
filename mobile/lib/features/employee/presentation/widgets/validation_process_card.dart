import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/command_entity.dart';

/// Card showing the validation process information matching Figma design.
/// Order section and Product Validation section are SEPARATE containers.
class ValidationProcessCard extends StatelessWidget {
  final CommandEntity validation;
  final VoidCallback? onValidateProduct;
  final VoidCallback? onFlagIssue;
  final Set<String> validatedItemIds;
  final Function(String itemId) onItemToggle;

  const ValidationProcessCard({
    super.key,
    required this.validation,
    required this.validatedItemIds,
    required this.onItemToggle,
    this.onValidateProduct,
    this.onFlagIssue,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Commande ${validation.displayOrderId}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                        _getStatusLabel(),
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

          // Individual product items with checkboxes
          if (validation.items.isNotEmpty)
            ...validation.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final itemId = item.id.toString();
              final isValidated = validatedItemIds.contains(itemId);

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < validation.items.length - 1 ? 12 : 0,
                ),
                child: _buildCheckItemCard(
                  '${item.productName ?? item.sku} (${item.quantity} unités)',
                  isValidated: isValidated,
                  onTap: () => onItemToggle(itemId),
                ),
              );
            })
          else
          // Fallback if no items loaded yet - show generic checkboxes
          ...[
            _buildCheckItemCard(
              'Quantité (${validation.totalItems} articles)',
              isValidated: validatedItemIds.contains('quantity'),
              onTap: () => onItemToggle('quantity'),
            ),
            const SizedBox(height: 12),
            _buildCheckItemCard(
              'Type de Produit',
              isValidated: validatedItemIds.contains('product_type'),
              onTap: () => onItemToggle('product_type'),
            ),
          ],
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

  String _getStatusLabel() {
    switch (validation.status) {
      case CommandStatus.pending:
        return 'EN ATTENTE';
      case CommandStatus.inProgress:
        return 'EN COURS';
      case CommandStatus.completed:
        return 'TERMINÉ';
      case CommandStatus.cancelled:
        return 'ANNULÉ';
    }
  }

  Color _getStatusBackgroundColor() {
    switch (validation.status) {
      case CommandStatus.pending:
        return Colors.grey.shade200;
      case CommandStatus.inProgress:
        return _inProgressColor.withOpacity(0.15);
      case CommandStatus.completed:
        return AppColors.success.withOpacity(0.15);
      case CommandStatus.cancelled:
        return AppColors.failure.withOpacity(0.15);
    }
  }

  Color _getStatusTextColor() {
    switch (validation.status) {
      case CommandStatus.pending:
        return AppColors.textSecondary;
      case CommandStatus.inProgress:
        return _inProgressColor;
      case CommandStatus.completed:
        return AppColors.success;
      case CommandStatus.cancelled:
        return AppColors.failure;
    }
  }
}
