import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/empty_state_widget.dart';
import 'supervisor_dashboard.dart';
import 'Bon_de_préparation.dart';

class AIDecisionsEmptyScreen extends StatefulWidget {
  const AIDecisionsEmptyScreen({Key? key}) : super(key: key);

  @override
  State<AIDecisionsEmptyScreen> createState() => _AIDecisionsEmptyScreenState();
}

class _AIDecisionsEmptyScreenState extends State<AIDecisionsEmptyScreen> {
  DateTime? selectedDate;
  DateTime displayMonth = DateTime(2026, 2, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMonthHeader(),
                    const SizedBox(height: 16),
                    CalendarWidget(
                      selectedDate: selectedDate ?? DateTime.now(),
                      displayMonth: displayMonth,
                      onDateSelected: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      onMonthChanged: (month) {
                        setState(() {
                          displayMonth = month;
                        });
                      },
                      decisionData: _getDecisionData(),
                    ),
                    const SizedBox(height: 24),
                    _buildLegend(),
                    const SizedBox(height: 24),
                    if (selectedDate == null)
                      const EmptyStateWidget(
                        imagePath: 'assets/select_date.png',
                        title: 'Sélectionnez une date',
                        message:
                            'Choisissez un jour dans le calendrier ci-dessus\npour voir et gérer les décisions IA.',
                      )
                    else
                      _buildDecisionTypes(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 1, onTap: _onNavBarTap),
    );
  }

  void _onNavBarTap(int index) {
    if (index == 0) {
      // Navigate back to Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SupervisorDashboardScreen(),
        ),
      );
    }
    // Add other navigation cases as needed
    // index 1 = Calendar (current page)
    // index 2 = Map
    // index 3 = Profile
  }

  Widget _buildDecisionTypes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildDecisionTypeCard(
            icon: Icons.description_outlined,
            title: 'Bon de commande',
            subtitle: 'Purchase orders review',
            count: 2,
            color: const Color(0xFF0891B2),
            onTap: () {
              // Navigate to purchase orders
            },
          ),
          const SizedBox(height: 12),
          _buildDecisionTypeCard(
            icon: Icons.assignment_outlined,
            title: 'Bon de préparation',
            subtitle: 'Preparation slips',
            count: 5,
            color: const Color(0xFF0891B2),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PreparationSlipsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildDecisionTypeCard(
            icon: Icons.inventory_2_outlined,
            title: 'Storage',
            subtitle: 'Inventory placement AI',
            count: 3,
            color: const Color(0xFF0891B2),
            onTap: () {
              // Navigate to storage
            },
          ),
          const SizedBox(height: 12),
          _buildDecisionTypeCard(
            icon: Icons.route_outlined,
            title: 'Picking Route',
            subtitle: 'Optimal path optimization',
            count: 8,
            color: const Color(0xFF0891B2),
            onTap: () {
              // Navigate to picking route
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionTypeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  '$count',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Décisions IA',
            style: AppTextStyles.appTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getMonthYearString(displayMonth),
            style: AppTextStyles.screenTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: AppColors.textPrimary),
                onPressed: () {
                  setState(() {
                    displayMonth = DateTime(
                      displayMonth.year,
                      displayMonth.month - 1,
                    );
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: AppColors.textPrimary),
                onPressed: () {
                  setState(() {
                    displayMonth = DateTime(
                      displayMonth.year,
                      displayMonth.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem('En attente', AppColors.warning),
          const SizedBox(width: 24),
          _buildLegendItem('Approuvé', AppColors.success),
          const SizedBox(width: 24),
          _buildLegendItem('Remplacement', AppColors.failure),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _getMonthYearString(DateTime date) {
    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Map<DateTime, Map<String, int>> _getDecisionData() {
    return {
      DateTime(2026, 2, 1): {'pending': 1, 'approved': 0, 'override': 0},
      DateTime(2026, 2, 2): {'pending': 0, 'approved': 1, 'override': 0},
      DateTime(2026, 2, 3): {'pending': 1, 'approved': 0, 'override': 0},
      DateTime(2026, 2, 4): {'pending': 0, 'approved': 0, 'override': 1},
      DateTime(2026, 2, 6): {'pending': 0, 'approved': 2, 'override': 0},
      DateTime(2026, 2, 8): {'pending': 0, 'approved': 1, 'override': 0},
      DateTime(2026, 2, 9): {'pending': 1, 'approved': 0, 'override': 0},
      DateTime(2026, 2, 10): {'pending': 1, 'approved': 0, 'override': 0},
      DateTime(2026, 2, 11): {'pending': 0, 'approved': 1, 'override': 0},
      DateTime(2026, 2, 12): {'pending': 1, 'approved': 0, 'override': 0},
      DateTime(2026, 2, 13): {'pending': 0, 'approved': 2, 'override': 0},
      DateTime(2026, 2, 15): {'pending': 0, 'approved': 1, 'override': 0},
      DateTime(2026, 2, 16): {'pending': 1, 'approved': 0, 'override': 0},
      DateTime(2026, 2, 17): {'pending': 1, 'approved': 0, 'override': 0},
      DateTime(2026, 2, 18): {'pending': 0, 'approved': 1, 'override': 0},
      DateTime(2026, 2, 19): {'pending': 1, 'approved': 0, 'override': 0},
      DateTime(2026, 2, 20): {'pending': 1, 'approved': 0, 'override': 0},
      DateTime(2026, 2, 22): {'pending': 0, 'approved': 1, 'override': 0},
      DateTime(2026, 2, 23): {'pending': 1, 'approved': 0, 'override': 0},
      DateTime(2026, 2, 24): {'pending': 0, 'approved': 1, 'override': 0},
      DateTime(2026, 2, 25): {'pending': 0, 'approved': 1, 'override': 0},
      DateTime(2026, 2, 26): {'pending': 1, 'approved': 0, 'override': 0},
      DateTime(2026, 2, 27): {'pending': 0, 'approved': 1, 'override': 0},
    };
  }
}
