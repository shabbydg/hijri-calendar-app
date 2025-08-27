import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/models/hijri_calendar.dart';
import '../core/models/hijri_date.dart';
import '../core/models/prayer_times.dart';
import '../core/services/prayer_times_service.dart';
import '../features/calendar/widgets/calendar_grid.dart';
import '../features/calendar/widgets/month_controls.dart';
import '../features/calendar/widgets/year_controls.dart';
import '../features/calendar/widgets/today_button.dart';
import '../features/calendar/widgets/islamic_pattern_header.dart';
import '../features/calendar/widgets/events_details_panel.dart';
import '../features/settings/screens/settings_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late HijriCalendar _calendar;
  late HijriDate _today;
  PrayerTimes? _prayerTimes;
  bool _isLoadingPrayerTimes = false;
  int? _selectedHijriDay; // Track selected day for events
  int? _selectedHijriMonth; // Track selected month for events
  int? _selectedHijriYear; // Track selected year for events
  String? _currentLocation; // Track current location

  @override
  void initState() {
    super.initState();
    _today = HijriDate.fromGregorian(DateTime.now());
    _calendar = HijriCalendar(_today.getYear(), _today.getMonth());
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _isLoadingPrayerTimes = true;
    });

    try {
      // Use the real API service with Colombo fallback
      final prayerTimes = await PrayerTimesService.getTodayPrayerTimes();
      
      setState(() {
        _prayerTimes = prayerTimes;
        _isLoadingPrayerTimes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPrayerTimes = false;
      });
      print('Error loading prayer times: $e');
    }
  }

  void _changeMonth(int monthChange) {
    setState(() {
      if (monthChange < 0) {
        _calendar = _calendar.previousMonth();
      } else {
        _calendar = _calendar.nextMonth();
      }
      // Clear selection when changing months
      _selectedHijriDay = null;
      _selectedHijriMonth = null;
      _selectedHijriYear = null;
    });
  }

  void _changeYear(int yearChange) {
    setState(() {
      if (yearChange < 0) {
        _calendar = _calendar.previousYear();
      } else {
        _calendar = _calendar.nextYear();
      }
      // Clear selection when changing years
      _selectedHijriDay = null;
      _selectedHijriMonth = null;
      _selectedHijriYear = null;
    });
  }

  void _navigateToToday() {
    setState(() {
      _today = HijriDate.fromGregorian(DateTime.now());
      _calendar = HijriCalendar(_today.getYear(), _today.getMonth());
      // Clear selection when navigating to today
      _selectedHijriDay = null;
      _selectedHijriMonth = null;
      _selectedHijriYear = null;
    });
  }

  void _selectDay(HijriDate? hijriDate) {
    setState(() {
      if (hijriDate != null) {
        _selectedHijriDay = hijriDate.getDate();
        _selectedHijriMonth = hijriDate.getMonth();
        _selectedHijriYear = hijriDate.getYear();
      } else {
        _selectedHijriDay = null;
        _selectedHijriMonth = null;
        _selectedHijriYear = null;
      }
    });
    
    // Load prayer times for the selected date
    if (hijriDate != null) {
      _loadPrayerTimesForSelectedDate(hijriDate.getDate());
    } else {
      // Load today's prayer times if no day is selected
      _loadPrayerTimes();
    }
  }

  /// Load prayer times for a specific Hijri date
  Future<void> _loadPrayerTimesForSelectedDate(int hijriDay) async {
    setState(() {
      _isLoadingPrayerTimes = true;
    });

    try {
      // Get prayer times for the selected Hijri date
      final prayerTimes = await PrayerTimesService.getPrayerTimesForHijriDate(
        hijriDay,
        _calendar.getMonth(),
        _calendar.getYear(),
      );
      
      setState(() {
        _prayerTimes = prayerTimes;
        _isLoadingPrayerTimes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPrayerTimes = false;
      });
      print('Error loading prayer times for selected date: $e');
    }
  }

  /// Open settings screen
  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  /// Request location permission and update prayer times
  Future<void> _requestLocationAndUpdatePrayerTimes() async {
    setState(() {
      _isLoadingPrayerTimes = true;
    });

    try {
      // Request user location
      final userLocation = await PrayerTimesService.requestUserLocation();
      
      if (userLocation != null) {
        // Update location display
        setState(() {
          _currentLocation = userLocation['city'] ?? 'GPS Location';
        });
        
        // Reload prayer times with new location
        await _loadPrayerTimes();
      } else {
        // Location permission denied, continue with fallback
        setState(() {
          _currentLocation = 'Colombo (Fallback)';
        });
        await _loadPrayerTimes();
      }
    } catch (e) {
      setState(() {
        _isLoadingPrayerTimes = false;
        _currentLocation = 'Colombo (Fallback)';
      });
      print('Error requesting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: IslamicColors.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Islamic pattern + settings (no month/year subtitle)
              IslamicPatternHeader(
                title: 'Hijri Calendar',
                height: 60,
                onSettingsPressed: _openSettings,
              ),
              
              const SizedBox(height: 8),
              
              // Month controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MonthControls(
                  month: _calendar.getMonth(),
                  year: _calendar.getYear(),
                  onMonthChange: _changeMonth,
                  onToday: null,
                  onSelectMonthYear: (yr, mo) {
                    setState(() {
                      _calendar = HijriCalendar(yr, mo);
                      _selectedHijriDay = null;
                      _selectedHijriMonth = null;
                      _selectedHijriYear = null;
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Calendar grid and content in a scrollable area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Calendar grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CalendarGrid(
                          calendar: _calendar,
                          today: _today,
                          onDaySelected: _selectDay,
                          selectedHijriDay: _selectedHijriDay,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Compact details panel (includes prayer row + events)
                      EventsDetailsPanel(
                        selectedHijriDay: _selectedHijriDay,
                        selectedHijriMonth: (_selectedHijriMonth ?? _calendar.getMonth()),
                        selectedHijriYear: _selectedHijriYear ?? _calendar.getYear(),
                        prayerTimes: _prayerTimes,
                        isLoading: _isLoadingPrayerTimes,
                      ),
                      
                      const SizedBox(height: 16),
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
}
