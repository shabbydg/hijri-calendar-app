import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';
  static AppSettings? _cachedSettings;

  /// Get current app settings
  static Future<AppSettings> getSettings() async {
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
        _cachedSettings = AppSettings.fromJson(settingsMap);
        return _cachedSettings!;
      }
    } catch (e) {
      print('Error loading settings: $e');
    }

    // Return default settings if none found
    _cachedSettings = AppSettings.defaultSettings;
    return _cachedSettings!;
  }

  /// Save app settings
  static Future<bool> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(settings.toJson());
      final success = await prefs.setString(_settingsKey, settingsJson);
      
      if (success) {
        _cachedSettings = settings;
      }
      
      return success;
    } catch (e) {
      print('Error saving settings: $e');
      return false;
    }
  }

  /// Update specific setting
  static Future<bool> updateSetting<T>(String key, T value) async {
    try {
      final currentSettings = await getSettings();
      AppSettings newSettings;
      
      switch (key) {
        case 'enablePrayerNotifications':
          newSettings = currentSettings.copyWith(enablePrayerNotifications: value as bool);
          break;
        case 'enableAdhanSounds':
          newSettings = currentSettings.copyWith(enableAdhanSounds: value as bool);
          break;
        case 'enableLocationServices':
          newSettings = currentSettings.copyWith(enableLocationServices: value as bool);
          break;
        case 'language':
          newSettings = currentSettings.copyWith(language: value as String);
          break;
        case 'theme':
          newSettings = currentSettings.copyWith(theme: value as String);
          break;
        case 'showGregorianDates':
          newSettings = currentSettings.copyWith(showGregorianDates: value as bool);
          break;
        case 'showEventDots':
          newSettings = currentSettings.copyWith(showEventDots: value as bool);
          break;
        case 'prayerTimeFormat':
          newSettings = currentSettings.copyWith(prayerTimeFormat: value as String);
          break;
        case 'prayerNotificationAdvance':
          newSettings = currentSettings.copyWith(prayerNotificationAdvance: value as Duration);
          break;
        default:
          return false;
      }
      
      return await saveSettings(newSettings);
    } catch (e) {
      print('Error updating setting: $e');
      return false;
    }
  }

  /// Reset settings to default
  static Future<bool> resetToDefault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_settingsKey);
      
      if (success) {
        _cachedSettings = null;
      }
      
      return success;
    } catch (e) {
      print('Error resetting settings: $e');
      return false;
    }
  }

  /// Clear cached settings (useful for testing)
  static void clearCache() {
    _cachedSettings = null;
  }
}
