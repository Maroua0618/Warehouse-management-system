import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/ingoing_validation_state.dart';
import '../cubit/mock_ingoing_validation_cubit.dart';
import '../widgets/path_resolved_card.dart';
import '../widgets/target_destination_card.dart';
import '../widgets/validation_process_card.dart';
import '../widgets/employee_header.dart';
import '../widgets/order_type_toggle.dart';
import 'report_issue_page.dart';

/// Page de validation d'une commande entrante.
/// Affiche les étapes de validation, le chemin de transport et permet de valider les articles.
class IngoingValidationPage extends StatefulWidget {
  final String orderId;

  const IngoingValidationPage({super.key, required this.orderId});

  @override
  State<IngoingValidationPage> createState() => _IngoingValidationPageState();
}

class _IngoingValidationPageState extends State<IngoingValidationPage> {
  // State for product validation checkboxes
  bool _isQuantityValidated = false;
  bool _isProductTypeValidated = false;

  @override
  void initState() {
    super.initState();
    context.read<MockIngoingValidationCubit>().loadValidation(widget.orderId);
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
            child:
                BlocConsumer<
                  MockIngoingValidationCubit,
                  IngoingValidationState
                >(
                  listener: (context, state) {
                    if (state is IngoingValidationCompleted) {
                      _showSuccessDialog();
                    } else if (state is IngoingValidationProblemReported) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Problème signalé avec succès'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is IngoingValidationLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (state is IngoingValidationError) {
                      return _buildErrorWidget(state.message);
                    }

                    final validation = _getValidationFromState(state);
                    if (validation == null) {
                      return const Center(child: Text('Chargement...'));
                    }

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Validation process card (order + product validation)
                          ValidationProcessCard(
                            validation: validation,
                            isQuantityValidated: _isQuantityValidated,
                            isProductTypeValidated: _isProductTypeValidated,
                            onQuantityTap: () {
                              setState(() {
                                _isQuantityValidated = !_isQuantityValidated;
                              });
                            },
                            onProductTypeTap: () {
                              setState(() {
                                _isProductTypeValidated =
                                    !_isProductTypeValidated;
                              });
                            },
                            onValidateProduct: () {
                              context
                                  .read<MockIngoingValidationCubit>()
                                  .validateProduct();
                            },
                            onFlagIssue: () {
                              _showFlagIssueDialog();
                            },
                          ),

                          const SizedBox(height: 20),

                          // Target Destination section
                          const TargetDestinationCard(
                            destinationCode: 'B7-N1-C2',
                            isVerified: true,
                          ),

                          const SizedBox(height: 24),

                          // Path Resolved section with visualization
                          const PathResolvedCard(
                            chariotName: 'Take Chariot Name',
                            chariotCodes: ['C-04', 'C-09', 'C-12'],
                            estimatedDelaySaved: 8,
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Employee header
          const EmployeeHeader(
            employeeName: 'Nom Employé',
            employeeInitials: 'CH',
            notificationCount: 0,
          ),

          const SizedBox(height: 14),

          // Toggle (showing incoming selected)
          OrderTypeToggle(selectedType: 'incoming', onTypeChanged: (_) {}),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Report problem button
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showFlagIssueDialog(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.failure,
                side: const BorderSide(color: AppColors.failure, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'SIGNALER PROBLÈME',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Validate & complete button
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                context.read<MockIngoingValidationCubit>().completeValidation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'VALIDER',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.failure.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Échec du Chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<MockIngoingValidationCubit>().loadValidation(
                  widget.orderId,
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFlagIssueDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportIssuePage()),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 48,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Validation Terminée!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tous les articles ont été validés avec succès.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(this.context, true); // Return validated status
              },
              child: const Text('Retour à la Liste'),
            ),
          ),
        ],
      ),
    );
  }

  _getValidationFromState(IngoingValidationState state) {
    if (state is IngoingValidationLoaded) return state.validation;
    if (state is IngoingValidationValidating) return state.currentValidation;
    if (state is IngoingValidationItemValidated) return state.validation;
    if (state is IngoingValidationProductValidated) return state.validation;
    if (state is IngoingValidationProblemReported) return state.validation;
    if (state is IngoingValidationError) return state.previousValidation;
    return null;
  }
}
