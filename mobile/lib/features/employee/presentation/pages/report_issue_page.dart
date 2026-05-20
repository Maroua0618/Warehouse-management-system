import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../logic/cubit.dart';
import '../cubit/ingoing_validation_cubit.dart';

/// Issue type model with icon and description.
class IssueType {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  const IssueType({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });
}

/// Report Issue page for employees to report problems to supervisors.
class ReportIssuePage extends StatefulWidget {
  final String? orderId;
  final int? commandId;
  final Function(String reason, String description)? onSubmit;

  const ReportIssuePage({
    super.key,
    this.orderId,
    this.commandId,
    this.onSubmit,
  });

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  IssueType? _selectedIssueType;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  // Issue type options matching Figma design
  static final List<IssueType> _issueTypes = [
    IssueType(
      id: 'damaged_products',
      title: 'Produits Endommagés',
      description: 'Dommages physiques aux articles ou emballages',
      icon: Icons.inventory_2_outlined,
      iconColor: const Color(0xFFE57373),
    ),
    IssueType(
      id: 'wrong_quantity',
      title: 'Quantité Incorrecte',
      description: 'Le nombre reçu ne correspond pas au manifeste',
      icon: Icons.error_outline,
      iconColor: const Color(0xFFFFB74D),
    ),
    IssueType(
      id: 'wrong_sku',
      title: 'SKU Incorrect',
      description: 'Variante d\'article ou code produit incorrect',
      icon: Icons.grid_view_outlined,
      iconColor: const Color(0xFFE57373),
    ),
    IssueType(
      id: 'storage_error',
      title: 'Erreur d\'Affectation',
      description: 'Article placé dans le mauvais bac ou zone',
      icon: Icons.warning_amber_outlined,
      iconColor: const Color(0xFFFFB74D),
    ),
    IssueType(
      id: 'workflow_bottleneck',
      title: 'Goulot d\'Étranglement',
      description: 'Retard de traitement ou panne d\'équipement',
      icon: Icons.hourglass_empty,
      iconColor: const Color(0xFFE57373),
    ),
    IssueType(
      id: 'stock_availability',
      title: 'Problème de Stock',
      description: 'Écart entre stock numérique et physique',
      icon: Icons.inventory_outlined,
      iconColor: const Color(0xFFFFB74D),
    ),
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_selectedIssueType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une raison'),
          backgroundColor: AppColors.accent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final description = _descriptionController.text.isNotEmpty
        ? _descriptionController.text
        : 'Aucune description fournie';

    // Submit issue report to backend
    if (widget.orderId != null) {
      // Use IngoingValidationCubit if available
      try {
        final validationCubit = context.read<IngoingValidationCubit>();
        await validationCubit.reportProblem(
          _selectedIssueType!.id.toUpperCase(),
          description,
        );
      } catch (e) {
        print('IngoingValidationCubit not available: $e');
        // Try EmployeeCubit as fallback
        try {
          final cubit = context.read<EmployeeCubit>();
          await cubit.reportIncident(
            type: _selectedIssueType!.title,
            description: description,
            commandId: widget.commandId,
          );
        } catch (e2) {
          print('EmployeeCubit not available: $e2');
          // Final fallback to callback
          widget.onSubmit?.call(_selectedIssueType!.title, description);
        }
      }
    } else {
      // No orderId, use callback
      widget.onSubmit?.call(_selectedIssueType!.title, description);
    }

    setState(() => _isSubmitting = false);

    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Green checkmark
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 36,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Rapport Envoyé',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Votre rapport a été envoyé au superviseur. Vous serez notifié une fois qu\'il aura été examiné.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Return to Tasks button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Retour aux Tâches',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIssueTypeSelector() {
    String searchQuery = '';
    IssueType? tempSelected = _selectedIssueType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final filteredTypes = _issueTypes.where((type) {
            final query = searchQuery.toLowerCase();
            return type.title.toLowerCase().contains(query) ||
                type.description.toLowerCase().contains(query);
          }).toList();

          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollController) => Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(sheetContext),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Sélectionner le Type de Problème',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setSheetState(() => searchQuery = value);
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Rechercher catégories...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Content area (white background)
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Text(
                              'CATÉGORIES OPÉRATIONNELLES',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          // Issue types list
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: filteredTypes.length,
                              itemBuilder: (context, index) {
                                final type = filteredTypes[index];
                                final isSelected = tempSelected?.id == type.id;

                                return GestureDetector(
                                  onTap: () {
                                    setSheetState(() => tempSelected = type);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.grey.shade200,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Icon
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: type.iconColor.withOpacity(
                                              0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            type.icon,
                                            color: type.iconColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Text
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                type.title,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                type.description,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Radio button
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFFE57373)
                                                  : Colors.grey.shade400,
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? Center(
                                                  child: Container(
                                                    width: 12,
                                                    height: 12,
                                                    decoration:
                                                        const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Color(
                                                            0xFFE57373,
                                                          ),
                                                        ),
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Bottom buttons
                          Container(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              16,
                              20,
                              MediaQuery.of(context).padding.bottom + 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Cancel button
                                Expanded(
                                  child: TextButton(
                                    onPressed: () =>
                                        Navigator.pop(sheetContext),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: const Text(
                                      'Annuler',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Confirm Selection button
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: tempSelected != null
                                        ? () {
                                            setState(
                                              () => _selectedIssueType =
                                                  tempSelected,
                                            );
                                            Navigator.pop(sheetContext);
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE57373),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Confirmer Sélection',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header
          _buildHeader(context),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reason selector
                  _buildReasonSection(),

                  const SizedBox(height: 24),

                  // Description field
                  _buildDescriptionSection(),

                  const SizedBox(height: 16),

                  // Info text
                  Text(
                    'Votre rapport sera envoyé directement au superviseur\nde service.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit button
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Get user from EmployeeCubit
    String initials = 'EM';
    String userName = 'Employé';
    try {
      final state = context.read<EmployeeCubit>().state;
      if (state is EmployeeLoaded) {
        initials = state.currentUser.initials;
        userName = state.currentUser.fullName;
      }
    } catch (_) {
      // Cubit not available, use defaults
    }

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Employee info row
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name and role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'PERSONNEL ENTREPÔT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Notification icon
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Report Issue title row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Signaler Problème',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Raison du Signalement',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        // Selector button
        GestureDetector(
          onTap: _showIssueTypeSelector,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (_selectedIssueType != null) ...[
                  Icon(_selectedIssueType!.icon, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                ],
                Text(
                  _selectedIssueType?.title ?? 'Sélectionner une raison',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText:
                  'Fournissez des détails sur l\'incident pour le\nsuperviseur...',
              hintStyle: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _handleSubmit,
        icon: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.send, size: 20),
        label: Text(
          _isSubmitting ? 'Envoi en cours...' : 'Envoyer',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
