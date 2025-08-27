class PrayerTimes {
  final String sihori;
  final String fajr;
  final String sunrise;
  final String zawaal;
  final String zohrEnd;
  final String asrEnd;
  final String maghrib;
  final String maghribEnd;
  final String nisfulLayl;
  final String nisfulLaylEnd;
  final DateTime date;

  PrayerTimes({
    required this.sihori,
    required this.fajr,
    required this.sunrise,
    required this.zawaal,
    required this.zohrEnd,
    required this.asrEnd,
    required this.maghrib,
    required this.maghribEnd,
    required this.nisfulLayl,
    required this.nisfulLaylEnd,
    required this.date,
  });

  // Factory method for API response format
  factory PrayerTimes.fromApiResponse(Map<String, dynamic> json, String dateString) {
    return PrayerTimes(
      sihori: json['sihori'] ?? '',
      fajr: json['fajr'] ?? '',
      sunrise: json['sunrise'] ?? '',
      zawaal: json['zawaal'] ?? '',
      zohrEnd: json['zohr_end'] ?? '',
      asrEnd: json['asr_end'] ?? '',
      maghrib: json['maghrib'] ?? '',
      maghribEnd: json['maghrib_end'] ?? '',
      nisfulLayl: json['nisful_layl'] ?? '',
      nisfulLaylEnd: json['nisful_layl_end'] ?? '',
      date: DateTime.parse(dateString),
    );
  }

  // Legacy factory method for backward compatibility
  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      sihori: json['sihori'] ?? '',
      fajr: json['fajr'] ?? '',
      sunrise: json['sunrise'] ?? '',
      zawaal: json['zawaal'] ?? json['dhuhr'] ?? '',
      zohrEnd: json['zohr_end'] ?? '',
      asrEnd: json['asr_end'] ?? '',
      maghrib: json['maghrib'] ?? '',
      maghribEnd: json['maghrib_end'] ?? '',
      nisfulLayl: json['nisful_layl'] ?? json['isha'] ?? '',
      nisfulLaylEnd: json['nisful_layl_end'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sihori': sihori,
      'fajr': fajr,
      'sunrise': sunrise,
      'zawaal': zawaal,
      'zohr_end': zohrEnd,
      'asr_end': asrEnd,
      'maghrib': maghrib,
      'maghrib_end': maghribEnd,
      'nisful_layl': nisfulLayl,
      'nisful_layl_end': nisfulLaylEnd,
      'date': date.toIso8601String(),
    };
  }

  // Helper getters for backward compatibility
  String get dhuhr => zawaal;
  String get asr => asrEnd;
  String get isha => nisfulLayl;

  String getNextPrayer() {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final prayers = [
      {'name': 'Fajr', 'time': fajr},
      {'name': 'Sunrise', 'time': sunrise},
      {'name': 'Zawaal', 'time': zawaal},
      {'name': 'Asr', 'time': asrEnd},
      {'name': 'Maghrib', 'time': maghrib},
      {'name': 'Nisful Layl', 'time': nisfulLayl},
    ];

    for (final prayer in prayers) {
      if (prayer['time']!.compareTo(currentTime) > 0) {
        return prayer['name']!;
      }
    }
    
    return 'Fajr'; // If all prayers passed, next is Fajr tomorrow
  }

  String getCurrentPrayerPeriod() {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    if (currentTime.compareTo(fajr) >= 0 && currentTime.compareTo(sunrise) < 0) {
      return 'Fajr';
    } else if (currentTime.compareTo(sunrise) >= 0 && currentTime.compareTo(zawaal) < 0) {
      return 'Sunrise to Zawaal';
    } else if (currentTime.compareTo(zawaal) >= 0 && currentTime.compareTo(asrEnd) < 0) {
      return 'Zawaal to Asr';
    } else if (currentTime.compareTo(asrEnd) >= 0 && currentTime.compareTo(maghrib) < 0) {
      return 'Asr to Maghrib';
    } else if (currentTime.compareTo(maghrib) >= 0 && currentTime.compareTo(nisfulLayl) < 0) {
      return 'Maghrib to Nisful Layl';
    } else {
      return 'Nisful Layl to Fajr';
    }
  }

  String formatTime(String time) {
    // Convert 24-hour format to 12-hour format in 6.03pm style
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      
      if (hour == 0) {
        return '12.$minute am';
      } else if (hour < 12) {
        return '$hour.$minute am';
      } else if (hour == 12) {
        return '12.$minute pm';
      } else {
        final displayHour = hour - 12;
        return '$displayHour.$minute pm';
      }
    } catch (e) {
      return time;
    }
  }

  String getTimeUntilNextPrayer() {
    final now = DateTime.now();
    final nextPrayer = getNextPrayer();
    
    String nextPrayerTime = '';
    switch (nextPrayer) {
      case 'Fajr':
        nextPrayerTime = fajr;
        break;
      case 'Sunrise':
        nextPrayerTime = sunrise;
        break;
      case 'Zawaal':
        nextPrayerTime = zawaal;
        break;
      case 'Asr':
        nextPrayerTime = asrEnd;
        break;
      case 'Maghrib':
        nextPrayerTime = maghrib;
        break;
      case 'Nisful Layl':
        nextPrayerTime = nisfulLayl;
        break;
    }
    
    // Calculate time difference
    try {
      final prayerParts = nextPrayerTime.split(':');
      final prayerHour = int.parse(prayerParts[0]);
      final prayerMinute = int.parse(prayerParts[1]);
      
      final prayerDateTime = DateTime(now.year, now.month, now.day, prayerHour, prayerMinute);
      final difference = prayerDateTime.difference(now);
      
      if (difference.isNegative) {
        return 'Prayer time has passed';
      }
      
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      
      if (hours > 0) {
        return '${hours}h ${minutes}m until $nextPrayer';
      } else {
        return '${minutes}m until $nextPrayer';
      }
    } catch (e) {
      return 'Unable to calculate time';
    }
  }

  bool isPrayerTime() {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Check if current time is within 5 minutes of any prayer time
    final prayers = [fajr, sunrise, zawaal, asrEnd, maghrib, nisfulLayl];
    
    for (final prayerTime in prayers) {
      if (_isTimeClose(currentTime, prayerTime, 5)) {
        return true;
      }
    }
    
    return false;
  }

  bool _isTimeClose(String time1, String time2, int minutes) {
    try {
      final parts1 = time1.split(':');
      final parts2 = time2.split(':');
      
      final minutes1 = int.parse(parts1[0]) * 60 + int.parse(parts1[1]);
      final minutes2 = int.parse(parts2[0]) * 60 + int.parse(parts2[1]);
      
      final difference = (minutes1 - minutes2).abs();
      return difference <= minutes;
    } catch (e) {
      return false;
    }
  }
}
