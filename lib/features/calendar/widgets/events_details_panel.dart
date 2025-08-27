import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/islamic_event.dart';
import '../../../core/services/events_service.dart';
import '../../../core/models/prayer_times.dart';
import '../../../core/models/hijri_date.dart';

class EventsDetailsPanel extends StatelessWidget {
  final int? selectedHijriDay;
  final int selectedHijriMonth; // 0-based, mirrors HijriDate
  final int selectedHijriYear;
  final PrayerTimes? prayerTimes;
  final bool isLoading;

  const EventsDetailsPanel({
    super.key,
    this.selectedHijriDay,
    required this.selectedHijriMonth,
    required this.selectedHijriYear,
    this.prayerTimes,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final events = selectedHijriDay != null
        ? EventsService.getEventsForDate(selectedHijriDay!, selectedHijriMonth)
        : EventsService.getEventsForMonth(selectedHijriMonth);

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // // Header (compact)
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          //   child: Row(
          //     children: [
          //       Icon(
          //         Icons.event_note,
          //         color: IslamicColors.primaryGreen,
          //         size: 18,
          //       ),
          //       const SizedBox(width: 8),
          //       Expanded(
          //         child: Text(
          //           selectedHijriDay != null
          //               ? '${HijriDate.getMonthName(selectedHijriMonth)} ${selectedHijriDay}, ${selectedHijriYear}'
          //               : HijriDate.getMonthName(selectedHijriMonth),
          //           style: const TextStyle(
          //             color: IslamicColors.calligraphyBlack,
          //             fontSize: 14,
          //             fontWeight: FontWeight.w700,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // Prayer times row placeholder (Sunrise • Zawal • Maghrib)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: IslamicColors.goldAccent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  _PrayerCol(label: 'Sunrise', value: _format(prayerTimes?.sunrise, isLoading)),
                  const _Divider(),
                  _PrayerCol(label: 'Zawal', value: _format(prayerTimes?.zawaal, isLoading)),
                  const _Divider(),
                  _PrayerCol(label: 'Maghrib', value: _format(prayerTimes?.maghrib, isLoading)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Events list
          if (events.isEmpty)
            _buildNoEventsState()
          else
            _buildEventsList(events),
        ],
      ),
    );
  }

  Widget _buildNoEventsState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: 36,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No events for this ${selectedHijriDay != null ? 'day' : 'month'}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(List<IslamicEvent> events) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventItem(event);
      },
    );
  }

  Widget _buildEventItem(IslamicEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: event.isImportant 
            ? IslamicColors.goldAccent.withOpacity(0.08)
            : IslamicColors.warmBeige.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: event.isImportant 
              ? IslamicColors.goldAccent.withOpacity(0.25)
              : IslamicColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (event.isImportant)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: IslamicColors.goldAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Important',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                event.category,
                style: TextStyle(
                  color: IslamicColors.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            event.title,
            style: TextStyle(
              color: IslamicColors.calligraphyBlack,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'KanzAlMarjaan',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            event.description,
            style: TextStyle(
              color: IslamicColors.calligraphyBlack.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: IslamicColors.primaryGreen,
              ),
              const SizedBox(width: 4),
              Text(
                event.location,
                style: TextStyle(
                  color: IslamicColors.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // no local month map; we rely on HijriDate.getMonthName for consistency

  static String _format(String? time, bool isLoading) {
    if (isLoading) return '…';
    if (time == null || time.isEmpty) return '—:—';
    
    // Handle API response format: "2025-08-23 06:03:00" -> "06:03"
    if (time.contains(' ')) {
      final parts = time.split(' ');
      if (parts.length >= 2) {
        final timePart = parts[1];
        if (timePart.contains(':')) {
          return timePart.substring(0, 5); // Extract HH:mm
        }
      }
    }
    
    // Handle direct time format: "06:03" -> "06:03"
    if (time.contains(':')) {
      return time.substring(0, 5);
    }
    
    return time;
  }
}

class _PrayerCol extends StatelessWidget {
  final String label;
  final String value;
  const _PrayerCol({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: IslamicColors.calligraphyBlack.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: IslamicColors.calligraphyBlack,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.black.withOpacity(0.08),
    );
  }
}
