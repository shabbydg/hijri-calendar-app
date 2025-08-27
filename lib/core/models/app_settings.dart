class AppSettings {
  final bool enablePrayerNotifications;
  final bool enableAdhanSounds;
  final bool enableLocationServices;
  final String language;
  final String theme;
  final bool showGregorianDates;
  final bool showEventDots;
  final String prayerTimeFormat;
  final Duration prayerNotificationAdvance;

  const AppSettings({
    this.enablePrayerNotifications = true,
    this.enableAdhanSounds = true,
    this.enableLocationServices = true,
    this.language = 'en',
    this.theme = 'light',
    this.showGregorianDates = true,
    this.showEventDots = true,
    this.prayerTimeFormat = '12h',
    this.prayerNotificationAdvance = const Duration(minutes: 15),
  });

  AppSettings copyWith({
    bool? enablePrayerNotifications,
    bool? enableAdhanSounds,
    bool? enableLocationServices,
    String? language,
    String? theme,
    bool? showGregorianDates,
    bool? showEventDots,
    String? prayerTimeFormat,
    Duration? prayerNotificationAdvance,
  }) {
    return AppSettings(
      enablePrayerNotifications: enablePrayerNotifications ?? this.enablePrayerNotifications,
      enableAdhanSounds: enableAdhanSounds ?? this.enableAdhanSounds,
      enableLocationServices: enableLocationServices ?? this.enableLocationServices,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      showGregorianDates: showGregorianDates ?? this.showGregorianDates,
      showEventDots: showEventDots ?? this.showEventDots,
      prayerTimeFormat: prayerTimeFormat ?? this.prayerTimeFormat,
      prayerNotificationAdvance: prayerNotificationAdvance ?? this.prayerNotificationAdvance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enablePrayerNotifications': enablePrayerNotifications,
      'enableAdhanSounds': enableAdhanSounds,
      'enableLocationServices': enableLocationServices,
      'language': language,
      'theme': theme,
      'showGregorianDates': showGregorianDates,
      'showEventDots': showEventDots,
      'prayerTimeFormat': prayerTimeFormat,
      'prayerNotificationAdvance': prayerNotificationAdvance.inMinutes,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      enablePrayerNotifications: json['enablePrayerNotifications'] ?? true,
      enableAdhanSounds: json['enableAdhanSounds'] ?? true,
      enableLocationServices: json['enableLocationServices'] ?? true,
      language: json['language'] ?? 'en',
      theme: json['theme'] ?? 'light',
      showGregorianDates: json['showGregorianDates'] ?? true,
      showEventDots: json['showEventDots'] ?? true,
      prayerTimeFormat: json['prayerTimeFormat'] ?? '12h',
      prayerNotificationAdvance: Duration(minutes: json['prayerNotificationAdvance'] ?? 15),
    );
  }

  static const AppSettings defaultSettings = AppSettings();
}
