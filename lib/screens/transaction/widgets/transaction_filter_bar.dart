import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/date_helper.dart';
import '../../../core/widgets/month_year_picker.dart';

class TransactionFilterBar extends StatelessWidget {
  const TransactionFilterBar({
    super.key,
    required this.searchController,
    required this.type,
    required this.month,
    required this.onSearchChanged,
    required this.onTypeChanged,
    required this.onMonthChanged,
  });

  final TextEditingController searchController;
  final String type;
  final DateTime? month;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<DateTime?> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            labelText: 'Tìm kiếm theo tiêu đề, ghi chú, danh mục',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('Tất cả')),
                  ButtonSegment(value: 'income', label: Text('Thu')),
                  ButtonSegment(value: 'expense', label: Text('Chi')),
                ],
                selected: {type},
                onSelectionChanged: (values) => onTypeChanged(values.first),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showMonthYearPickerDialog(
                    context: context,
                    initialMonth: month,
                  );
                  if (picked != null) {
                    onMonthChanged(picked);
                  }
                },
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  month == null
                      ? 'Lọc theo tháng'
                      : 'Tháng ${DateHelper.formatMonth(month!)}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (month != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => onMonthChanged(null),
                icon: const Icon(Icons.close),
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
