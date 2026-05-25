import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/currency_helper.dart';
import '../../../models/transaction_model.dart';

class BalanceLineChart extends StatelessWidget {
  const BalanceLineChart({super.key, required this.transactions});

  final List<TransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();

    final sorted = [...transactions]..sort((a, b) => a.date.compareTo(b.date));
    var balance = 0.0;
    final spots = <FlSpot>[];
    for (var i = 0; i < sorted.length; i++) {
      balance += sorted[i].isIncome ? sorted[i].amount : -sorted[i].amount;
      spots.add(FlSpot(i.toDouble(), balance));
    }

    final maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final paddedMax = maxY == minY
        ? maxY + 100000
        : maxY + (maxY - minY).abs() * 0.15;
    final paddedMin = maxY == minY
        ? minY - 100000
        : minY - (maxY - minY).abs() * 0.15;
    final interval = ((paddedMax - paddedMin).abs() / 4).clamp(
      1,
      double.infinity,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Xu hướng số dư',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              Text(
                CurrencyHelper.format(balance),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Diễn biến số dư sau mỗi giao dịch',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: paddedMin,
                maxY: paddedMax,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF2A1730),
                    getTooltipItems: (items) => items.map((item) {
                      final index = item.x.toInt().clamp(0, sorted.length - 1);
                      final transaction = sorted[index];
                      return LineTooltipItem(
                        '${transaction.title}\n${CurrencyHelper.format(item.y)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval.toDouble(),
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
                      reservedSize: 52,
                      interval: interval.toDouble(),
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
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: spots.length <= 4
                          ? 1
                          : (spots.length / 4).ceilToDouble(),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sorted.length) {
                          return const SizedBox.shrink();
                        }
                        final date = sorted[index].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.25,
                    color: AppColors.primary,
                    barWidth: 4,
                    dotData: FlDotData(
                      show: spots.length <= 12,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: 3.5,
                            color: AppColors.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.22),
                          AppColors.primary.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 550),
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }
}
