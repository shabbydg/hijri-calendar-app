import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/hijri_calendar.dart';
import '../../../core/models/hijri_date.dart';
import 'calendar_day.dart';

class CalendarGrid extends StatelessWidget {
  final HijriCalendar calendar;
  final HijriDate today;
  final Function(HijriDate?)? onDaySelected; // Add day selection callback
  final int? selectedHijriDay; // Add selected day parameter

  const CalendarGrid({
    super.key,
    required this.calendar,
    required this.today,
    this.onDaySelected, // Make it optional
    this.selectedHijriDay, // Make it optional
  });

  @override
  Widget build(BuildContext context) {
    final weeks = calendar.weeks();
    
    // Flatten all days to detect month transitions across weeks
    final allDays = <Map<String, dynamic>?>[];
    for (final week in weeks) {
      allDays.addAll(week);
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // tighter radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06), // lighter shadow
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Weekday headers
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10), // slimmer
            decoration: const BoxDecoration(
              color: IslamicColors.desertSand, // flat beige
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: _buildWeekdayHeaders(),
            ),
          ),
          
          // Calendar days (non-scrollable; page scrolls)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: List.generate(weeks.length, (weekIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _buildWeekRow(weeks[weekIndex], weekIndex, allDays),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWeekdayHeaders() {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    return weekdays.map((day) {
      return Expanded(
        child: Center(
          child: Text(
            day,
            style: const TextStyle(
              color: IslamicColors.calligraphyBlack,
              fontWeight: FontWeight.w600,
              fontSize: 12, // smaller
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildWeekRow(List<Map<String, dynamic>?> week, int weekIndex, List<Map<String, dynamic>?> allDays) {
    return Row(
      children: week.asMap().entries.map((entry) {
        final weekDayIndex = entry.key;
        final day = entry.value;
        
        if (day == null) {
          return Expanded(child: SizedBox(height: 0));
        }
        
        final hijriDate = day['hijriDate'] as HijriDate;
        final gregorianDate = day['gregorianDate'] as DateTime;
        final isCurrentMonth = !(day['isPrevious'] ?? false) && !(day['isNext'] ?? false);
        final isSelected = selectedHijriDay != null && 
                          selectedHijriDay == hijriDate.getDate() &&
                          isCurrentMonth; // Only select if it's in the current month
        
        // Calculate global index in the flattened allDays list
        final globalIndex = weekIndex * 7 + weekDayIndex;
        
        // Determine if we should show month name for this day
        bool showMonthName = false;
        if (globalIndex == 0) {
          // First day in the entire grid always shows month name
          showMonthName = true;
        } else {
          // Check if month changed from previous day
          final previousDay = allDays[globalIndex - 1];
          if (previousDay != null) {
            final previousGregorianDate = previousDay['gregorianDate'] as DateTime;
            if (gregorianDate.month != previousGregorianDate.month) {
              showMonthName = true;
            }
          }
        }
        
        final cell = CalendarDay(
          day: day,
          isToday: day['isToday'] ?? false,
          isCurrentMonth: isCurrentMonth,
          isSelected: isSelected,
          showMonthName: showMonthName,
        );
        
        return Expanded(
          child: isCurrentMonth
              ? GestureDetector(
                  onTap: () {
                    if (onDaySelected != null) {
                      onDaySelected!(hijriDate);
                    }
                  },
                  child: cell,
                )
              : cell,
        );
      }).toList(),
    );
  }
}
