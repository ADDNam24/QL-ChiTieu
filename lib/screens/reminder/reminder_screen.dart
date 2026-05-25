import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/premium_card.dart';
import '../../models/reminder_model.dart';
import '../../providers/reminder_provider.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReminderProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Nhắc nhở')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.padding),
        children: [
          CustomButton(
            label: 'Thêm nhắc nhở',
            icon: Icons.add_alert_outlined,
            onPressed: () => _showDialog(context),
          ),
          const SizedBox(height: 16),
          ...provider.reminders.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PremiumCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.notifications_active_outlined),
                  ),
                  title: Text(item.title),
                  subtitle: Text('${item.type} • ${item.timeText}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: item.id == null
                        ? null
                        : () => provider.deleteReminder(item.id!),
                  ),
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
    final time = TextEditingController(text: '21:00');
    var type = 'daily_expense';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thêm nhắc nhở'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Loại'),
                items: const [
                  DropdownMenuItem(
                    value: 'daily_expense',
                    child: Text('Nhập chi tiêu cuối ngày'),
                  ),
                  DropdownMenuItem(
                    value: 'bill',
                    child: Text('Thanh toán hóa đơn'),
                  ),
                  DropdownMenuItem(
                    value: 'budget_check',
                    child: Text('Kiểm tra ngân sách'),
                  ),
                ],
                onChanged: (value) => setState(() => type = value ?? type),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: time,
                decoration: const InputDecoration(labelText: 'Giờ nhắc'),
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
                if (title.text.trim().isEmpty) return;
                await context.read<ReminderProvider>().addReminder(
                  ReminderModel(
                    title: title.text.trim(),
                    type: type,
                    timeText: time.text.trim(),
                    isActive: true,
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
