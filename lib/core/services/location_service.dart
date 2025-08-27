import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check current location permission status
  static Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  static Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  // Request location permission with dialog
  static Future<bool> requestLocationPermissionWithDialog() async {
    // First check if location services are enabled
    if (!await isLocationServiceEnabled()) {
      return false;
    }

    // Check current permission status
    LocationPermission permission = await checkLocationPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await requestLocationPermission();
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permission denied forever, user needs to enable in settings
      return false;
    }
    
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  // Get current location with permission check
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if we have permission
      if (!await hasValidLocationPermissions()) {
        return null;
      }
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // Get last known location
  static Future<Position?> getLastKnownLocation() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('Error getting last known location: $e');
      return null;
    }
  }

  // Check if we have valid location permissions
  static Future<bool> hasValidLocationPermissions() async {
    LocationPermission permission = await checkLocationPermission();
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  // Calculate distance between two points
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Get location name from coordinates (simplified)
  static String getLocationName(double latitude, double longitude) {
    // For now, return coordinates as location name
    // In production, you could integrate with a reverse geocoding service
    return '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
  }
}
