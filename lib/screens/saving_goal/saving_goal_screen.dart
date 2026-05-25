import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/premium_card.dart';
import '../../models/saving_goal_model.dart';
import '../../providers/saving_goal_provider.dart';

class SavingGoalScreen extends StatelessWidget {
  const SavingGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavingGoalProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Mục tiêu tiết kiệm')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.padding),
        children: [
          CustomButton(
            label: 'Tạo mục tiêu',
            icon: Icons.add,
            onPressed: () => _showGoalDialog(context),
          ),
          const SizedBox(height: 16),
          ...provider.goals.map(
            (goal) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: goal.id == null
                              ? null
                              : () => provider.deleteGoal(goal.id!),
                        ),
                      ],
                    ),
                    Text('Dự kiến: ${DateHelper.formatDate(goal.dueDate)}'),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: goal.progress,
                      minHeight: 10,
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${CurrencyHelper.format(goal.currentAmount)} / ${CurrencyHelper.format(goal.targetAmount)}',
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _showAddMoneyDialog(context, goal),
                      icon: const Icon(Icons.savings_outlined),
                      label: const Text('Nạp tiền'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGoalDialog(BuildContext context) {
    final name = TextEditingController();
    final target = TextEditingController();
    final current = TextEditingController(text: '0');
    final note = TextEditingController();
    var due = DateTime.now().add(const Duration(days: 90));
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tạo mục tiêu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Tên mục tiêu'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: target,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số tiền mục tiêu',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: current,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số tiền hiện tại',
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: due,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) setState(() => due = picked);
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(DateHelper.formatDate(due)),
                ),
                TextField(
                  controller: note,
                  decoration: const InputDecoration(labelText: 'Ghi chú'),
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
              onPressed: () async {
                if (name.text.trim().isEmpty) return;
                await context.read<SavingGoalProvider>().addGoal(
                  SavingGoalModel(
                    name: name.text.trim(),
                    targetAmount: double.tryParse(target.text) ?? 0,
                    currentAmount: double.tryParse(current.text) ?? 0,
                    dueDate: due,
                    note: note.text.trim(),
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

  void _showAddMoneyDialog(BuildContext context, SavingGoalModel goal) {
    final amount = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nạp tiền vào mục tiêu'),
        content: TextField(
          controller: amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Số tiền'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              await context.read<SavingGoalProvider>().addMoney(
                goal,
                double.tryParse(amount.text) ?? 0,
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Nạp'),
          ),
        ],
      ),
    );
  }
}
