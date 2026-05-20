import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/bon_de_preparation_model.dart';
import 'dispatch_confirmation_screen.dart';

class ApproveAssignScreen extends StatefulWidget {
  final BonDePreparation bonDePreparation;

  const ApproveAssignScreen({Key? key, required this.bonDePreparation})
    : super(key: key);

  @override
  State<ApproveAssignScreen> createState() => _ApproveAssignScreenState();
}

class _ApproveAssignScreenState extends State<ApproveAssignScreen> {
  Employee? selectedEmployee;
  Equipment? selectedChariot;

  // Mock data - replace with actual API calls
  final List<Employee> employees = [
    Employee(
      id: '1',
      name: 'Karim Bennani',
      photoUrl: null,
      tasksActive: 2,
      totalStock: 4,
    ),
    Employee(
      id: '2',
      name: 'Yacine Mansour',
      photoUrl: null,
      tasksActive: 9,
      totalStock: 2,
    ),
  ];
  // Available chariots
  final List<Equipment> chariots = [
    Equipment(
      id: '1',
      name: 'Chariot C2',
      type: 'chariot',
      batteryPercentage: 85,
      status: 'available',
    ),
    Equipment(
      id: '2',
      name: 'Chariot C3',
      type: 'chariot',
      batteryPercentage: 92,
      status: 'available',
    ),
  ];
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
          'Approuver & Assigner',
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
                  // Order Reference Card
                  _buildOrderReferenceCard(),
                  const SizedBox(height: 24),

                  // Select Lead Employee Section
                  _buildSelectEmployeeSection(),
                  const SizedBox(height: 24),

                  // Assign Chariot Section
                  _buildAssignChariotSection(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Bottom Confirm Button
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildOrderReferenceCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'PRODUITS',
                  value: '${widget.bonDePreparation.totalProducts} Skus',
                ),
              ),
              Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: _buildStatItem(
                  label: 'UNITÉS TOTALES',
                  value: '${widget.bonDePreparation.totalUnits} Unités',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required String label, required String value}) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectEmployeeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sélectionner Un Employé',
              style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // Filter action
              },
              icon: Icon(Icons.filter_list, size: 18, color: AppColors.primary),
              label: Text(
                'FILTRE',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...employees.map((employee) => _buildEmployeeCard(employee)).toList(),
      ],
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    final isSelected = selectedEmployee?.id == employee.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedEmployee = employee;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: employee.photoUrl != null
                      ? NetworkImage(employee.photoUrl!)
                      : null,
                  child: employee.photoUrl == null
                      ? Icon(Icons.person, color: AppColors.primary, size: 24)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildEmployeeBadge(
                            '${employee.tasksActive} TÂCHES ACTIVE',
                            Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          _buildEmployeeBadge(
                            '${employee.totalStock}m DE DISTANCE',
                            Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAssignChariotSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigner Chariot',
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: chariots
              .map((chariot) => _buildChariotCard(chariot))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildChariotCard(Equipment chariot) {
    final isSelected = selectedChariot?.id == chariot.id;
    final isAvailable = chariot.status == 'available';
    final isMaintenance = chariot.status == 'maintenance';

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isAvailable
              ? (isSelected
                    ? AppColors.primary.withOpacity(0.05)
                    : AppColors.surface)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isAvailable
                      ? const Color(0xFFE2E8F0)
                      : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isAvailable
                ? () {
                    setState(() {
                      selectedChariot = chariot;
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: isAvailable ? AppColors.primary : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    chariot.name,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isAvailable ? AppColors.textPrimary : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMaintenance ? 'MAINTENANCE' : 'DISPONIBLE MAINTENANT',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isMaintenance ? Colors.orange : Colors.green,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final canConfirm = selectedEmployee != null && selectedChariot != null;

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
        child: ElevatedButton(
          onPressed: canConfirm
              ? () {
                  // Navigate to dispatch confirmation
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DispatchConfirmationScreen(
                        bonDePreparation: widget.bonDePreparation.copyWith(
                          assignedEmployeeId: selectedEmployee!.id,
                          assignedEmployeeName: selectedEmployee!.name,
                          assignedEquipmentId: selectedChariot!.id,
                          assignedEquipmentName: selectedChariot!.name,
                          status: 'dispatched',
                          dispatchedAt: DateTime.now(),
                        ),
                      ),
                    ),
                  );
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
                'Confirmer & Envoyer à l\'Employé',
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
