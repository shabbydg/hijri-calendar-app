import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/hijri_date.dart';

class MonthControls extends StatelessWidget {
  final int month;
  final int year;
  final Function(int) onMonthChange;
  final VoidCallback? onToday;
  final void Function(int year, int month)? onSelectMonthYear;

  const MonthControls({
    super.key,
    required this.month,
    required this.year,
    required this.onMonthChange,
    this.onToday,
    this.onSelectMonthYear,
  });

  @override
  Widget build(BuildContext context) {
    final title = '${HijriDate.getMonthName(month)} $year';
    return Row(
      children: [
        _todayButton(context),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _showMonthYearPicker(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: IslamicColors.primaryGreen,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'KanzAlMarjaan',
                        fontSize: 14,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _navButton(context, Icons.chevron_left, () => onMonthChange(-1)),
        _navButton(context, Icons.chevron_right, () => onMonthChange(1)),
      ],
    );
  }

  Widget _todayButton(BuildContext context) {
    return TextButton.icon(
      onPressed: onToday,
      style: TextButton.styleFrom(
        foregroundColor: IslamicColors.primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.black.withOpacity(0.06)),
        ),
      ),
      icon: const Icon(Icons.today, size: 16),
      label: const Text(
        'Today',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _navButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.black.withOpacity(0.06)),
        ),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Icon(icon, size: 20, color: IslamicColors.primaryGreen),
        ),
      ),
    );
  }

  void _showMonthYearPicker(BuildContext context) async {
    final years = List<String>.generate(60, (i) => (1400 + i).toString());
    final months = List<String>.generate(12, (i) => HijriDate.getMonthName(i));
    final monthInitial = month.clamp(0, months.length - 1) as int;
    final yearInitial = (year - 1400).clamp(0, years.length - 1) as int;

    final selected = await showModalBottomSheet<Map<String, int>>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        int tempMonth = month;
        int tempYear = year;
        return Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Icon(Icons.date_range, color: IslamicColors.primaryGreen, size: 18),
                    SizedBox(width: 8),
                    Text('Select Month & Year',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 180,
                  child: Row(
                    children: [
                      Expanded(
                        child: _PickerColumn(
                          items: months,
                          initialIndex: monthInitial,
                          onSelectedItemChanged: (i) => tempMonth = i,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PickerColumn(
                          items: years,
                          initialIndex: yearInitial,
                          onSelectedItemChanged: (i) => tempYear = 1400 + i,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: IslamicColors.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context, {'year': tempYear, 'month': tempMonth}),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && onSelectMonthYear != null) {
      onSelectMonthYear!(selected['year']!, selected['month']!);
    }
  }
}

class _PickerColumn extends StatefulWidget {
  final List<String> items;
  final int initialIndex;
  final ValueChanged<int> onSelectedItemChanged;
  const _PickerColumn({
    required this.items,
    required this.initialIndex,
    required this.onSelectedItemChanged,
  });
  
  @override
  State<_PickerColumn> createState() => _PickerColumnState();
}

class _PickerColumnState extends State<_PickerColumn> {
  late int _selectedIndex;
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _controller = FixedExtentScrollController(initialItem: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Column(
        children: [
          Expanded(
            child: ListWheelScrollView.useDelegate(
              controller: _controller,
              itemExtent: 28,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                widget.onSelectedItemChanged(index);
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  if (index < 0 || index >= widget.items.length) return null;
                  final isSelected = index == _selectedIndex;
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? IslamicColors.primaryGreen.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.items[index],
                        style: TextStyle(
                          fontSize: isSelected ? 16 : 14, // Slightly larger font for selected item
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.black : IslamicColors.primaryGreen.withOpacity(0.6), // Black for focused item
                        ),
                      ),
                    ),
                  );
                },
                childCount: widget.items.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
