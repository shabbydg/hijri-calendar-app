import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/prayer_times.dart';

class PrayerTimesCard extends StatelessWidget {
  final PrayerTimes? prayerTimes;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final String? location; // Add location parameter

  const PrayerTimesCard({
    super.key,
    this.prayerTimes,
    this.isLoading = false,
    this.onRefresh,
    this.location, // Make location optional
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (isLoading) _buildLoadingState(),
          if (!isLoading && prayerTimes == null) _buildNoDataState(),
          if (!isLoading && prayerTimes != null) _buildPrayerTimes(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: IslamicColors.primaryGradient,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.mosque,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prayer Times',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'KanzAlMarjaan',
                  ),
                ),
                if (location != null)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location!,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                if (prayerTimes != null && location == null)
                  Text(
                    prayerTimes!.getCurrentPrayerPeriod(),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          if (onRefresh != null)
            IconButton(
              onPressed: onRefresh,
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(IslamicColors.primaryGreen),
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.location_off,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Location required for prayer times',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enable location services to see prayer times',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimes() {
    if (prayerTimes == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildPrayerTimeRow('Fajr', prayerTimes!.fajr, Icons.wb_sunny_outlined),
          const SizedBox(height: 16),
          _buildPrayerTimeRow('Sunrise', prayerTimes!.sunrise, Icons.wb_sunny),
          const SizedBox(height: 16),
          _buildPrayerTimeRow('Dhuhr', prayerTimes!.dhuhr, Icons.wb_sunny_outlined),
          const SizedBox(height: 16),
          _buildPrayerTimeRow('Asr', prayerTimes!.asr, Icons.wb_sunny_outlined),
          const SizedBox(height: 16),
          _buildPrayerTimeRow('Maghrib', prayerTimes!.maghrib, Icons.nightlight_round),
          const SizedBox(height: 16),
          _buildPrayerTimeRow('Isha', prayerTimes!.isha, Icons.nightlight_round),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: IslamicColors.warmBeige.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: IslamicColors.primaryGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: IslamicColors.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    prayerTimes!.getTimeUntilNextPrayer(),
                    style: TextStyle(
                      color: IslamicColors.primaryGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'KanzAlMarjaan',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeRow(String name, String time, IconData icon) {
    final isNextPrayer = prayerTimes!.getNextPrayer() == name;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isNextPrayer 
            ? IslamicColors.primaryGreen.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isNextPrayer
            ? Border.all(
                color: IslamicColors.primaryGreen.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isNextPrayer 
                ? IslamicColors.primaryGreen
                : IslamicColors.deepBlue,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isNextPrayer 
                    ? IslamicColors.primaryGreen
                    : IslamicColors.calligraphyBlack,
                fontFamily: 'KanzAlMarjaan',
              ),
            ),
          ),
          Text(
            prayerTimes!.formatTime(time),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isNextPrayer 
                  ? IslamicColors.primaryGreen
                  : IslamicColors.deepBlue,
              fontFamily: 'KanzAlMarjaan',
            ),
          ),
        ],
      ),
    );
  }
}
