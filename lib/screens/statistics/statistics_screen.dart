import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/month_year_picker.dart';
import '../../core/widgets/premium_card.dart';
import '../../providers/transaction_provider.dart';
import '../home/widgets/summary_card.dart';
import 'widgets/balance_line_chart.dart';
import 'widgets/expense_pie_chart.dart';
import 'widgets/monthly_bar_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _selectedMonth = DateTime.now();
  int _selectedYear = DateTime.now().year;
  String _viewMode = 'month';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final periodTransactions = provider.allTransactions.where((transaction) {
      if (_viewMode == 'year') {
        return transaction.date.year == _selectedYear;
      }
      return transaction.date.year == _selectedMonth.year &&
          transaction.date.month == _selectedMonth.month;
    }).toList();

    final periodIncome = periodTransactions
        .where((item) => item.type == 'income')
        .fold(0.0, (sum, item) => sum + item.amount);
    final periodExpense = periodTransactions
        .where((item) => item.type == 'expense')
        .fold(0.0, (sum, item) => sum + item.amount);

    final expenseByCategory = <String, double>{};
    for (final transaction in periodTransactions.where(
      (item) => item.type == 'expense',
    )) {
      expenseByCategory.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    final topCategories = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final periodLabel = _viewMode == 'year'
        ? 'Năm $_selectedYear'
        : 'Tháng ${DateHelper.formatMonth(_selectedMonth)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê')),
      body: RefreshIndicator(
        onRefresh: provider.loadTransactions,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.padding),
          children: [
            PremiumCard(
              gradient: AppColors.gradient,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng quan $periodLabel',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyHelper.format(periodIncome - periodExpense),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thu ${CurrencyHelper.compact(periodIncome)} • Chi ${CurrencyHelper.compact(periodExpense)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SummaryCard(
                  title: 'Tổng thu',
                  amount: periodIncome,
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.income,
                ),
                const SizedBox(width: 12),
                SummaryCard(
                  title: 'Tổng chi',
                  amount: periodExpense,
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.expense,
                ),
              ],
            ),
            const SizedBox(height: 18),
            SegmentedButton<String>(
              selected: {_viewMode},
              segments: const [
                ButtonSegment(
                  value: 'month',
                  icon: Icon(Icons.calendar_month_outlined),
                  label: Text('Theo tháng'),
                ),
                ButtonSegment(
                  value: 'year',
                  icon: Icon(Icons.calendar_today_outlined),
                  label: Text('Theo năm'),
                ),
              ],
              onSelectionChanged: (value) =>
                  setState(() => _viewMode = value.first),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                if (_viewMode == 'year') {
                  final picked = await showYearPickerDialog(
                    context: context,
                    initialYear: _selectedYear,
                  );
                  if (picked != null) {
                    setState(() => _selectedYear = picked);
                  }
                  return;
                }

                final picked = await showMonthYearPickerDialog(
                  context: context,
                  initialMonth: _selectedMonth,
                );
                if (picked != null) {
                  setState(() {
                    _selectedMonth = picked;
                    _selectedYear = picked.year;
                  });
                }
              },
              icon: Icon(
                _viewMode == 'year'
                    ? Icons.calendar_today_outlined
                    : Icons.calendar_month_outlined,
              ),
              label: Text(periodLabel),
            ),
            const SizedBox(height: 18),
            if (provider.allTransactions.isEmpty)
              const EmptyState(
                title: 'Chưa có dữ liệu thống kê',
                message: 'Thêm giao dịch để xem biểu đồ thu chi.',
                icon: Icons.pie_chart_outline,
              )
            else ...[
              if (expenseByCategory.isEmpty)
                EmptyState(
                  title: 'Chưa có chi tiêu trong $periodLabel',
                  message: 'Biểu đồ danh mục sẽ xuất hiện khi có khoản chi.',
                  icon: Icons.donut_large,
                )
              else
                ExpensePieChart(data: expenseByCategory),
              const SizedBox(height: 18),
              MonthlyBarChart(data: provider.monthlySummary),
              const SizedBox(height: 18),
              BalanceLineChart(transactions: provider.allTransactions),
              const SizedBox(height: 18),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top 5 danh mục chi nhiều nhất - $periodLabel',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (topCategories.isEmpty)
                      const Text(
                        'Chưa có dữ liệu chi tiêu.',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    else
                      ...topCategories
                          .take(5)
                          .map(
                            (entry) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.local_fire_department_outlined,
                                color: AppColors.expense,
                              ),
                              title: Text(entry.key),
                              trailing: Text(
                                CurrencyHelper.format(entry.value),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
