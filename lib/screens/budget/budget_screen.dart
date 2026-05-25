import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/premium_card.dart';
import '../../models/budget_model.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgets = context.watch<BudgetProvider>();
    final transactions = context.watch<TransactionProvider>().allTransactions;
    return Scaffold(
      appBar: AppBar(title: const Text('Ngân sách tháng')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.padding),
        children: [
          CustomButton(
            label: 'Đặt ngân sách',
            icon: Icons.add,
            onPressed: () => _showDialog(context),
          ),
          const SizedBox(height: 16),
          ...budgets.budgets.map((budget) {
            final spent = budgets.spentFor(budget, transactions);
            final percent = budget.amount <= 0 ? 0.0 : spent / budget.amount;
            final color = percent >= 1
                ? AppColors.expense
                : percent >= 0.8
                ? AppColors.warning
                : AppColors.income;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${budget.category} • ${budget.monthKey}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: budget.id == null
                              ? null
                              : () => budgets.deleteBudget(budget.id!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percent.clamp(0, 1),
                      color: color,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${CurrencyHelper.format(spent)} / ${CurrencyHelper.format(budget.amount)} (${(percent * 100).toStringAsFixed(0)}%)',
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context) {
    final amountController = TextEditingController();
    final categories = context.read<CategoryProvider>().byType('expense');
    var category = categories.isEmpty ? 'Khác' : categories.first.name;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Đặt ngân sách'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Danh mục'),
                items: categories
                    .map(
                      (c) =>
                          DropdownMenuItem(value: c.name, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => category = value ?? category),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Ngân sách'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount <= 0) return;
                await context.read<BudgetProvider>().addBudget(
                  BudgetModel(
                    monthKey: DateHelper.monthKey(DateTime.now()),
                    category: category,
                    amount: amount,
                    createdAt: DateTime.now(),
                  ),
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
