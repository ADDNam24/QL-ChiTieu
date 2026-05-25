import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/premium_card.dart';
import '../../providers/security_provider.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecurityProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Bảo mật')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.padding),
        children: [
          PremiumCard(
            child: Column(
              children: [
                SwitchListTile(
                  value: provider.isPinEnabled,
                  onChanged: provider.hasPin ? provider.setEnabled : null,
                  title: const Text('Khóa app bằng mã PIN'),
                  subtitle: Text(
                    provider.hasPin
                        ? 'PIN đã được thiết lập'
                        : 'Tạo PIN trước khi bật',
                  ),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  label: 'Tạo hoặc đổi PIN 4 số',
                  icon: Icons.pin_outlined,
                  onPressed: () => _showPinDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPinDialog(BuildContext context) {
    final pin = TextEditingController();
    final confirm = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thiết lập PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pin,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(labelText: 'PIN 4 số'),
            ),
            TextField(
              controller: confirm,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(labelText: 'Nhập lại PIN'),
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
              if (pin.text != confirm.text) return;
              final ok = await context.read<SecurityProvider>().setPin(
                pin.text,
              );
              if (!dialogContext.mounted) return;
              if (ok) Navigator.pop(dialogContext);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
