import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/operational_monitor_models.dart';

/// Screen showing detailed 3D map view of warehouse with all employees
class DetailedMapScreen extends StatefulWidget {
  final List<Employee> employees;
  final String floor;

  const DetailedMapScreen({
    Key? key,
    required this.employees,
    required this.floor,
  }) : super(key: key);

  @override
  State<DetailedMapScreen> createState() => _DetailedMapScreenState();
}

class _DetailedMapScreenState extends State<DetailedMapScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Employee? _selectedEmployee;

  String _getFloorImage(String floor) {
    switch (floor) {
      case 'RDC':
        return 'assets/picking floor.png';
      case 'Floor 1':
      case 'Floor 2':
        return 'assets/First and second storage floors.png';
      case 'Floor 3':
      case 'Floor 4':
        return 'assets/Third and fourth storage floors.png';
      default:
        return 'assets/picking floor.png';
    }
  }

  List<Employee> get _filteredEmployees {
    if (_searchQuery.isEmpty) return widget.employees;
    return widget.employees.where((employee) {
      return employee.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  // Map view
                  Column(
                    children: [
                      Expanded(flex: 3, child: _buildMapView()),
                      // Legend
                      _buildLegend(),
                      // Employee List
                      Expanded(flex: 2, child: _buildEmployeeList()),
                    ],
                  ),

                  // Search bar overlay
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: _buildSearchBar(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            'Carte Détaillée - ${widget.floor}',
            style: AppTextStyles.screenTitle.copyWith(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA)),
      child: Stack(
        children: [
          // 3D Warehouse background
          Center(
            child: Image.asset(
              _getFloorImage(widget.floor),
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Light overlay for better contrast
          Container(color: Colors.white.withOpacity(0.3)),

          // Employee markers
          ..._filteredEmployees.map(
            (employee) => _buildDetailedEmployeeMarker(employee),
          ),

          // Center/Recenter button
          Positioned(
            top: 80,
            right: 16,
            child: Column(
              children: [
                _buildMapControlButton(
                  icon: Icons.my_location,
                  onPressed: () {
                    // Recenter map logic
                  },
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  icon: Icons.zoom_in,
                  onPressed: () {
                    // Zoom in logic
                  },
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  icon: Icons.zoom_out,
                  onPressed: () {
                    // Zoom out logic
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }

  Widget _buildDetailedEmployeeMarker(Employee employee) {
    Color markerColor;
    switch (employee.status) {
      case EmployeeStatus.active:
        markerColor = const Color(0xFF10B981);
        break;
      case EmployeeStatus.idle:
        markerColor = const Color(0xFFF59E0B);
        break;
      case EmployeeStatus.standby:
        markerColor = const Color(0xFF3B82F6);
        break;
      case EmployeeStatus.offline:
        markerColor = const Color(0xFFEF4444);
        break;
    }

    return Positioned(
      left: employee.location.x * MediaQuery.of(context).size.width * 0.8,
      top: employee.location.y * 300,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedEmployee = employee;
          });
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: markerColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: _selectedEmployee?.id == employee.id ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: markerColor.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Center(
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Rechercher Employés (e.g. EMP-01)...',
          hintStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
          bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('Active', const Color(0xFF10B981)),
          _buildLegendItem('Idle', const Color(0xFFF59E0B)),
          _buildLegendItem('Standby', const Color(0xFF3B82F6)),
          _buildLegendItem('Offline', const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeList() {
    return Container(
      color: AppColors.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredEmployees.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final employee = _filteredEmployees[index];
          return _buildEmployeeCard(employee);
        },
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    Color statusColor;
    switch (employee.status) {
      case EmployeeStatus.active:
        statusColor = const Color(0xFF10B981);
        break;
      case EmployeeStatus.idle:
        statusColor = const Color(0xFFF59E0B);
        break;
      case EmployeeStatus.standby:
        statusColor = const Color(0xFF3B82F6);
        break;
      case EmployeeStatus.offline:
        statusColor = const Color(0xFFEF4444);
        break;
    }

    final bool isSelected = _selectedEmployee?.id == employee.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEmployee = employee;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? statusColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? statusColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Status indicator with employee icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(Icons.person, color: statusColor, size: 24),
              ),
            ),
            const SizedBox(width: 12),

            // Employee info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          employee.name,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          employee.status.label,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    employee.role,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    employee.location.locationDescription,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
