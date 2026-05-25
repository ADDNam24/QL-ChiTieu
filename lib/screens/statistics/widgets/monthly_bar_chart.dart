import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/currency_helper.dart';

class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({super.key, required this.data});

  final Map<String, Map<String, double>> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final keys = data.keys.toList()..sort();
    final visibleKeys = keys.length > 6 ? keys.sublist(keys.length - 6) : keys;
    final maxValue = visibleKeys.fold<double>(0, (max, key) {
      final month = data[key]!;
      final income = month['income'] ?? 0;
      final expense = month['expense'] ?? 0;
      final value = income > expense ? income : expense;
      return value > max ? value : max;
    });
    final chartMaxY = _niceMax(maxValue);
    final interval = chartMaxY / 4;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thu chi theo tháng',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'So sánh 6 tháng gần nhất',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: chartMaxY,
                groupsSpace: 18,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF2A1730),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final month = visibleKeys[group.x.toInt()];
                      final label = rodIndex == 0 ? 'Thu' : 'Chi';
                      return BarTooltipItem(
                        '$label $month\n${CurrencyHelper.format(rod.toY)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.divider.withValues(alpha: 0.85),
                    strokeWidth: 1,
                    dashArray: [6, 4],
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: AppColors.divider),
                    bottom: BorderSide(color: AppColors.divider),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: interval,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          CurrencyHelper.compact(value),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= visibleKeys.length) {
                          return const SizedBox.shrink();
                        }
                        final parts = visibleKeys[index].split('-');
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'T${int.parse(parts[1])}\n${parts[0].substring(2)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              height: 1.15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(visibleKeys.length, (index) {
                  final month = data[visibleKeys[index]]!;
                  return BarChartGroupData(
                    x: index,
                    barsSpace: 5,
                    barRods: [
                      BarChartRodData(
                        toY: month['income'] ?? 0,
                        color: AppColors.income,
                        width: 13,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(7),
                        ),
                      ),
                      BarChartRodData(
                        toY: month['expense'] ?? 0,
                        color: AppColors.expense,
                        width: 13,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(7),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              duration: const Duration(milliseconds: 550),
              curve: Curves.easeOutCubic,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: AppColors.income, label: 'Thu nhập'),
              SizedBox(width: 18),
              _Legend(color: AppColors.expense, label: 'Chi tiêu'),
            ],
          ),
        ],
      ),
    );
  }

  double _niceMax(double value) {
    if (value <= 0) return 100000;
    final padded = value * 1.18;
    if (padded <= 100000) return 100000;
    if (padded <= 500000) return 500000;
    if (padded <= 1000000) return 1000000;
    if (padded <= 5000000) return 5000000;
    if (padded <= 10000000) return 10000000;
    return ((padded / 10000000).ceil() * 10000000).toDouble();
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
