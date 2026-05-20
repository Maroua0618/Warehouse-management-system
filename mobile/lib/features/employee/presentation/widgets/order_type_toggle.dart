import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Toggle button widget for switching between Outgoing and Incoming orders.
/// Displays two pill-shaped buttons in a container.
class OrderTypeToggle extends StatelessWidget {
  /// Currently selected order type
  final String selectedType;

  /// Callback when order type is changed
  final ValueChanged<String> onTypeChanged;

  const OrderTypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            label: 'COMMANDES SORTANTES',
            type: 'outgoing',
            isSelected: selectedType == 'outgoing',
          ),
          _buildToggleButton(
            label: 'COMMANDES ENTRANTES',
            type: 'incoming',
            isSelected: selectedType == 'incoming',
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required String type,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? AppColors.primary
                : Colors.white.withOpacity(0.85),
          ),
        ),
      ),
    );
  }
}
