import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_times.dart';
import 'location_service.dart';
import '../models/hijri_date.dart';

class PrayerTimesService {
  // API Configuration exactly like HTML version
  static const String _baseUrl = 'https://mumineen.org/api/v1';
  
  // Fallback coordinates (Colombo, Sri Lanka) exactly like HTML version
  static const Map<String, dynamic> FALLBACK_COORDS = {
    'latitude': 6.56,
    'longitude': 79.51,
    'city': 'Colombo',
    'timezone': 'Asia/Kolkata'
  };
  
  // Cache configuration like HTML version
  static const int CACHE_DURATION = 30 * 24 * 60 * 60 * 1000; // 30 days in milliseconds
  static const int LOCATION_CACHE_DURATION = 7 * 24 * 60 * 60 * 1000; // 7 days for location cache
  
  // Current user location (will be updated when permissions are granted)
  static Map<String, dynamic>? _currentUserLocation;
  
  // Mock prayer times for development/testing (fallback)
  static PrayerTimes getMockPrayerTimes() {
    return PrayerTimes(
      sihori: '04:49',
      fajr: '05:33',
      sunrise: '07:15',
      zawaal: '12:15',
      zohrEnd: '14:16',
      asrEnd: '16:19',
      maghrib: '18:20',
      maghribEnd: '18:33',
      nisfulLayl: '19:45',
      nisfulLaylEnd: '20:15',
      date: DateTime.now(),
    );
  }

