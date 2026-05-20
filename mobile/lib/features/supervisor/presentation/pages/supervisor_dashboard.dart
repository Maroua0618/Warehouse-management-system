import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/bottom_nav_bar.dart';
import 'operational_issues.dart';
import 'calendar.dart';
import '../operational_monitor/operational_monitor_screen.dart';
import '../bon de préparation/Bon_de_préparation.dart';
import '../../data/repositories/supervisor_repository.dart';
import '../../data/models/supervisor_models.dart';

class SupervisorDashboardScreen extends StatefulWidget {
  const SupervisorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SupervisorDashboardScreen> createState() =>
      _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends State<SupervisorDashboardScreen> {
  final SupervisorRepository _repository = SupervisorRepository();
  DashboardStats? _stats;
  List<RecentActivity> _activities = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Parallelize API calls for faster loading
      final results = await Future.wait([
        _repository.getDashboardStats(),
        _repository.getRecentActivity(limit: 3),
      ]);

      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      setState(() {
        _stats = results[0] as DashboardStats;
        _activities = results[1] as List<RecentActivity>;
        _isLoading = false;
      });
    } catch (e) {
      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().contains('timed out')
            ? 'Le serveur ne répond pas. Vérifiez votre connexion.'
            : 'Erreur de chargement: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _buildErrorState()
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: Column(
                  children: [
                    // Header
                    _buildHeader(),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            // Operational Issues Banner
                            _buildOperationalIssuesBanner(context),

                            const SizedBox(height: 16),

                            // Stats Grid
                            _buildStatsGrid(),

                            const SizedBox(height: 24),

                            // AI Performance Card
                            _buildAIPerformanceCard(),

                            const SizedBox(height: 24),

                            const SizedBox(height: 24),

                            // Recent Activity
                            _buildRecentActivity(),

                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0, onTap: _onNavBarTap),
    );
  }

  void _onNavBarTap(int index) {
    if (index == 1) {
      // Navigate to Calendar
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AIDecisionsEmptyScreen()),
      );
    } else if (index == 2) {
      // Navigate to Map/Operational Monitor
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OperationalMonitorScreen(),
        ),
      );
    }
    // index 0 = Dashboard (current page)
    // index 3 = Profile
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.failure),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Une erreur est survenue',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
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
            'Accueil',
            style: AppTextStyles.appTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.accent,
                child: Icon(Icons.person, color: Colors.white, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalIssuesBanner(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OperationalIssuesScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: AppColors.failure, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Problèmes opérationnels',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.failure,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.failure, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final activeEmployees = _stats?.activeEmployees ?? 0;
    final pendingViolations = _stats?.pendingViolations ?? 0;
    final ordersToday = _stats?.ordersToday ?? 0;
    final aiOverrides = _stats?.aiOverrides ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.groups,
                  iconColor: AppColors.success,
                  number: '$activeEmployees',
                  label: 'Employés actifs',
                  badge: activeEmployees > 0 ? 'EN DIRECT' : null,
                  badgeColor: AppColors.success,
                  borderColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.warning,
                  iconColor: AppColors.warning,
                  number: '$pendingViolations',
                  label: 'Validations en attente',
                  badge: pendingViolations > 0 ? 'URGENT' : null,
                  badgeColor: AppColors.warning,
                  borderColor: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.receipt,
                  iconColor: AppColors.primary,
                  number: '$ordersToday',
                  label: 'Commandes aujourd\'hui',
                  borderColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.error_outline,
                  iconColor: AppColors.warning,
                  number: '$aiOverrides',
                  label: 'Remplacements IA',
                  borderColor: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String number,
    required String label,
    String? badge,
    Color? badgeColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Icon(icon, color: iconColor, size: 24),
              if (badge != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: badgeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            number,
            style: AppTextStyles.appTitle.copyWith(
              color: AppColors.textPrimary,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIPerformanceCard() {
    final performancePercentage = _stats?.performancePercentage ?? 0.0;
    final performanceValue = performancePercentage / 100;
    final performanceText = '${performancePercentage.toInt()}%';
    final savedDistance = (_stats?.savedTodayMeters ?? 0.0).toInt();
    final aiOverrides = _stats?.aiOverrides ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'PERFORMANCE IA',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary.withOpacity(0.6),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circular Progress
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: performanceValue,
                        strokeWidth: 8,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          performanceText,
                          style: AppTextStyles.appTitle.copyWith(
                            color: AppColors.primary,
                            fontSize: 28,
                          ),
                        ),
                        Text(
                          'PRÉCISION',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${savedDistance}m',
                      style: AppTextStyles.appTitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Distance moyenne économisée',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          '$aiOverrides',
                          style: AppTextStyles.sectionHeader.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Remplacements',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Voir le rapport d\'optimisation détaillé',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.trending_up, color: AppColors.primary, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVITÉ RÉCENTE',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.history, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Journaux',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (_activities.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Aucune activité récente',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  ..._activities.asMap().entries.map((entry) {
                    final index = entry.key;
                    final activity = entry.value;
                    return Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildActivityItem(
                          title: activity.title,
                          description: activity.description,
                          time: _formatTimestamp(activity.timestamp),
                          color: _getActivityColor(activity.type),
                        ),
                        if (index < _activities.length - 1)
                          const Divider(height: 24),
                      ],
                    );
                  }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'MANUAL_OVERRIDE':
        return AppColors.warning;
      case 'BULK_RECEIPT':
        return AppColors.primary;
      case 'SYSTEM_NOTIFICATION':
        return AppColors.textSecondary.withOpacity(0.3);
      default:
        return AppColors.primary;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'il y a ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'il y a ${difference.inHours}h';
    } else {
      return 'il y a ${difference.inDays}j';
    }
  }

  Widget _buildActivityItem({
    required String title,
    required String description,
    required String time,
    String? badge,
    String? id,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    time,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (badge != null || id != null) const SizedBox(height: 8),
              if (badge != null || id != null)
                Row(
                  children: [
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (badge != null && id != null) const SizedBox(width: 8),
                    if (id != null)
                      Text(
                        id,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
