import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/command_order_model.dart';
import 'command_order_card.dart';

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
        scheduledReception: DateTime(2026, 2, 13, 9, 30),
        products: [
          ProductLine(sku: 'SKU-442', quantityReceived: 1240),
          ProductLine(sku: 'SKU-109', quantityReceived: 1240),
          ProductLine(sku: 'SKU-882', quantityReceived: 1240),
        ],
      ),
      CommandOrder(
        deliveryId: '#DLV-882915',
        scheduledReception: DateTime(2026, 2, 13, 11, 15),
        products: [
          ProductLine(sku: 'SKU-201', quantityReceived: 850),
          ProductLine(sku: 'SKU-554', quantityReceived: 850),
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
        return CommandOrderCard(order: order);
      },
    );
  }
}
