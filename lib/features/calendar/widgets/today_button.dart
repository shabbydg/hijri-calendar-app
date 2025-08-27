import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class TodayButton extends StatelessWidget {
  final VoidCallback onClick;

  const TodayButton({
    super.key,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: IslamicColors.accentGradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: IslamicColors.goldAccent.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onClick,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.today,
                  color: IslamicColors.calligraphyBlack,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Today',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: IslamicColors.calligraphyBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
