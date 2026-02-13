import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../data/models/command_order_model.dart';
import 'command_order_card.dart';
import '../pages/supervisor_dashboard.dart';
import '../pages/calendar.dart';

/// Main page for Bon de commande (Command Orders/Purchase Orders)
/// Displays delivery orders with product SKUs, quantities, and reception times
class BonDeCommandeScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const BonDeCommandeScreen({Key? key, this.selectedDate}) : super(key: key);

  @override
  State<BonDeCommandeScreen> createState() => _BonDeCommandeScreenState();
}

class _BonDeCommandeScreenState extends State<BonDeCommandeScreen> {
  bool _isLoading = false;
  final List<CommandOrder> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Replace with actual Supabase query
    // Example query structure:
    // final response = await Supabase.instance.client
    //     .from('command_orders')
    //     .select('''
    //       order_id,
    //       reception_at,
    //       orders!inner (
    //         id,
    //         delivery_id,
    //         deliveries (
    //           delivery_id
    //         )
    //       )
    //     ''')
    //     .order('reception_at', ascending: false);

    // For now, using mock data
    await Future.delayed(const Duration(milliseconds: 500));

    final mockOrders = _getMockOrders();

    if (mounted) {
      setState(() {
        _orders.clear();
        _orders.addAll(mockOrders);
        _isLoading = false;
      });
    }
  }

  List<CommandOrder> _getMockOrders() {
    // Mock data matching the image provided
    return [
      CommandOrder(
        deliveryId: '#DLV-882910',
        receptionAt: DateTime(2026, 2, 13, 9, 30),
        items: [
          CommandOrderItem(
            productIdentifier: 'SKU-442',
            quantityReceived: 1240,
          ),
          CommandOrderItem(
            productIdentifier: 'SKU-109',
            quantityReceived: 1240,
          ),
          CommandOrderItem(
            productIdentifier: 'SKU-882',
            quantityReceived: 1240,
          ),
        ],
      ),
      CommandOrder(
        deliveryId: '#DLV-882915',
        receptionAt: DateTime(2026, 2, 13, 11, 15),
        items: [
          CommandOrderItem(productIdentifier: 'SKU-201', quantityReceived: 850),
          CommandOrderItem(productIdentifier: 'SKU-554', quantityReceived: 850),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _orders.isEmpty
                  ? _buildEmptyState()
                  : _buildOrdersList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2, onTap: _onNavBarTap),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bon de commande',
                  style: AppTextStyles.screenTitle.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.selectedDate != null)
                  Text(
                    _formatSelectedDate(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadOrders,
          ),
        ],
      ),
    );
  }

  String _formatSelectedDate() {
    if (widget.selectedDate == null) return '';
    final now = DateTime.now();
    final date = widget.selectedDate!;

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Aujourd\'hui';
    }

    final tomorrow = now.add(const Duration(days: 1));
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Demain';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF0891B2)),
          const SizedBox(height: 16),
          Text(
            'Loading command orders...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun bon de commande',
              style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucun bon de commande prévu pour cette date.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length + 1,
      itemBuilder: (context, index) {
        if (index == _orders.length) {
          return const SizedBox(height: 80);
        }

        final order = _orders[index];
        return CommandOrderCard(
          order: order,
          onTap: () => _showOrderDetails(order),
        );
      },
    );
  }

  void _showOrderDetails(CommandOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOrderDetailsSheet(order),
    );
  }

  Widget _buildOrderDetailsSheet(CommandOrder order) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSheetHandle(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Détails du bon de commande',
                    style: AppTextStyles.sectionHeader.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Produits',
                    style: AppTextStyles.sectionHeader.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...order.items.map((item) => _buildDetailProductItem(item)),
                  const SizedBox(height: 24),
                  _buildActionButtons(order),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 16),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildDetailProductItem(CommandOrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: const Color(0xFF0891B2),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productIdentifier,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantityReceived} unités',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(CommandOrder order) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Fermer',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement validate action
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0891B2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Valider',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onNavBarTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SupervisorDashboardScreen(),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AIDecisionsEmptyScreen()),
      );
    }
  }
}
