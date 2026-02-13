import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/report_issue_page.dart';

/// Simple red text link for reporting problem with order - matches Figma design.
class ReportProblemCard extends StatelessWidget {
  final String? orderId;
  final Function(String reason, String description)? onSubmitProblem;

  const ReportProblemCard({super.key, this.orderId, this.onSubmitProblem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ReportIssuePage(orderId: orderId, onSubmit: onSubmitProblem),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.failure,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Report Problem with Order',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.failure,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