  /// Request location permission and get user's current location
  static Future<Map<String, dynamic>?> requestUserLocation() async {
    try {
      // Request location permission
      final hasPermission = await LocationService.requestLocationPermissionWithDialog();
      
      if (!hasPermission) {
        print('Location permission denied');
        return null;
      }
      
      // Get current location
      final position = await LocationService.getCurrentLocation();
      
      if (position != null) {
        // Get location data from API
        final locationData = await getLocationData(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        
        if (locationData != null) {
          _currentUserLocation = locationData;
          return locationData;
        } else {
          // Use coordinates directly if API fails
          _currentUserLocation = {
            'latitude': position.latitude,
            'longitude': position.longitude,
            'city': LocationService.getLocationName(position.latitude, position.longitude),
            'timezone': 'UTC', // Default timezone
          };
          return _currentUserLocation;
        }
      }
      
      return null;
    } catch (e) {
      print('Error requesting user location: $e');
      return null;
    }
  }

  /// Get the best available location (user location or fallback)
  static Future<Map<String, dynamic>> getBestAvailableLocation() async {
    // If we already have user location, use it
    if (_currentUserLocation != null) {
      return _currentUserLocation!;
    }
    
    // Try to get user location
    final userLocation = await requestUserLocation();
    if (userLocation != null) {
      return userLocation;
    }
    
    // Fallback to Colombo
    return FALLBACK_COORDS;
  }

  /// Get location data from mumineen.org API (exactly like HTML version)
  static Future<Map<String, dynamic>?> getLocationData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/location/nearest?latitude=$latitude&longitude=$longitude');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']; // Extract data field like HTML version
      } else {
        print('Location API failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching location data: $e');
      return null;
    }
  }

  /// Get prayer times from mumineen.org API (exactly like HTML version)
  static Future<PrayerTimes?> getPrayerTimes({
    required double latitude,
    required double longitude,
    required String timezone,
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateString = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
      
      final url = Uri.parse('$_baseUrl/salaat?start=$dateString&latitude=$latitude&longitude=$longitude&timezone=${Uri.encodeComponent(timezone)}');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prayerData = data['data'][dateString]; // Extract data like HTML version
        
        if (prayerData != null) {
          return PrayerTimes.fromApiResponse(prayerData, dateString);
        }
      } else {
        print('Prayer times API failed with status: ${response.statusCode}');
      }
      
      // Fallback to mock data if API fails
      return getMockPrayerTimes();
    } catch (e) {
      print('Error fetching prayer times: $e');
      // Fallback to mock data on error
      return getMockPrayerTimes();
    }
  }

  /// Get today's prayer times with location detection
  static Future<PrayerTimes?> getTodayPrayerTimes({
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Get the best available location
      final location = await getBestAvailableLocation();
      
      return await getPrayerTimes(
        latitude: location['latitude'],
        longitude: location['longitude'],
        timezone: location['timezone'],
        date: DateTime.now(),
      );
    } catch (e) {
      print('Error getting today prayer times: $e');
      return getMockPrayerTimes();
    }
  }

  /// Get prayer times for a specific date
  static Future<PrayerTimes?> getPrayerTimesForDate(DateTime date) async {
    try {
      // Get the best available location
      final location = await getBestAvailableLocation();
      
      return await getPrayerTimes(
        latitude: location['latitude'],
        longitude: location['longitude'],
        timezone: location['timezone'],
        date: date,
      );
    } catch (e) {
      print('Error getting prayer times for date: $e');
      return getMockPrayerTimes();
    }
  }

  /// Get prayer times for a specific Hijri date
  static Future<PrayerTimes?> getPrayerTimesForHijriDate(int hijriDay, int hijriMonth, int hijriYear) async {
    try {
      // Convert Hijri date to Gregorian date
      final hijri = HijriDate(hijriYear, hijriMonth, hijriDay);
      final gregorianDate = hijri.toGregorian();
      return await getPrayerTimesForDate(gregorianDate);
    } catch (e) {
      print('Error getting prayer times for Hijri date: $e');
      return getMockPrayerTimes();
    }
  }

  /// Get prayer times for a specific date range
  static Future<List<PrayerTimes>> getPrayerTimesForRange({
    required double latitude,
    required double longitude,
    required String timezone,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startString = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endString = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      
      final url = Uri.parse('$_baseUrl/salaat?start=$startString&end=$endString&latitude=$latitude&longitude=$longitude&timezone=${Uri.encodeComponent(timezone)}');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prayerData = data['data'];
        
        final prayerTimes = <PrayerTimes>[];
        
        // Convert each day's data to PrayerTimes objects
        prayerData.forEach((dateString, dayData) {
          if (dayData != null) {
            final prayerTime = PrayerTimes.fromJson(dayData);
            prayerTimes.add(prayerTime);
          }
        });
        
        return prayerTimes;
      }
      
      // Fallback to mock data
      return [getMockPrayerTimes()];
    } catch (e) {
      print('Error fetching prayer times range: $e');
      return [getMockPrayerTimes()];
    }
  }

  /// Get current week prayer times
  static Future<List<PrayerTimes>> getCurrentWeekPrayerTimes({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      
      final coords = {
        'latitude': latitude ?? FALLBACK_COORDS['latitude'],
        'longitude': longitude ?? FALLBACK_COORDS['longitude'],
        'timezone': FALLBACK_COORDS['timezone'],
      };
      
      return await getPrayerTimesForRange(
        latitude: coords['latitude'],
        longitude: coords['longitude'],
        timezone: coords['timezone'],
        startDate: startOfWeek,
        endDate: endOfWeek,
      );
    } catch (e) {
      print('Error getting current week prayer times: $e');
      return [getMockPrayerTimes()];
    }
  }

  /// Get current month prayer times
  static Future<List<PrayerTimes>> getCurrentMonthPrayerTimes({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      
      final coords = {
        'latitude': latitude ?? FALLBACK_COORDS['latitude'],
        'longitude': longitude ?? FALLBACK_COORDS['longitude'],
        'timezone': FALLBACK_COORDS['timezone'],
      };
      
      return await getPrayerTimesForRange(
        latitude: coords['latitude'],
        longitude: coords['longitude'],
        timezone: coords['timezone'],
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
    } catch (e) {
      print('Error getting current month prayer times: $e');
      return [getMockPrayerTimes()];
    }
  }
}
