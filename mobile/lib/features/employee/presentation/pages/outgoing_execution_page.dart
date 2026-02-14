import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/domain/entities/user_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/command_entity.dart';
import '../cubit/outgoing_execution_cubit.dart';
import '../cubit/outgoing_execution_state.dart';
import '../widgets/confirm_delivery_dialog.dart';
import 'order_already_validated_page.dart';
import 'report_issue_page.dart';

class OutgoingExecutionPage extends StatefulWidget {
  final String orderId;
  final UserEntity user;

  const OutgoingExecutionPage({
    super.key,
    required this.orderId,
    required this.user,
  });

  @override
  State<OutgoingExecutionPage> createState() => _OutgoingExecutionPageState();
}

class _OutgoingExecutionPageState extends State<OutgoingExecutionPage> {
  @override
  void initState() {
    super.initState();
    // Load execution data when page opens
    context.read<OutgoingExecutionCubit>().loadExecution(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OutgoingExecutionCubit, OutgoingExecutionState>(
      listener: (context, state) {
        if (state is OutgoingExecutionDeliveryConfirmed) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OrderAlreadyValidatedPage(
                orderId: widget.orderId,
                isOutgoing: true,
                deliveryId: state.command.displayOrderId,
                skuReference: state.command.displayOrderId,
              ),
            ),
          );
        } else if (state is OutgoingExecutionCompleted) {
          Navigator.of(context).pop(true);
        } else if (state is OutgoingExecutionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.failure,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<OutgoingExecutionCubit, OutgoingExecutionState>(
            builder: (context, state) {
              if (state is OutgoingExecutionLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (state is OutgoingExecutionError &&
                  state.previousCommand == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.failure,
                      ),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context
                            .read<OutgoingExecutionCubit>()
                            .loadExecution(widget.orderId),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                );
              }

              final command = _getCommandFromState(state);

              return Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildHeader(),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: -40,
                        child: _buildValidationProcessCard(command),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDeliveryInfoRow(command),
                          const SizedBox(height: 20),
                          _buildFinalDestination(command),
                          const SizedBox(height: 20),
                          _buildItemsList(command),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomBar(command),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  CommandEntity? _getCommandFromState(OutgoingExecutionState state) {
    if (state is OutgoingExecutionLoaded) return state.command;
    if (state is OutgoingExecutionProcessing) return state.currentCommand;
    if (state is OutgoingExecutionItemPicked) return state.command;
    if (state is OutgoingExecutionDeliveryConfirmed) return state.command;
    if (state is OutgoingExecutionProblemReported) return state.command;
    if (state is OutgoingExecutionError) return state.previousCommand;
    return null;
  }

  String _statusToLabel(CommandStatus? status) {
    switch (status) {
      case CommandStatus.pending:
        return 'EN ATTENTE';
      case CommandStatus.inProgress:
        return 'EN COURS';
      case CommandStatus.completed:
        return 'TERMINÉ';
      case CommandStatus.cancelled:
        return 'ANNULÉ';
      case null:
        return 'EN COURS';
    }
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.textOnPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.user.initials,
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EMPLOYÉ',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textOnPrimary.withOpacity(0.8),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.user.fullName,
                  style: AppTextStyles.cardTitle.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationProcessCard(CommandEntity? command) {
    final statusLabel = _statusToLabel(command?.status);
    final orderLabel = command?.displayOrderId ?? widget.orderId;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROCESSUS DE VALIDATION',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel.toUpperCase(),
                  style: AppTextStyles.badge.copyWith(
                    color: AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Commande #$orderLabel',
            style: AppTextStyles.cardTitle.copyWith(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoRow(CommandEntity? command) {
    final deliveryId = command?.displayOrderId ?? '-';
    final location = command?.displayLocation ?? '-';
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.local_shipping_outlined,
            label: 'ID Livraison',
            value: deliveryId,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.layers_outlined,
            label: 'Emplacement',
            value: location,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalDestination(CommandEntity? command) {
    final destination = command?.displayLocation ?? '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Destination Finale',
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Zone de chargement',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(CommandEntity? command) {
    final items = command?.items ?? [];
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Articles (${items.length})',
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.sku,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Qté: ${item.quantity} • ${item.location ?? 'N/A'}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  item.isValidated
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: item.isValidated
                      ? AppColors.success
                      : AppColors.textSecondary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(CommandEntity? command) {
    final itemCount = command?.items.length ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReportIssuePage(orderId: widget.orderId),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.failure,
                side: BorderSide(color: AppColors.failure, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'SIGNALER',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.failure,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: BlocBuilder<OutgoingExecutionCubit, OutgoingExecutionState>(
              builder: (context, state) {
                final isProcessing = state is OutgoingExecutionProcessing;
                return ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => ConfirmDeliveryDialog(
                              deliveryId:
                                  command?.displayOrderId ?? widget.orderId,
                              itemsVerified: itemCount,
                              onValidate: () {
                                Navigator.of(dialogContext).pop();
                                context
                                    .read<OutgoingExecutionCubit>()
                                    .confirmDelivery();
                              },
                              onBack: () {
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Valider',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
