import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/domain/entities/user_entity.dart';
import '../../domain/entities/command_entity.dart';
import '../cubit/ingoing_validation_state.dart';
import '../cubit/ingoing_validation_cubit.dart';
import '../widgets/employee_header.dart';
import 'report_issue_page.dart';

/// Page de validation d'une commande entrante.
/// Design matching Figma with TARGET DESTINATION card, Path Resolved, and mini map.
class IngoingValidationPage extends StatefulWidget {
  final String orderId;
  final UserEntity user;

  const IngoingValidationPage({
    super.key,
    required this.orderId,
    required this.user,
  });

  @override
  State<IngoingValidationPage> createState() => _IngoingValidationPageState();
}

class _IngoingValidationPageState extends State<IngoingValidationPage> {
  final Set<String> _validatedItemIds = {};
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      context.read<IngoingValidationCubit>().loadValidation(widget.orderId);
    }
  }

  bool _areAllItemsValidated(CommandEntity validation) {
    return _validatedItemIds.contains('quantity') &&
        _validatedItemIds.contains('product_type');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocConsumer<IngoingValidationCubit, IngoingValidationState>(
              listener: (context, state) {
                if (state is IngoingValidationCompleted) {
                  _showSuccessDialog();
                } else if (state is IngoingValidationProblemReported) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Problem reported successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is IngoingValidationLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is IngoingValidationError) {
                  return _buildErrorWidget(state.message);
                }

                final validation = _getValidationFromState(state);
                if (validation == null) {
                  return const Center(child: Text('Loading...'));
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildOrderCard(validation),
                      const SizedBox(height: 20),
                      _buildProductValidationSection(validation),
                      const SizedBox(height: 16),
                      _buildLocationPinIcon(),
                      const SizedBox(height: 8),
                      _buildTargetDestinationCard(validation),
                      const SizedBox(height: 24),
                      _buildPathResolvedSection(validation),
                      const SizedBox(height: 16),
                      _buildMiniMap(),
                      const SizedBox(height: 16),
                      _buildEstimatedDelaySavedBadge(validation),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          BlocBuilder<IngoingValidationCubit, IngoingValidationState>(
            builder: (context, state) {
              final validation = _getValidationFromState(state);
              return _buildBottomBar(validation);
            },
          ),
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
      child: EmployeeHeader(
        employeeName: widget.user.fullName,
        employeeInitials: widget.user.initials,
        notificationCount: 0,
      ),
    );
  }

  Widget _buildOrderCard(CommandEntity validation) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF9F3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VALIDATION PROCESS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${validation.displayOrderId}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'IN PROGRESS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductValidationSection(CommandEntity validation) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Product Validation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _showFlagIssueDialog,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag, size: 16, color: Colors.red.shade400),
                      const SizedBox(width: 4),
                      Text(
                        'FLAG ISSUE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildValidationCheckbox(
            'Quantity (${validation.totalItems} units)',
            isValidated: _validatedItemIds.contains('quantity'),
            onTap: () => setState(
              () => _validatedItemIds.contains('quantity')
                  ? _validatedItemIds.remove('quantity')
                  : _validatedItemIds.add('quantity'),
            ),
          ),
          const SizedBox(height: 12),
          _buildValidationCheckbox(
            'Product Type (Electronics)',
            isValidated: _validatedItemIds.contains('product_type'),
            onTap: () => setState(
              () => _validatedItemIds.contains('product_type')
                  ? _validatedItemIds.remove('product_type')
                  : _validatedItemIds.add('product_type'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationCheckbox(
    String label, {
    required bool isValidated,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isValidated ? AppColors.primary : Colors.grey.shade300,
                  width: 2,
                ),
                color: isValidated ? AppColors.primary : Colors.transparent,
              ),
              child: isValidated
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPinIcon() {
    return const Padding(
      padding: EdgeInsets.only(left: 16),
      child: Icon(Icons.location_on, color: AppColors.primary, size: 24),
    );
  }

  Widget _buildTargetDestinationCard(CommandEntity validation) {
    final locationCode = validation.location ?? 'B7-NZ-CW';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              'T A R G E T   D E S T I N A T I O N',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              locationCode,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Location Verified',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
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

  Widget _buildPathResolvedSection(CommandEntity validation) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Path Resolved',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Take Chariot Name (C-04, C-09, C-12)',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMap() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 150,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: CustomPaint(
          painter: _RouteMapPainter(),
          size: const Size(double.infinity, 120),
        ),
      ),
    );
  }

  Widget _buildEstimatedDelaySavedBadge(CommandEntity validation) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'ESTIMATED DELAY SAVED:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              '8 mins',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(CommandEntity? validation) {
    final allValidated =
        validation != null && _areAllItemsValidated(validation);
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
          Expanded(
            child: OutlinedButton(
              onPressed: _showFlagIssueDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade400,
                side: BorderSide(color: Colors.red.shade400, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'REPORT PROBLEM',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: allValidated
                  ? () => context.read<IngoingValidationCubit>().validateTask(
                      widget.orderId,
                      validatedItems: _validatedItemIds.toList(),
                    )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: allValidated
                    ? AppColors.primary
                    : Colors.grey.shade300,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
              ),
              child: const Text(
                'VALIDATE &\nCOMPLETE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.2,
                ),
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
            const Text(
              'Loading Failed',
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
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context
                  .read<IngoingValidationCubit>()
                  .loadValidation(widget.orderId),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFlagIssueDialog() {
    final validationCubit = context.read<IngoingValidationCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider<IngoingValidationCubit>.value(
          value: validationCubit,
          child: ReportIssuePage(orderId: widget.orderId),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
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
              'Validation Complete!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'All items have been validated successfully.',
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
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              child: const Text('Back to List'),
            ),
          ),
        ],
      ),
    );
  }

  CommandEntity? _getValidationFromState(IngoingValidationState state) {
    if (state is IngoingValidationLoaded) return state.validation;
    if (state is IngoingValidationValidating) return state.currentValidation;
    if (state is IngoingValidationItemValidated) return state.validation;
    if (state is IngoingValidationProductValidated) return state.validation;
    if (state is IngoingValidationProblemReported) return state.validation;
    if (state is IngoingValidationError) return state.previousValidation;
    return null;
  }
}

class _RouteMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dashedPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final textStyle = TextStyle(color: Colors.grey.shade500, fontSize: 10);
    final path = Path();
    final startX = 20.0;
    final startY = 20.0;
    path.moveTo(startX, startY);
    path.lineTo(size.width * 0.4, startY);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width * 0.8, size.height * 0.4);
    path.lineTo(size.width * 0.6, size.height * 0.8);
    _drawDashedPath(canvas, path, dashedPaint);
    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(startX, startY), 6, pointPaint);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.4),
      6,
      pointPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.8),
      6,
      pointPaint,
    );
    _drawText(canvas, 'A1', Offset(startX - 5, startY - 18), textStyle);
    _drawText(
      canvas,
      'D2',
      Offset(size.width * 0.8 + 5, size.height * 0.4 - 8),
      textStyle,
    );
    _drawText(
      canvas,
      'B4',
      Offset(size.width * 0.4 - 15, size.height * 0.6 + 5),
      textStyle,
    );
    _drawText(
      canvas,
      'C7',
      Offset(size.width * 0.6 - 5, size.height * 0.8 + 10),
      textStyle,
    );
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final pathSegment = metric.extractPath(distance, distance + 8);
        canvas.drawPath(pathSegment, paint);
        distance += 16;
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
