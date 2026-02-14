import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class OperationalIssuesScreen extends StatefulWidget {
  const OperationalIssuesScreen({Key? key}) : super(key: key);

  @override
  State<OperationalIssuesScreen> createState() =>
      _OperationalIssuesScreenState();
}

class _OperationalIssuesScreenState extends State<OperationalIssuesScreen> {
  String selectedFilter = 'Tous';

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
          'Problèmes opérationnels',
          style: AppTextStyles.screenTitle.copyWith(
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Stats Cards
          _buildStatsCards(),

          const SizedBox(height: 16),

          // Filter Chips
          _buildFilterChips(),

          const SizedBox(height: 16),

          // Issues List
          Expanded(child: _buildIssuesList()),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: 100,
              child: _buildStatCard('EN ATTENTE', '4', AppColors.warning),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 110,
              height: 100,
              child: _buildStatCard('PRIORITÉ HAUTE', '2', AppColors.failure),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 110,
              height: 100,
              child: _buildStatCard('RÉSOLUS', '12', AppColors.success),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 8,
              letterSpacing: 0.2,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: AppTextStyles.appTitle.copyWith(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Tous', 'Endommagés', 'Goulots', 'Retards'];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: filters.map((filter) {
            final isSelected = selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Text(filter),
                onSelected: (selected) {
                  setState(() {
                    selectedFilter = filter;
                  });
                },
                backgroundColor: AppColors.background,
                selectedColor: AppColors.primary,
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide.none,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildIssuesList() {
    return Container(
      color: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildIssueCard(
            initials: 'KM',
            initialsColor: const Color(0xFF3B82F6),
            name: 'Karim',
            time: 'IL Y A 16 MIN',
            badge: 'PRODUIT ENDOMMAGÉ',
            badgeColor: AppColors.failure,
            description:
                '3 cartons fissurés de SKU-4922 trouvés dans l\'allée 4. La palette semble être tombée lors du déchargement.',
          ),
          const SizedBox(height: 12),
          _buildIssueCard(
            initials: 'SL',
            initialsColor: const Color(0xFF8B5CF6),
            name: 'Sarah Lopez',
            time: 'IL Y A 43 MIN',
            badge: 'GOULOT D\'ÉTRANGLEMENT',
            badgeColor: AppColors.warning,
            description:
                'Le tapis roulant 2 est bloqué près de la station de tri. La maintenance a été appelée mais n\'est pas encore arrivée.',
          ),
          const SizedBox(height: 12),
          _buildIssueCard(
            initials: 'RJ',
            initialsColor: const Color(0xFF10B981),
            name: 'Robert J.',
            time: 'IL Y A 1 HEURE',
            badge: 'PROBLÈME DE STOCK',
            badgeColor: const Color(0xFF3B82F6),
            description:
                'Alerte de stock faible pour les matériaux d\'emballage (Boîtes Moyennes). Moins de 50 unités restantes dans la zone B.',
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCard({
    required String initials,
    required Color initialsColor,
    required String name,
    required String time,
    required String badge,
    required Color badgeColor,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and badge
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: initialsColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: initialsColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Examiner',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Ignorer',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
