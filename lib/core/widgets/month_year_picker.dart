import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

Future<DateTime?> showMonthYearPickerDialog({
  required BuildContext context,
  DateTime? initialMonth,
  int yearRange = 5,
}) {
  final now = DateTime.now();
  var selectedMonth = initialMonth?.month ?? now.month;
  var selectedYear = initialMonth?.year ?? now.year;
  final years = List.generate(
    yearRange * 2 + 1,
    (index) => now.year - yearRange + index,
  );

  return showDialog<DateTime>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Chọn tháng'),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Năm',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    items: years
                        .map(
                          (year) => DropdownMenuItem(
                            value: year,
                            child: Text('$year'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedYear = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 12,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 3.2,
                        ),
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      final isSelected = selectedMonth == month;
                      return _PickerOption(
                        label: 'Tháng $month',
                        isSelected: isSelected,
                        onTap: () => setState(() => selectedMonth = month),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    DateTime(selectedYear, selectedMonth),
                  );
                },
                child: const Text('Áp dụng'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<int?> showYearPickerDialog({
  required BuildContext context,
  int? initialYear,
  int yearRange = 5,
}) {
  final now = DateTime.now();
  var selectedYear = initialYear ?? now.year;
  final years = List.generate(
    yearRange * 2 + 1,
    (index) => now.year - yearRange + index,
  );

  return showDialog<int>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Chọn năm'),
            content: SizedBox(
              width: 320,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: years.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.4,
                ),
                itemBuilder: (context, index) {
                  final year = years[index];
                  return _PickerOption(
                    label: '$year',
                    isSelected: selectedYear == year,
                    onTap: () => setState(() => selectedYear = year),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, selectedYear),
                child: const Text('Áp dụng'),
              ),
            ],
          );
        },
      );
    },
  );
}

class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
