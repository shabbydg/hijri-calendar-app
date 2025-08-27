import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/services/settings_service.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppSettings? _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.getSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _updateSetting<T>(String key, T value) async {
    final success = await SettingsService.updateSetting(key, value);
    if (success) {
      await _loadSettings();
    }
  }

  Future<void> _resetToDefault() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await SettingsService.resetToDefault();
      if (success) {
        await _loadSettings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings reset to default')),
          );
        }
      }
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
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'KanzAlMarjaan',
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _resetToDefault,
                      icon: const Icon(
                        Icons.restore,
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'Reset to Default',
                    ),
                  ],
                ),
              ),
              
              // Settings Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _buildSettingsContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent() {
    if (_settings == null) return const SizedBox.shrink();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Prayer Times Section
            SettingsSection(
              title: 'Prayer Times',
              icon: Icons.mosque,
              children: [
                SettingsTile(
                  title: 'Enable Notifications',
                  subtitle: 'Get notified before prayer times',
                  trailing: Switch(
                    value: _settings!.enablePrayerNotifications,
                    onChanged: (value) => _updateSetting('enablePrayerNotifications', value),
                    activeColor: IslamicColors.primaryGreen,
                  ),
                ),
                SettingsTile(
                  title: 'Adhan Sounds',
                  subtitle: 'Play adhan when notifications appear',
                  trailing: Switch(
                    value: _settings!.enableAdhanSounds,
                    onChanged: (value) => _updateSetting('enableAdhanSounds', value),
                    activeColor: IslamicColors.primaryGreen,
                  ),
                ),
                SettingsTile(
                  title: 'Notification Advance',
                  subtitle: '${_settings!.prayerNotificationAdvance.inMinutes} minutes before',
                  trailing: IconButton(
                    onPressed: () => _showNotificationAdvanceDialog(),
                    icon: const Icon(Icons.edit),
                    color: IslamicColors.primaryGreen,
                  ),
                ),
                SettingsTile(
                  title: 'Time Format',
                  subtitle: _settings!.prayerTimeFormat == '12h' ? '12-hour (6:30 PM)' : '24-hour (18:30)',
                  trailing: IconButton(
                    onPressed: () => _showTimeFormatDialog(),
                    icon: const Icon(Icons.edit),
                    color: IslamicColors.primaryGreen,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Calendar Section
            SettingsSection(
              title: 'Calendar',
              icon: Icons.calendar_today,
              children: [
                SettingsTile(
                  title: 'Show Gregorian Dates',
                  subtitle: 'Display both Hijri and Gregorian dates',
                  trailing: Switch(
                    value: _settings!.showGregorianDates,
                    onChanged: (value) => _updateSetting('showGregorianDates', value),
                    activeColor: IslamicColors.primaryGreen,
                  ),
                ),
                SettingsTile(
                  title: 'Show Event Dots',
                  subtitle: 'Display event indicators on calendar days',
                  trailing: Switch(
                    value: _settings!.showEventDots,
                    onChanged: (value) => _updateSetting('showEventDots', value),
                    activeColor: IslamicColors.primaryGreen,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Location Section
            SettingsSection(
              title: 'Location',
              icon: Icons.location_on,
              children: [
                SettingsTile(
                  title: 'Location Services',
                  subtitle: 'Use GPS for accurate prayer times',
                  trailing: Switch(
                    value: _settings!.enableLocationServices,
                    onChanged: (value) => _updateSetting('enableLocationServices', value),
                    activeColor: IslamicColors.primaryGreen,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Appearance Section
            SettingsSection(
              title: 'Appearance',
              icon: Icons.palette,
              children: [
                SettingsTile(
                  title: 'Theme',
                  subtitle: _settings!.theme == 'light' ? 'Light Theme' : 'Dark Theme',
                  trailing: IconButton(
                    onPressed: () => _showThemeDialog(),
                    icon: const Icon(Icons.edit),
                    color: IslamicColors.primaryGreen,
                  ),
                ),
                SettingsTile(
                  title: 'Language',
                  subtitle: _getLanguageName(_settings!.language),
                  trailing: IconButton(
                    onPressed: () => _showLanguageDialog(),
                    icon: const Icon(Icons.edit),
                    color: IslamicColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationAdvanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Advance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How many minutes before prayer time should you be notified?'),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: _settings!.prayerNotificationAdvance.inMinutes,
              decoration: const InputDecoration(
                labelText: 'Minutes',
                border: OutlineInputBorder(),
              ),
              items: [5, 10, 15, 20, 30].map((minutes) {
                return DropdownMenuItem(
                  value: minutes,
                  child: Text('$minutes minutes'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _updateSetting('prayerNotificationAdvance', Duration(minutes: value));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showTimeFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Time Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('12-hour (6:30 PM)'),
              subtitle: const Text('Traditional format'),
              value: '12h',
              groupValue: _settings!.prayerTimeFormat,
              onChanged: (value) {
                if (value != null) {
                  _updateSetting('prayerTimeFormat', value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('24-hour (18:30)'),
              subtitle: const Text('Military format'),
              value: '24h',
              groupValue: _settings!.prayerTimeFormat,
              onChanged: (value) {
                if (value != null) {
                  _updateSetting('prayerTimeFormat', value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Light Theme'),
              subtitle: const Text('Default Islamic theme'),
              value: 'light',
              groupValue: _settings!.theme,
              onChanged: (value) {
                if (value != null) {
                  _updateSetting('theme', value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Dark Theme'),
              subtitle: const Text('Dark mode with gold accents'),
              value: 'dark',
              groupValue: _settings!.theme,
              onChanged: (value) {
                if (value != null) {
                  _updateSetting('theme', value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              subtitle: const Text('Default language'),
              value: 'en',
              groupValue: _settings!.language,
              onChanged: (value) {
                if (value != null) {
                  _updateSetting('language', value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('العربية'),
              subtitle: const Text('Arabic language'),
              value: 'ar',
              groupValue: _settings!.language,
              onChanged: (value) {
                if (value != null) {
                  _updateSetting('language', value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('اردو'),
              subtitle: const Text('Urdu language'),
              value: 'ur',
              groupValue: _settings!.language,
              onChanged: (value) {
                if (value != null) {
                  _updateSetting('language', value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'ur':
        return 'اردو';
      default:
        return 'English';
    }
  }
}
