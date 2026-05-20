import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime displayMonth;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onMonthChanged;
  final Map<DateTime, Map<String, int>>? decisionData;

  const CalendarWidget({
    Key? key,
    required this.selectedDate,
    required this.displayMonth,
    required this.onDateSelected,
    required this.onMonthChanged,
    this.decisionData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildWeekdayHeaders(),
          const SizedBox(height: 16),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    final weekdays = ['DI', 'LU', 'MA', 'ME', 'JE', 'VE', 'SA'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final lastDayOfMonth = DateTime(
      displayMonth.year,
      displayMonth.month + 1,
      0,
    );
    final startingWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> dayWidgets = [];

    // Add empty cells for days before the first day
    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 44, height: 44));
    }

    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(displayMonth.year, displayMonth.month, day);
      dayWidgets.add(_buildDayCell(date));
    }

    // Create rows of 7 days
    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayWidgets.sublist(
              i,
              i + 7 > dayWidgets.length ? dayWidgets.length : i + 7,
            ),
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildDayCell(DateTime date) {
    final isSelected =
        selectedDate.year == date.year &&
        selectedDate.month == date.month &&
        selectedDate.day == date.day;

    final isToday =
        DateTime.now().year == date.year &&
        DateTime.now().month == date.month &&
        DateTime.now().day == date.day;

    final dateKey = DateTime(date.year, date.month, date.day);
    final hasData = decisionData?.containsKey(dateKey) ?? false;
    final data = decisionData?[dateKey];

    final isInactive = date.month != displayMonth.month;

    return GestureDetector(
      onTap: () => onDateSelected(date),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(color: AppColors.primary, width: 1)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              date.day.toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : isInactive
                    ? AppColors.textSecondary.withOpacity(0.3)
                    : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (hasData && !isSelected)
              Positioned(
                bottom: 6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if ((data?['pending'] ?? 0) > 0)
                      _buildIndicatorDot(AppColors.warning),
                    if ((data?['approved'] ?? 0) > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: _buildIndicatorDot(AppColors.success),
                      ),
                    if ((data?['override'] ?? 0) > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: _buildIndicatorDot(AppColors.failure),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorDot(Color color) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
