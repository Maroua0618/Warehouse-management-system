import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/action_buttons.dart';
import '../../data/models/bon_de_preparation_model.dart';
import 'approve_assign_screen.dart';
import 'override_forecast_screen.dart';

class PreparationSlipsScreen extends StatefulWidget {
  const PreparationSlipsScreen({Key? key}) : super(key: key);

  @override
  State<PreparationSlipsScreen> createState() => _PreparationSlipsScreenState();
}

class _PreparationSlipsScreenState extends State<PreparationSlipsScreen> {
  // Mock data - replace with actual API calls
  late List<BonDePreparation> preparations;

  @override
  void initState() {
    super.initState();
    preparations = [
      BonDePreparation(
        deliveryId: 'DLV-2026-0001',
        items: [
          PreparationItem(
            productIdentifier: 'SKU-88291',
            quantity: 24,
            storageLocation: StorageLocation(
              zone: 'Zone A-12',
              shelf: 'Shelf 04',
            ),
            zone: 'Zone A-12',
            shelf: 'Shelf 04',
          ),
          PreparationItem(
            productIdentifier: 'SKU-11405',
            quantity: 12,
            storageLocation: StorageLocation(
              zone: 'Zone C-05',
              shelf: 'Shelf 01',
            ),
            zone: 'Zone C-05',
            shelf: 'Shelf 01',
          ),
        ],
        status: 'pending',
        createdAt: DateTime.now(),
      ),
      BonDePreparation(
        deliveryId: 'DLV-2026-0002',
        items: [
          PreparationItem(
            productIdentifier: 'SKU-99022',
            quantity: 50,
            storageLocation: StorageLocation(
              zone: 'Zone B-22',
              shelf: 'Shelf 09',
            ),
            zone: 'Zone B-22',
            shelf: 'Shelf 09',
          ),
        ],
        status: 'pending',
        createdAt: DateTime.now(),
      ),
      BonDePreparation(
        deliveryId: 'DLV-2026-0003',
        items: [
          PreparationItem(
            productIdentifier: 'SKU-44120',
            quantity: 100,
            storageLocation: StorageLocation(
              zone: 'Zone A-01',
              shelf: 'Shelf 03',
            ),
            zone: 'Zone A-01',
            shelf: 'Shelf 03',
          ),
          PreparationItem(
            productIdentifier: 'SKU-33219',
            quantity: 5,
            storageLocation: StorageLocation(
              zone: 'Zone D-15',
              shelf: 'Shelf 02',
            ),
            zone: 'Zone D-15',
            shelf: 'Shelf 02',
          ),
        ],
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    ];
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
          'Bon de préparation',
          style: AppTextStyles.screenTitle.copyWith(
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: preparations.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildDeliveryCard(context, preparations[index]),
          );
        },
      ),
    );
  }

  Widget _buildDeliveryCard(
    BuildContext context,
    BonDePreparation preparation,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Items
          ...preparation.items.asMap().entries.map((entry) {
            final isLast = entry.key == preparation.items.length - 1;
            return Column(
              children: [
                _buildItemRow(entry.value),
                if (!isLast) const Divider(height: 1, indent: 72),
              ],
            );
          }).toList(),

          const Divider(height: 1),

          // Action Buttons
          ButtonRow(
            padding: const EdgeInsets.all(16),
            primaryButton: PrimaryButton(
              label: 'Approuver',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ApproveAssignScreen(bonDePreparation: preparation),
                  ),
                );
              },
              padding: const EdgeInsets.symmetric(vertical: 12),
              borderRadius: 8,
            ),
            secondaryButton: SecondaryButton(
              label: 'Remplacer',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OverrideForecastScreen(bonDePreparation: preparation),
                  ),
                );
              },
              padding: const EdgeInsets.symmetric(vertical: 12),
              borderRadius: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(PreparationItem item) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productIdentifier,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.fullLocation,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'x${item.quantity}',
                style: AppTextStyles.sectionHeader.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'QTY',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
