import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_entity.dart';

/// Card widget displaying a single order.
/// Shows order number, location, item count, status, and optional time.
class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Order icon based on status
              _buildOrderIcon(),
              const SizedBox(width: 12),

              // Order details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order number
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Location and item count
                    Row(
                      children: [
                        // Location (always shown)
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Item count
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 14,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${order.itemCount} Articles',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status badge
              _buildStatusBadge(),

              const SizedBox(width: 8),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the order status icon with appropriate color.
  Widget _buildOrderIcon() {
    Color backgroundColor;
    IconData icon;

    if (order.isValidated) {
      backgroundColor = AppColors.success.withOpacity(0.15);
      icon = Icons.check_circle;
    } else if (order.isPending) {
      backgroundColor = AppColors.warning.withOpacity(0.15);
      icon = Icons.inventory_2;
    } else {
      backgroundColor = AppColors.primary.withOpacity(0.15);
      icon = Icons.local_shipping;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: order.isValidated
            ? AppColors.success
            : order.isPending
            ? AppColors.accent
            : AppColors.primary,
        size: 24,
      ),
    );
  }

  /// Builds the status badge (PENDING, VALIDATED, etc.)
  Widget _buildStatusBadge() {
    Color textColor;
    String statusText = order.status.toUpperCase();

    if (order.isValidated) {
      textColor = AppColors.success;
    } else if (order.isPending) {
      textColor = AppColors.warning;
    } else {
      textColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
