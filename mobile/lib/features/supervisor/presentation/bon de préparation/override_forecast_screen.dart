import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/bon_de_preparation_model.dart';
import 'storage_zone_selection_dialog.dart';
import 'product_replacement_dialog.dart';

class OverrideForecastScreen extends StatefulWidget {
  final BonDePreparation bonDePreparation;

  const OverrideForecastScreen({Key? key, required this.bonDePreparation})
    : super(key: key);

  @override
  State<OverrideForecastScreen> createState() => _OverrideForecastScreenState();
}

class _OverrideForecastScreenState extends State<OverrideForecastScreen> {
  String? selectedReason;
  final TextEditingController detailsController = TextEditingController();
  final Map<String, int> adjustments = {};
  StorageLocation? selectedZone;

  final List<Map<String, String>> reasons = [
    {'id': 'inventory_error', 'label': 'Erreur d\'inventaire'},
    {'id': 'equipment_issue', 'label': 'Problème d\'équipement'},
    {'id': 'staff_shortage', 'label': 'Pénurie de personnel'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize adjustments with current quantities
    for (var item in widget.bonDePreparation.items) {
      adjustments[item.productIdentifier] = item.quantity;
    }
  }

  @override
  void dispose() {
    detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Remplacer Prévision',
          style: AppTextStyles.screenTitle.copyWith(
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Reason for Override
                  _buildReasonSection(),
                  const SizedBox(height: 24),

                  // Additional Details
                  _buildDetailsSection(),
                  const SizedBox(height: 24),

                  // Manual Adjustment
                  _buildManualAdjustmentSection(),
                  const SizedBox(height: 24),

                  // Add Additional Product Button
                  _buildAddProductButton(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Raison du remplacement',
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: reasons.take(2).map((reason) {
            final isSelected = selectedReason == reason['id'];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedReason = reason['id'];
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    reason['label']!,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              selectedReason = reasons[2]['id'];
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: selectedReason == reasons[2]['id']
                  ? AppColors.primary
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selectedReason == reasons[2]['id']
                    ? AppColors.primary
                    : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: Text(
              reasons[2]['label']!,
              style: AppTextStyles.labelMedium.copyWith(
                color: selectedReason == reasons[2]['id']
                    ? Colors.white
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détails supplémentaires',
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          padding: const EdgeInsets.all(4),
          child: TextField(
            controller: detailsController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Fournir des détails supplémentaires pour la piste d\'audit...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualAdjustmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ajustement Manuel',
              style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.bonDePreparation.totalProducts} PRODUITS',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...widget.bonDePreparation.items
            .map((item) => _buildAdjustmentCard(item))
            .toList(),
      ],
    );
  }

  Widget _buildAdjustmentCard(PreparationItem item) {
    final currentQty = adjustments[item.productIdentifier] ?? item.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.productIdentifier,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            _showStorageZoneSelection(context, item);
                          },
                          child: Icon(
                            Icons.sync_alt,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.fullLocation,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildQuantityButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (currentQty > 0) {
                        setState(() {
                          adjustments[item.productIdentifier] = currentQty - 1;
                        });
                      }
                    },
                  ),
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '$currentQty',
                      style: AppTextStyles.sectionHeader.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  _buildQuantityButton(
                    icon: Icons.add,
                    onTap: () {
                      setState(() {
                        adjustments[item.productIdentifier] = currentQty + 1;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }

  Widget _buildAddProductButton() {
    return GestureDetector(
      onTap: () {
        _showProductReplacement(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Ajouter un produit supplémentaire',
              style: AppTextStyles.button.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    final canConfirm = selectedReason != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Annuler',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: canConfirm
                    ? () {
                        // Submit override
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Remplacement confirmé'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Confirmer',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStorageZoneSelection(BuildContext context, PreparationItem item) {
    showDialog(
      context: context,
      builder: (context) => StorageZoneSelectionDialog(
        currentItem: item,
        onZoneSelected: (zone) {
          setState(() {
            selectedZone = zone;
          });
        },
      ),
    );
  }

  void _showProductReplacement(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ProductReplacementDialog(
        onProductSelected: (replacement) {
          // Add the replacement product to adjustments
          setState(() {
            adjustments[replacement.replacementSku] = 1;
          });
        },
      ),
    );
  }
}
