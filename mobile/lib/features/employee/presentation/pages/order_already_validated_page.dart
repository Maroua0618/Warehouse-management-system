import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Page displayed when user tries to access an already validated order.
/// Shows validation summary with order details.
class OrderAlreadyValidatedPage extends StatelessWidget {
  final String orderId;
  final bool isOutgoing;
  final String? deliveryId;
  final String? skuReference;
  final DateTime? validatedAt;

  const OrderAlreadyValidatedPage({
    super.key,
    required this.orderId,
    required this.isOutgoing,
    this.deliveryId,
    this.skuReference,
    this.validatedAt,
  });

  @override
  Widget build(BuildContext context) {
    final timestamp = validatedAt ?? DateTime.now();
    final timeStr =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.hour >= 12 ? 'PM' : 'AM'}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Success icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 56,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      isOutgoing
                          ? 'Order Already Delivered\nSuccessfully'
                          : 'Order Already Placed\nSuccessfully',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.sectionHeader.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Inventory has been updated and the\nmovement has been recorded.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Validation Summary Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with accent line
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: AppColors.primary,
                                  width: 4,
                                ),
                              ),
                            ),
                            child: Text(
                              'VALIDATION SUMMARY',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),

                          Divider(
                            height: 1,
                            color: AppColors.textSecondary.withOpacity(0.1),
                          ),

                          // Details
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  isOutgoing ? 'Delivery ID' : 'Order ID',
                                  '#${deliveryId ?? 'WH-88293'}',
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  isOutgoing ? 'Order ID' : 'SKU Reference',
                                  skuReference ?? 'SKU-9902-BX',
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  'Timestamp',
                                  'Today, $timeStr',
                                  hasIcon: true,
                                ),
                              ],
                            ),
                          ),

                          // Validation Capture placeholder
                          Container(
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.textSecondary.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Placeholder grid image
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildPlaceholderBox(),
                                    const SizedBox(width: 8),
                                    _buildPlaceholderBox(),
                                    const SizedBox(width: 8),
                                    _buildPlaceholderBox(),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildPlaceholderBox(),
                                    const SizedBox(width: 8),
                                    _buildPlaceholderBox(),
                                    const SizedBox(width: 8),
                                    _buildPlaceholderBox(),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.qr_code_scanner,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'VALIDATION CAPTURE',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.textSecondary,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.dashboard_outlined, size: 20),
                  label: const Text('Return to Dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool hasIcon = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          children: [
            if (hasIcon) ...[
              Icon(Icons.access_time, size: 14, color: AppColors.textPrimary),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceholderBox() {
    return Container(
      width: 50,
      height: 35,
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
