import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/command_order_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Reusable widget to display a Bon de Commande card
/// This widget is designed to be loaded from Supabase data
class BonDeCommandeCard extends StatelessWidget {
  final CommandOrder commandOrder;
  final VoidCallback? onTap;

  const BonDeCommandeCard({super.key, required this.commandOrder, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery ID Section
              _buildSection(
                icon: Icons.local_shipping_outlined,
                title: 'DELIVERY ID',
                content: '#${commandOrder.deliveryId}',
                contentStyle: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Product SKUs Section
              _buildSection(
                icon: Icons.inventory_2_outlined,
                title: 'Product SKUs',
                content: commandOrder.productSkusFormatted,
                contentStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Quantity Section
              _buildSection(
                icon: Icons.scale_outlined,
                title: 'Quantity Received',
                content: '${commandOrder.totalQuantity} units',
                contentStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Scheduled Reception Section
              _buildSection(
                icon: Icons.access_time_outlined,
                title: 'Scheduled Reception',
                content: _formatScheduledReception(
                  commandOrder.scheduledReception,
                  commandOrder.bay,
                ),
                contentStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a section with icon, title, and content
  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    required TextStyle contentStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(content, style: contentStyle),
            ],
          ),
        ),
      ],
    );
  }

  /// Format the scheduled reception date with optional bay
  String _formatScheduledReception(DateTime dateTime, String? bay) {
    final timeFormat = DateFormat('hh:mm a'); // e.g., "09:30 AM"
    final time = timeFormat.format(dateTime);

    if (bay != null && bay.isNotEmpty) {
      return '$time - $bay';
    }
    return time;
  }
}

/// Compact version of the BonDeCommandeCard for use in lists
class BonDeCommandeCompactCard extends StatelessWidget {
  final CommandOrder commandOrder;
  final VoidCallback? onTap;

  const BonDeCommandeCompactCard({
    super.key,
    required this.commandOrder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          '#${commandOrder.deliveryId}',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${commandOrder.products.length} SKU(s) • ${commandOrder.totalQuantity} units',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ),
    );
  }
}
