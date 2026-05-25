import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saving_goal_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../budget/budget_screen.dart';
import '../category/category_screen.dart';
import '../recurring/recurring_screen.dart';
import '../reminder/reminder_screen.dart';
import '../report/report_screen.dart';
import '../saving_goal/saving_goal_screen.dart';
import '../security/security_screen.dart';
import '../settings/theme_screen.dart';
import '../wallet/wallet_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final transactions = context.watch<TransactionProvider>();
    final wallets = context.watch<WalletProvider>();
    final goals = context.watch<SavingGoalProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cá nhân')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.padding),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.inputFill,
                  child: Icon(Icons.person, color: AppColors.primary, size: 46),
                ),
                const SizedBox(height: 14),
                Text(
                  auth.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showEditNameDialog(context, auth.name),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Đổi tên'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showChangePasswordDialog(context),
                      icon: const Icon(Icons.lock_reset_outlined),
                      label: const Text('Đổi mật khẩu'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoTile(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Tổng số ví',
            value: '${wallets.walletCount}',
          ),
          _InfoTile(
            icon: Icons.receipt_long_outlined,
            label: 'Tổng số giao dịch',
            value: '${transactions.allTransactions.length}',
          ),
          _InfoTile(
            icon: Icons.arrow_downward_rounded,
            label: 'Tổng số tiền đã thu',
            value: CurrencyHelper.format(transactions.totalIncome),
            color: AppColors.income,
          ),
          _InfoTile(
            icon: Icons.flag_outlined,
            label: 'Số mục tiêu tiết kiệm',
            value: '${goals.goalCount}',
          ),
          const SizedBox(height: 16),
          _MenuCard(
            items: [
              _MenuItem(
                Icons.account_balance_wallet_outlined,
                'Quản lý ví',
                const WalletScreen(),
              ),
              _MenuItem(
                Icons.category_outlined,
                'Danh mục',
                const CategoryScreen(),
              ),
              _MenuItem(
                Icons.track_changes_outlined,
                'Ngân sách',
                const BudgetScreen(),
              ),
              _MenuItem(
                Icons.flag_outlined,
                'Mục tiêu tiết kiệm',
                const SavingGoalScreen(),
              ),
              _MenuItem(
                Icons.repeat,
                'Giao dịch định kỳ',
                const RecurringScreen(),
              ),
              _MenuItem(
                Icons.notifications_outlined,
                'Nhắc nhở',
                const ReminderScreen(),
              ),
              _MenuItem(
                Icons.summarize_outlined,
                'Báo cáo',
                const ReportScreen(),
              ),
              _MenuItem(
                Icons.security_outlined,
                'Bảo mật',
                const SecurityScreen(),
              ),
              _MenuItem(
                Icons.palette_outlined,
                'Giao diện',
                const ThemeScreen(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoTile(
            icon: Icons.arrow_upward_rounded,
            label: 'Tổng số tiền đã chi',
            value: CurrencyHelper.format(transactions.totalExpense),
            color: AppColors.expense,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin ứng dụng',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                SizedBox(height: 12),
                Text('Tên app: ${AppStrings.appName}'),
                SizedBox(height: 6),
                Text('Phiên bản: ${AppStrings.version}'),
                SizedBox(height: 6),
                Text('Mô tả: ${AppStrings.appDescription}'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          CustomButton(
            label: 'Đăng xuất',
            icon: Icons.logout,
            backgroundColor: AppColors.expense,
            onPressed: context.read<AuthProvider>().logout,
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Đổi tên người dùng'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Tên hiển thị',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Vui lòng nhập tên'
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                await context.read<AuthProvider>().updateName(controller.text);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Đổi mật khẩu'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentController,
                  autofocus: true,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu hiện tại',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Vui lòng nhập mật khẩu hiện tại'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu mới',
                    prefixIcon: Icon(Icons.password_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mật khẩu mới';
                    }
                    if (value.trim().length < 4) {
                      return 'Mật khẩu cần ít nhất 4 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nhập lại mật khẩu mới',
                    prefixIcon: Icon(Icons.verified_user_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập lại mật khẩu mới';
                    }
                    if (value != newController.text) {
                      return 'Mật khẩu nhập lại không trùng';
                    }
                    return null;
                  },
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
                if (!formKey.currentState!.validate()) return;
                final success = await context
                    .read<AuthProvider>()
                    .changePassword(
                      currentPassword: currentController.text,
                      newPassword: newController.text,
                    );
                if (!dialogContext.mounted) return;
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mật khẩu hiện tại không đúng'),
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã đổi mật khẩu')),
                );
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.icon, this.title, this.screen);

  final IconData icon;
  final String title;
  final Widget screen;
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.items});

  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: items
            .map(
              (item) => ListTile(
                leading: Icon(item.icon, color: AppColors.primary),
                title: Text(item.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.screen),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
