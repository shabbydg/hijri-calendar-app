class ArabicNumerals {
  // Arabic numerals array exactly like HTML version
  static const List<String> arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  /// Convert a number to Arabic numerals
  /// Example: 123 becomes "١٢٣"
  static String convertToArabic(int number) {
    return number.toString().split('').map((digit) {
      final digitIndex = int.parse(digit);
      return arabicNumerals[digitIndex];
    }).join('');
  }

  /// Convert a number to Arabic numerals with fallback to original number
  /// This ensures we never crash if there's an issue with conversion
  static String convertToArabicSafe(int number) {
    try {
      return convertToArabic(number);
    } catch (e) {
      // Fallback to original number if conversion fails
      return number.toString();
    }
  }
}
