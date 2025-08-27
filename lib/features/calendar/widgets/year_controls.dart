import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/arabic_numerals.dart';

class YearControls extends StatelessWidget {
  final int year;
  final Function(int) onYearChange;

  const YearControls({
    super.key,
    required this.year,
    required this.onYearChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _navButton(context, Icons.chevron_left, () => onYearChange(-1)),
        const SizedBox(width: 8),
        Text(
          ArabicNumerals.convertToArabicSafe(year),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: IslamicColors.calligraphyBlack,
                fontWeight: FontWeight.w600,
                fontFamily: 'KanzAlMarjaan',
                fontSize: 16,
              ),
        ),
        const SizedBox(width: 8),
        _navButton(context, Icons.chevron_right, () => onYearChange(1)),
      ],
    );
  }

  Widget _navButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.black.withOpacity(0.06)),
        ),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Icon(icon, size: 18, color: IslamicColors.primaryGreen),
        ),
      ),
    );
  }
}
