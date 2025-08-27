import 'hijri_date.dart';

class HijriCalendar {
  final int year;
  final int month;
  final bool isISO;

  static const int minCalendarYear = 1000;
  static const int maxCalendarYear = 3000;

  HijriCalendar(this.year, this.month, {this.isISO = false});

  int getYear() => year;
  int getMonth() => month;
  bool isISOCalendar() => isISO;

  static int getMinYear() => minCalendarYear;
  static int getMaxYear() => maxCalendarYear;

  // Return day of week for the specified date
  int dayOfWeek(int date) {
    final hijriDate = HijriDate(year, month, date);
    final gregorianDate = hijriDate.toGregorian();
    // Convert to 0-6 format (Sunday = 0, Saturday = 6)
    return gregorianDate.weekday % 7;
  }

  // Return array of days of this month and year
  List<Map<String, dynamic>> days() {
    final daysInMonth = HijriDate.daysInMonth(year, month);
    final List<Map<String, dynamic>> result = [];
    
    for (int day = 0; day < daysInMonth; day++) {
      final hijriDate = HijriDate(year, month, day + 1);
      final gregorianDate = hijriDate.toGregorian();
      result.add(dayHash(hijriDate, gregorianDate));
    }
    
    return result;
  }

  // Return array of weeks for this month and year
  List<List<Map<String, dynamic>?>> weeks() {
    final allDays = <Map<String, dynamic>?>[];
    allDays.addAll(previousDays());
    allDays.addAll(days());
    allDays.addAll(nextDays());
    
    // Group into weeks of 7 days
    final List<List<Map<String, dynamic>?>> weeks = [];
    for (int i = 0; i < allDays.length; i += 7) {
      final week = allDays.skip(i).take(7).toList();
      // Pad with nulls if week is incomplete
      while (week.length < 7) {
        week.add(null);
      }
      weeks.add(week);
    }
    
    return weeks;
  }

  // Return array of days from beginning of week until start of this month and year
  List<Map<String, dynamic>?> previousDays() {
    final previousMonth = this.previousMonth();
    final daysInPreviousMonth = HijriDate.daysInMonth(
      previousMonth.getYear(), 
      previousMonth.getMonth()
    );
    final dayAtStartOfMonth = dayOfWeek(1);

    if (month == 0 && year == minCalendarYear) {
      return List.filled(6 - dayAtStartOfMonth, null);
    }

    final List<Map<String, dynamic>?> result = [];
    for (int day = 0; day < dayAtStartOfMonth; day++) {
      final hijriDate = HijriDate(
        previousMonth.getYear(),
        previousMonth.getMonth(),
        daysInPreviousMonth - dayAtStartOfMonth + day + 1
      );
      final gregorianDate = hijriDate.toGregorian();
      result.add(dayHash(hijriDate, gregorianDate, isPrevious: true));
    }
    
    return result;
  }

  // Return array of days from end of this month and year until end of the week
  List<Map<String, dynamic>?> nextDays() {
    final nextMonth = this.nextMonth();
    final daysInMonth = HijriDate.daysInMonth(year, month);
    final dayAtEndOfMonth = dayOfWeek(daysInMonth);

    if (nextMonth.getYear() == year && nextMonth.getMonth() == month) {
      return List.filled(6 - dayAtEndOfMonth, null);
    }

    final List<Map<String, dynamic>?> result = [];
    for (int day = 0; day < 6 - dayAtEndOfMonth; day++) {
      final hijriDate = HijriDate(
        nextMonth.getYear(),
        nextMonth.getMonth(),
        day + 1
      );
      final gregorianDate = hijriDate.toGregorian();
      result.add(dayHash(hijriDate, gregorianDate, isNext: true));
    }
    
    return result;
  }

  // Get previous month
  HijriCalendar previousMonth() {
    if (month == 0) {
      return HijriCalendar(year - 1, 11, isISO: isISO);
    } else {
      return HijriCalendar(year, month - 1, isISO: isISO);
    }
  }

  // Get next month
  HijriCalendar nextMonth() {
    if (month == 11) {
      return HijriCalendar(year + 1, 0, isISO: isISO);
    } else {
      return HijriCalendar(year, month + 1, isISO: isISO);
    }
  }

  // Get previous year
  HijriCalendar previousYear() {
    if (year > minCalendarYear) {
      return HijriCalendar(year - 1, month, isISO: isISO);
    }
    return this;
  }

  // Get next year
  HijriCalendar nextYear() {
    if (year < maxCalendarYear) {
      return HijriCalendar(year + 1, month, isISO: isISO);
    }
    return this;
  }

  // Helper method to create day hash
  Map<String, dynamic> dayHash(HijriDate hijriDate, DateTime gregorianDate, {
    bool isPrevious = false, 
    bool isNext = false
  }) {
    return {
      'hijriDate': hijriDate,
      'gregorianDate': gregorianDate,
      'isPrevious': isPrevious,
      'isNext': isNext,
      'isToday': _isToday(gregorianDate),
    };
  }

  // Check if a date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}
