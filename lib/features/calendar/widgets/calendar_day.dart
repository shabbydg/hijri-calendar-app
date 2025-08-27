import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/hijri_date.dart';
import '../../../core/utils/arabic_numerals.dart';
import '../../../core/services/events_service.dart';

class CalendarDay extends StatelessWidget {
  final Map<String, dynamic> day;
  final bool isToday;
  final bool isCurrentMonth;
  final bool isSelected; // Add selection state
  final bool showMonthName; // Add month name display flag

  const CalendarDay({
    super.key,
    required this.day,
    required this.isToday,
    required this.isCurrentMonth,
    this.isSelected = false, // Make it optional with default false
    this.showMonthName = false, // Make it optional with default false
  });

  @override
  Widget build(BuildContext context) {
    final hijriDate = day['hijriDate'] as HijriDate;
    final gregorianDate = day['gregorianDate'] as DateTime;
    
    // Check if there are events for this day
    final events = EventsService.getEventsForDate(
      hijriDate.getDate(), 
      hijriDate.getMonth()
    );
    final hasEvents = events.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.all(2),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: _getDayColor(),
            borderRadius: BorderRadius.circular(10),
            border: _getBorder(), // Use new border method
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04), // lighter
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hijri date (Arabic numerals)
                    Text(
                      ArabicNumerals.convertToArabicSafe(hijriDate.getDate()),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _getTextColor(),
                        fontFamily: 'KanzAlMarjaan',
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Gregorian date (smaller)
                    Text(
                      showMonthName 
                          ? '${_getMonthAbbreviation(gregorianDate.month)} ${gregorianDate.day}'
                          : '${gregorianDate.day}',
                      style: TextStyle(
                        fontSize: 10,
                        color: _getTextColor().withOpacity(0.56),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Event indicator dots
              if (hasEvents)
                Positioned(
                  bottom: 4,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.take(3).map((event) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: event.isImportant 
                            ? IslamicColors.goldAccent 
                            : IslamicColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDayColor() {
    if (isSelected) {
      return IslamicColors.primaryGreen.withOpacity(0.08); // softer selected
    }
    if (isToday) {
      return IslamicColors.goldAccent.withOpacity(0.08); // softer today
    }
    if (isCurrentMonth) {
      return Colors.white;
    } else {
      return IslamicColors.warmBeige.withOpacity(0.25);
    }
  }

  Border? _getBorder() {
    if (isSelected) {
      return Border.all(
        color: IslamicColors.primaryGreen,
        width: 2,
      );
    }
    if (isToday) {
      return Border.all(
        color: IslamicColors.goldAccent,
        width: 1,
      );
    }
    return Border.all(color: Colors.black.withOpacity(0.04), width: 1);
  }

  Color _getTextColor() {
    if (!isCurrentMonth) {
      return IslamicColors.calligraphyBlack.withOpacity(0.45);
    }
    return IslamicColors.calligraphyBlack;
  }

  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return 'Jan'; // Fallback
    }
  }
}
