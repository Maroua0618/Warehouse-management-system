import 'package:flutter/material.dart';
import '../../data/models/command_order_model.dart';
import '../widgets/bon_de_commande_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Page to display all Bon de Commande (Command Orders/Delivery Notes)
/// Data will be loaded from Supabase
class BonDeCommandePage extends StatefulWidget {
  const BonDeCommandePage({super.key});

  @override
  State<BonDeCommandePage> createState() => _BonDeCommandePageState();
}

class _BonDeCommandePageState extends State<BonDeCommandePage> {
  bool _isLoading = false;
  List<CommandOrder> _commandOrders = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCommandOrders();
  }

  /// Load command orders from Supabase
  /// TODO: Replace mock data with actual Supabase query
  /// Example query:
  /// ```dart
  /// final data = await supabase
  ///     .from('command_orders')
  ///     .select('''
  ///       delivery_id,
  ///       reception_at,
  ///       orders (
  ///         id,
  ///         order_lines (
  ///           sku_id,
  ///           skus (sku_code),
  ///           quantity
  ///         )
  ///       )
  ///     ''')
  ///     .order('reception_at', ascending: false);
  /// ```
  Future<void> _loadCommandOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with actual Supabase call
      // Simulating network delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data matching the structure from the image
      final mockOrders = [
        CommandOrder(
          deliveryId: 'DLV-882910',
          products: [
            const ProductLine(sku: '442', quantityReceived: 400),
            const ProductLine(sku: '109', quantityReceived: 500),
            const ProductLine(sku: '882', quantityReceived: 340),
          ],
          scheduledReception: DateTime(2026, 2, 13, 9, 30),
          bay: 'Bay 4',
        ),
        CommandOrder(
          deliveryId: 'DLV-882915',
          products: [
            const ProductLine(sku: '201', quantityReceived: 450),
            const ProductLine(sku: '554', quantityReceived: 400),
          ],
          scheduledReception: DateTime(2026, 2, 13, 11, 15),
          bay: 'Bay 12',
        ),
        CommandOrder(
          deliveryId: 'DLV-882920',
          products: [
            const ProductLine(sku: '330', quantityReceived: 600),
            const ProductLine(sku: '445', quantityReceived: 300),
            const ProductLine(sku: '778', quantityReceived: 250),
          ],
          scheduledReception: DateTime(2026, 2, 13, 14, 0),
          bay: 'Bay 7',
        ),
        CommandOrder(
          deliveryId: 'DLV-882925',
          products: [const ProductLine(sku: '100', quantityReceived: 800)],
          scheduledReception: DateTime(2026, 2, 13, 16, 30),
          bay: 'Bay 3',
        ),
      ];

      setState(() {
        _commandOrders = mockOrders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des données: $e';
        _isLoading = false;
      });
    }
  }

  /// Handle refresh action
  Future<void> _handleRefresh() async {
    await _loadCommandOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Bon de commande',
          style: AppTextStyles.screenTitle.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _handleRefresh,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.failure),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _handleRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_commandOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun bon de commande',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les bons de commande apparaîtront ici',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Header with AI recommendation notice
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Review suggested delivery intake plans generated by AI to optimize warehouse space and manpower.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Command Orders List
          ..._commandOrders.map((order) {
            return BonDeCommandeCard(
              commandOrder: order,
              onTap: () => _handleOrderTap(order),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Handle when a command order is tapped
  /// TODO: Navigate to detail page or show more information
  void _handleOrderTap(CommandOrder order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bon de commande: #${order.deliveryId}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
