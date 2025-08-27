import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/themes.dart';
import 'app/app.dart';

void main() {
  runApp(const HijriCalendarApp());
}

class HijriCalendarApp extends StatelessWidget {
  const HijriCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Hijri Calendar',
        theme: IslamicThemes.lightTheme,
        darkTheme: IslamicThemes.darkTheme,
        themeMode: ThemeMode.system,
        home: const CalendarScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
