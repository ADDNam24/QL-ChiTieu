import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/premium_card.dart';
import '../../models/wallet_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final transactions = context.watch<TransactionProvider>().allTransactions;

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý ví')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.padding),
        children: [
          CustomButton(
            label: 'Thêm ví',
            icon: Icons.add,
            onPressed: () => _showWalletDialog(context),
          ),
          const SizedBox(height: 12),
          CustomButton(
            label: 'Chuyển tiền giữa các ví',
            icon: Icons.swap_horiz,
            backgroundColor: AppColors.primaryDark,
            onPressed: () =>
                _showTransferDialog(context, walletProvider.wallets),
          ),
          const SizedBox(height: 18),
          if (walletProvider.wallets.isEmpty)
            const EmptyState(
              title: 'Chưa có ví',
              message: 'Thêm ví tiền mặt, ngân hàng hoặc tiết kiệm.',
            )
          else
            ...walletProvider.wallets.map(
              (wallet) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PremiumCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: wallet.color.withValues(alpha: 0.14),
                      child: Icon(wallet.icon, color: wallet.color),
                    ),
                    title: Text(
                      wallet.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(wallet.type),
                    trailing: Text(
                      CurrencyHelper.format(
                        walletProvider.walletBalance(
                          wallet.id ?? 0,
                          transactions,
                        ),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    onTap: () => _showWalletDialog(context, wallet: wallet),
                    onLongPress: () {
                      if (wallet.id != null) {
                        walletProvider.deleteWallet(wallet.id!);
                      }
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showWalletDialog(BuildContext context, {WalletModel? wallet}) {
    final nameController = TextEditingController(text: wallet?.name ?? '');
    final balanceController = TextEditingController(
      text: wallet?.balance.toStringAsFixed(0) ?? '0',
    );
    var type = wallet?.type ?? 'cash';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(wallet == null ? 'Thêm ví' : 'Sửa ví'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên ví'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số dư ban đầu'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Loại ví'),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Tiền mặt')),
                  DropdownMenuItem(value: 'bank', child: Text('Ngân hàng')),
                  DropdownMenuItem(value: 'saving', child: Text('Tiết kiệm')),
                  DropdownMenuItem(value: 'other', child: Text('Khác')),
                ],
                onChanged: (value) => setState(() => type = value ?? type),
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
                final name = nameController.text.trim();
                final balance = double.tryParse(balanceController.text) ?? 0;
                if (name.isEmpty) {
                  return;
                }
                final model = WalletModel(
                  id: wallet?.id,
                  name: name,
                  type: type,
                  balance: balance,
                  iconCodePoint:
                      Icons.account_balance_wallet_outlined.codePoint,
                  colorValue: AppColors.primary.toARGB32(),
                  createdAt: wallet?.createdAt ?? DateTime.now(),
                );
                final provider = context.read<WalletProvider>();
                wallet == null
                    ? await provider.addWallet(model)
                    : await provider.updateWallet(model);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransferDialog(BuildContext context, List<WalletModel> wallets) {
    if (wallets.length < 2) return;
    var from = wallets.first;
    var to = wallets[1];
    final amountController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Chuyển ví'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<WalletModel>(
                initialValue: from,
                decoration: const InputDecoration(labelText: 'Từ ví'),
                items: wallets
                    .map((w) => DropdownMenuItem(value: w, child: Text(w.name)))
                    .toList(),
                onChanged: (value) => setState(() => from = value ?? from),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<WalletModel>(
                initialValue: to,
                decoration: const InputDecoration(labelText: 'Đến ví'),
                items: wallets
                    .map((w) => DropdownMenuItem(value: w, child: Text(w.name)))
                    .toList(),
                onChanged: (value) => setState(() => to = value ?? to),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số tiền'),
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
                await context.read<WalletProvider>().transfer(
                  from: from,
                  to: to,
                  amount: amount,
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Chuyển'),
            ),
          ],
        ),
      ),
    );
  }
}
