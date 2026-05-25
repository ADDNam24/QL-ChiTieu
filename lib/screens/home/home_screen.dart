import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/animated_entry.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/premium_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../transaction/edit_transaction_screen.dart';
import '../transaction/widgets/transaction_item.dart';
import 'widgets/balance_card.dart';
import 'widgets/quick_action_grid.dart';
import 'widgets/summary_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onTabSelected});

  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<TransactionProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final hasBudgetAlert = budgetProvider.isOverBudget(
      provider.allTransactions,
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.loadTransactions();
          await budgetProvider.loadBudgets();
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              decoration: const BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào, ${auth.name}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 80),
                    child: BalanceCard(
                      balance: provider.balance,
                      monthIncome: provider.currentMonthIncome,
                      monthExpense: provider.currentMonthExpense,
                      expenseChangePercent: provider.expenseChangePercent,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                children: [
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 120),
                    child: Row(
                      children: [
                        SummaryCard(
                          title: 'Tổng thu',
                          amount: provider.totalIncome,
                          icon: Icons.arrow_downward_rounded,
                          color: AppColors.income,
                        ),
                        const SizedBox(width: 12),
                        SummaryCard(
                          title: 'Tổng chi',
                          amount: provider.totalExpense,
                          icon: Icons.arrow_upward_rounded,
                          color: AppColors.expense,
                        ),
                      ],
                    ),
                  ),
                  if (hasBudgetAlert) ...[
                    const SizedBox(height: 14),
                    const PremiumCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(0xFFFFF3E0),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.warning,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Cảnh báo thông minh: chi tiêu tháng này đã vượt 80% ngân sách.',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 180),
                    child: QuickActionGrid(onTabSelected: onTabSelected),
                  ),
                  const SizedBox(height: 24),
                  SectionTitle(
                    title: 'Giao dịch gần đây',
                    action: TextButton(
                      onPressed: () => onTabSelected(1),
                      child: const Text('Xem tất cả'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (provider.recentTransactions.isEmpty)
                    const EmptyState(
                      title: 'Chưa có giao dịch',
                      message: 'Hãy thêm khoản thu hoặc chi đầu tiên của bạn.',
                    )
                  else
                    ...provider.recentTransactions.toList().asMap().entries.map(
                      (entry) => AnimatedEntry(
                        delay: Duration(milliseconds: 60 * entry.key),
                        offset: const Offset(0, 10),
                        child: TransactionItem(
                          transaction: entry.value,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditTransactionScreen(
                                  transaction: entry.value,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
