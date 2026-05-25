import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/widgets/premium_card.dart';
import '../../providers/transaction_provider.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final now = DateTime.now();
    final monthKey = DateHelper.monthKey(now);
    final monthTransactions = provider.allTransactions
        .where((item) => DateHelper.monthKey(item.date) == monthKey)
        .toList();
    final income = monthTransactions
        .where((item) => item.type == 'income')
        .fold(0.0, (sum, item) => sum + item.amount);
    final expense = monthTransactions
        .where((item) => item.type == 'expense')
        .fold(0.0, (sum, item) => sum + item.amount);
    final byCategory = <String, double>{};
    final byDay = <String, double>{};
    for (final item in monthTransactions.where(
      (item) => item.type == 'expense',
    )) {
      byCategory.update(
        item.category,
        (value) => value + item.amount,
        ifAbsent: () => item.amount,
      );
      byDay.update(
        DateHelper.formatDate(item.date),
        (value) => value + item.amount,
        ifAbsent: () => item.amount,
      );
    }
    final topCategory = _topKey(byCategory);
    final topDay = _topKey(byDay);
    final report =
        '''
Báo cáo tài chính tháng ${DateHelper.formatMonth(now)}

Tổng thu: ${CurrencyHelper.format(income)}
Tổng chi: ${CurrencyHelper.format(expense)}
Số dư tháng: ${CurrencyHelper.format(income - expense)}
Danh mục chi nhiều nhất: ${topCategory ?? 'Chưa có'}
Ngày chi nhiều nhất: ${topDay ?? 'Chưa có'}

Gợi ý tiết kiệm: ${expense > income * 0.8 ? 'Chi tiêu đang cao, nên giảm các khoản không thiết yếu.' : 'Tỷ lệ chi tiêu đang ổn, hãy tiếp tục duy trì.'}
''';

    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo tài chính')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.padding),
        children: [
          Row(
            children: [
              Expanded(
                child: _ReportMetric(
                  title: 'Thu',
                  value: income,
                  color: AppColors.income,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ReportMetric(
                  title: 'Chi',
                  value: expense,
                  color: AppColors.expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PremiumCard(child: SelectableText(report)),
        ],
      ),
    );
  }

  String? _topKey(Map<String, double> data) {
    if (data.isEmpty) return null;
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }
}

class _ReportMetric extends StatelessWidget {
  const _ReportMetric({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            CurrencyHelper.format(value),
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
