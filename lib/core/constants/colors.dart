import 'package:flutter/material.dart';

class IslamicColors {
  // Primary Islamic green
  static const Color primaryGreen = Color(0xFF2E7D32);

  // Transparent color
  static const Color transparent = Color(0x00000000);
  
  // Gold accent for highlights
  static const Color goldAccent = Color(0xFFFFD700);
  
  // Deep blue for secondary elements
  static const Color deepBlue = Color(0xFF1565C0);
  
  // Warm beige for backgrounds
  static const Color warmBeige = Color(0xFFF5E6D3);
  
  // Calligraphy black for text
  static const Color calligraphyBlack = Color(0xFF212121);
  
  // Additional Islamic-inspired colors
  static const Color crescentSilver = Color(0xFFC0C0C0);
  static const Color prayerBlue = Color(0xFF1E3A8A);
  static const Color sunsetOrange = Color(0xFFFF6B35);
  static const Color desertSand = Color(0xFFE6D5AC);
  static const Color oliveGreen = Color(0xFF6B8E23);

  // Background Colours for Event Types
  // Birthdays - Baby Blue
  static const Color birthdayBackground = Color(0xFFADD8E6);
  // Wedding Anniversaries - Gold
  static const Color weddingAnniversaryBackground = Color(0xFFFFD700);
  // Other Events - Purple
  static const Color otherEventBackground = Color(0xFF800080);
  // Death Anniversary - Grey
  static const Color deathAnniversaryBackground = Color(0xFFC0C0C0);

  
  // Gradient colors
  static const List<Color> primaryGradient = [
    primaryGreen,
    deepBlue,
  ];
  
  static const List<Color> accentGradient = [
    goldAccent,
    sunsetOrange,
  ];
  
  static const List<Color> backgroundGradient = [
    Colors.white,
    warmBeige,
  ];
}
