import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/storage_move_models.dart';
import '../widgets/action_buttons.dart';

class OverrideStorageMovePage extends StatefulWidget {
  final StorageMove move;

  const OverrideStorageMovePage({super.key, required this.move});

  @override
  State<OverrideStorageMovePage> createState() =>
      _OverrideStorageMovePageState();
}

class _OverrideStorageMovePageState extends State<OverrideStorageMovePage> {
  Location? _selectedDestination;
  int _quantity = 350;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample alternative locations - replace with actual API call
  final List<Location> _alternativeLocations = [
    Location(
      id: 'rack-p-03',
      code: 'Rack P-03',
      type: LocationType.PICKING,
      isActive: true,
      storageDetails: StorageLocationDetails(
        level: 2,
        slotCode: 'P-03',
        areaM2: 4.5,
        isAvailable: true,
      ),
    ),
    Location(
      id: 'rack-p-10',
      code: 'Rack P-10',
      type: LocationType.PICKING,
      isActive: true,
      storageDetails: StorageLocationDetails(
        level: 3,
        slotCode: 'P-10',
        areaM2: 4.5,
        isAvailable: true,
      ),
    ),
  ];

  List<Location> get _filteredLocations {
    if (_searchQuery.isEmpty) return _alternativeLocations;
    return _alternativeLocations.where((loc) {
      return loc.code.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _quantity = widget.move.quantity;
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          icon: Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Remplacer Mouvement de Stock',
          style: AppTextStyles.screenTitle.copyWith(
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Current Organization Section
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORGANISATION ACTUELLE',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID PRODUIT',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.move.sku?.skuCode ?? widget.move.productId,
                            style: AppTextStyles.sku.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        label: 'SOURCE',
                        value:
                            widget.move.sourceLocation?.code ??
                            widget.move.sourceLocationId,
                        icon: Icons.warehouse_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        label: 'RECOMMANDÉ PAR IA',
                        value:
                            widget.move.destinationLocation?.code ??
                            widget.move.destinationLocationId,
                        icon: Icons.auto_awesome,
                        isHighlighted: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Select New Destination Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SÉLECTIONNER NOUVELLE DESTINATION',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Search Input
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Rechercher zone ou rack...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location Options
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredLocations.length,
                      itemBuilder: (context, index) {
                        final location = _filteredLocations[index];
                        final isSelected =
                            _selectedDestination?.id == location.id;
                        return _LocationOption(
                          location: location,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedDestination = location;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Adjust Quantity Section
                  Text(
                    'AJUSTER QUANTITÉ',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_quantity > 1) {
                              setState(() {
                                _quantity--;
                              });
                            }
                          },
                          icon: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.textSecondary.withOpacity(0.2),
                              ),
                            ),
                            child: Icon(
                              Icons.remove,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Text(
                          _quantity.toString(),
                          style: AppTextStyles.hero.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _quantity++;
                            });
                          },
                          icon: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add,
                              color: AppColors.surface,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confirm Button
          BottomActionContainer(
            child: DangerButton(
              label: 'Confirmer le Remplacement',
              onPressed: _selectedDestination != null ? _handleConfirm : null,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  void _handleConfirm() {
    if (_selectedDestination == null) return;

    // Show confirmation dialog or navigate to next screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirmer le Remplacement',
          style: AppTextStyles.cardTitle.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir remplacer la recommandation IA?\n\nNouvelle destination: ${_selectedDestination!.code}\nQuantité: $_quantity',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list

              // Show success snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Remplacement confirmé avec succès',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.surface,
                    ),
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.failure,
              foregroundColor: AppColors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Confirmer',
              style: AppTextStyles.button.copyWith(color: AppColors.surface),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlighted;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighlighted
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isHighlighted
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isHighlighted
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationOption extends StatelessWidget {
  final Location location;
  final bool isSelected;
  final VoidCallback onTap;

  const _LocationOption({
    required this.location,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.textSecondary.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.code,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Niveau ${location.storageDetails?.level ?? "-"} • ${location.storageDetails?.areaM2 ?? 0}m²',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: AppColors.surface,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
