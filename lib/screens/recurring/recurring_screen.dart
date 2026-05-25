import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/premium_card.dart';
import '../../models/recurring_transaction_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/recurring_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';

class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecurringProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Giao dịch định kỳ')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.padding),
        children: [
          CustomButton(
            label: 'Tạo định kỳ',
            icon: Icons.repeat,
            onPressed: () => _showDialog(context),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => provider.processDueTransactions(
              context.read<TransactionProvider>(),
            ),
            icon: const Icon(Icons.play_circle_outline),
            label: const Text('Chạy giao dịch đến hạn'),
          ),
          const SizedBox(height: 16),
          ...provider.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PremiumCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.autorenew)),
                  title: Text(item.title),
                  subtitle: Text(
                    '${item.cycle} • đến hạn ${DateHelper.formatDate(item.nextRunDate)}',
                  ),
                  trailing: Text(CurrencyHelper.format(item.amount)),
                  onLongPress: item.id == null
                      ? null
                      : () => provider.deleteRecurring(item.id!),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context) {
    final title = TextEditingController();
    final amount = TextEditingController();
    final note = TextEditingController();
    var type = 'expense';
    var cycle = 'monthly';
    final initialWallets = context.read<WalletProvider>().wallets;
    final initialCategories = context.read<CategoryProvider>().byType(type);
    var walletId = initialWallets.isEmpty ? 1 : initialWallets.first.id ?? 1;
    var category = initialCategories.isEmpty
        ? 'Khác'
        : initialCategories.first.name;
    var nextRun = DateTime.now();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final wallets = context.read<WalletProvider>().wallets;
          final categories = context.read<CategoryProvider>().byType(type);
          return AlertDialog(
            title: const Text('Tạo giao dịch định kỳ'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Tiêu đề'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amount,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Số tiền'),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    selected: {type},
                    segments: const [
                      ButtonSegment(value: 'income', label: Text('Thu')),
                      ButtonSegment(value: 'expense', label: Text('Chi')),
                    ],
                    onSelectionChanged: (value) => setState(() {
                      type = value.first;
                      final nextCategories = context
                          .read<CategoryProvider>()
                          .byType(type);
                      category = nextCategories.isEmpty
                          ? 'Khác'
                          : nextCategories.first.name;
                    }),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: walletId,
                    decoration: const InputDecoration(labelText: 'Ví'),
                    items: wallets
                        .map(
                          (w) => DropdownMenuItem(
                            value: w.id,
                            child: Text(w.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => walletId = value ?? walletId,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Danh mục'),
                    items: categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.name,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => category = value ?? category,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: cycle,
                    decoration: const InputDecoration(labelText: 'Chu kỳ'),
                    items: const [
                      DropdownMenuItem(
                        value: 'daily',
                        child: Text('Hằng ngày'),
                      ),
                      DropdownMenuItem(
                        value: 'weekly',
                        child: Text('Hằng tuần'),
                      ),
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text('Hằng tháng'),
                      ),
                    ],
                    onChanged: (value) => cycle = value ?? cycle,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: nextRun,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 1),
                        ),
                        lastDate: DateTime.now().add(
                          const Duration(days: 3650),
                        ),
                      );
                      if (picked != null) setState(() => nextRun = picked);
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: Text(DateHelper.formatDate(nextRun)),
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
                  if (title.text.trim().isEmpty) return;
                  await context.read<RecurringProvider>().addRecurring(
                    RecurringTransactionModel(
                      title: title.text.trim(),
                      amount: double.tryParse(amount.text) ?? 0,
                      type: type,
                      category: category,
                      walletId: walletId,
                      cycle: cycle,
                      nextRunDate: nextRun,
                      note: note.text.trim(),
                      isActive: true,
                      createdAt: DateTime.now(),
                    ),
                  );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }
}
