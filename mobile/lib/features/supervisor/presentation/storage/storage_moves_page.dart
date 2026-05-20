import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/storage_move_models.dart';
import '../widgets/action_buttons.dart';
import 'assign_storage_move_page.dart';
import 'override_storage_move_page.dart';

class StorageMovesPage extends StatefulWidget {
  const StorageMovesPage({super.key});

  @override
  State<StorageMovesPage> createState() => _StorageMovesPageState();
}

class _StorageMovesPageState extends State<StorageMovesPage> {
  String _searchQuery = '';

  // Sample data - replace with actual API call
  final List<StorageMove> _moves = [
    StorageMove(
      id: '1',
      productId: 'sku-88294-b',
      sku: SKU(
        id: '1',
        skuCode: 'SKU-88294-B',
        name: 'Product A',
        weightKg: 15.5,
      ),
      sourceLocationId: 'bulk-zone-a-12',
      sourceLocation: Location(
        id: 'loc-1',
        code: 'Bulk Zone A-12',
        type: LocationType.STORAGE,
        isActive: true,
      ),
      destinationLocationId: 'picking-rack-p-04',
      destinationLocation: Location(
        id: 'loc-2',
        code: 'Picking Rack P-04',
        type: LocationType.PICKING,
        isActive: true,
      ),
      quantity: 100,
      priority: PriorityLevel.HIGH,
      status: TaskStatus.PENDING,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      validated: false,
    ),
    StorageMove(
      id: '2',
      productId: 'sku-10293-c',
      sku: SKU(
        id: '2',
        skuCode: 'SKU-10293-C',
        name: 'Product B',
        weightKg: 8.2,
      ),
      sourceLocationId: 'overstock-b-02',
      sourceLocation: Location(
        id: 'loc-3',
        code: 'Overstock B-02',
        type: LocationType.STORAGE,
        isActive: true,
      ),
      destinationLocationId: 'picking-rack-p-12',
      destinationLocation: Location(
        id: 'loc-4',
        code: 'Picking Rack P-12',
        type: LocationType.PICKING,
        isActive: true,
      ),
      quantity: 50,
      priority: PriorityLevel.MEDIUM,
      status: TaskStatus.PENDING,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      validated: false,
    ),
    StorageMove(
      id: '3',
      productId: 'sku-44012-a',
      sku: SKU(
        id: '3',
        skuCode: 'SKU-44012-A',
        name: 'Product C',
        weightKg: 3.5,
      ),
      sourceLocationId: 'receiving-dock',
      sourceLocation: Location(
        id: 'loc-5',
        code: 'Receiving Dock',
        type: LocationType.RECEIVING,
        isActive: true,
      ),
      destinationLocationId: 'picking-rack-p-01',
      destinationLocation: Location(
        id: 'loc-6',
        code: 'Picking Rack P-01',
        type: LocationType.PICKING,
        isActive: true,
      ),
      quantity: 200,
      priority: PriorityLevel.LOW,
      status: TaskStatus.PENDING,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      validated: false,
    ),
  ];

  List<StorageMove> get _filteredMoves {
    if (_searchQuery.isEmpty) return _moves;
    return _moves.where((move) {
      final skuCode = move.sku?.skuCode.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return skuCode.contains(query);
    }).toList();
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
          'Mouvements de Stock',
          style: AppTextStyles.screenTitle.copyWith(
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Rechercher produit ou rayonnage...',
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
                          vertical: 12,
                        ),
                      ),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),

          // Storage Moves List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredMoves.length,
              itemBuilder: (context, index) {
                final move = _filteredMoves[index];
                return _StorageMoveCard(
                  move: move,
                  onApprove: () => _handleApprove(move),
                  onOverride: () => _handleOverride(move),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleApprove(StorageMove move) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignStorageMovePage(move: move),
      ),
    );
  }

  void _handleOverride(StorageMove move) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OverrideStorageMovePage(move: move),
      ),
    );
  }
}

class _StorageMoveCard extends StatelessWidget {
  final StorageMove move;
  final VoidCallback onApprove;
  final VoidCallback onOverride;

  const _StorageMoveCard({
    required this.move,
    required this.onApprove,
    required this.onOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with priority badge
          Padding(
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
                      Row(
                        children: [
                          Text(
                            'ID PRODUIT',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _PriorityBadge(priority: move.priority),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        move.sku?.skuCode ?? move.productId,
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
          ),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.textSecondary.withOpacity(0.1),
          ),

          // Location Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.warehouse_outlined,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        move.sourceLocation?.code ?? move.sourceLocationId,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          move.destinationLocation?.code ??
                              move.destinationLocationId,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.textSecondary.withOpacity(0.1),
          ),

          // Action Buttons
          ButtonRow(
            padding: const EdgeInsets.all(16),
            primaryButton: PrimaryButton(
              label: 'Approuver',
              onPressed: onApprove,
              padding: const EdgeInsets.symmetric(vertical: 12),
              borderRadius: 8,
            ),
            secondaryButton: SecondaryButton(
              label: 'Remplacer',
              onPressed: onOverride,
              padding: const EdgeInsets.symmetric(vertical: 12),
              borderRadius: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final PriorityLevel priority;

  const _PriorityBadge({required this.priority});

  Color get _backgroundColor {
    switch (priority) {
      case PriorityLevel.HIGH:
        return AppColors.failure;
      case PriorityLevel.MEDIUM:
        return AppColors.accent;
      case PriorityLevel.LOW:
        return AppColors.textSecondary;
    }
  }

  String get _label {
    switch (priority) {
      case PriorityLevel.HIGH:
        return 'PRIORITÉ ÉLEVÉE';
      case PriorityLevel.MEDIUM:
        return 'MOYENNE';
      case PriorityLevel.LOW:
        return 'FAIBLE';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _label,
        style: AppTextStyles.labelSmall.copyWith(
          color: _backgroundColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
