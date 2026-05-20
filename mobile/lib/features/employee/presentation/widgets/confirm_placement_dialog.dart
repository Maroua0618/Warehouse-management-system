import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Dialogue de confirmation de placement affiché lors de la validation d'un placement de livraison.
/// Affiche les informations SKU et emplacement cible avec un bouton de confirmation.
class ConfirmPlacementDialog extends StatelessWidget {
  final String sku;
  final String targetSlot;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ConfirmPlacementDialog({
    super.key,
    required this.sku,
    required this.targetSlot,
    this.onConfirm,
    this.onCancel,
  });

  /// Affiche le dialogue avec le SKU et l'emplacement cible spécifiés.
  static Future<bool?> show({
    required BuildContext context,
    required String sku,
    required String targetSlot,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmPlacementDialog(
        sku: sku,
        targetSlot: targetSlot,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green checkmark icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 36,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Confirmer le Placement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Validation prête pour enregistrement',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Info rows container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // SKU row
                  _buildInfoRow('SKU', sku),
                  const SizedBox(height: 12),
                  // Target Slot row
                  _buildInfoRow('Emplacement Cible', targetSlot),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Confirm button - primary color
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirmer et Enregistrer Mouvement',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Annuler',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
