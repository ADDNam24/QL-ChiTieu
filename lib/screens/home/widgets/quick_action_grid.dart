import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../budget/budget_screen.dart';
import '../../report/report_screen.dart';
import '../../saving_goal/saving_goal_screen.dart';
import '../../transaction/add_transaction_screen.dart';
import '../../wallet/wallet_screen.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key, required this.onTabSelected});

  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        title: 'Thêm thu',
        icon: Icons.add_card_outlined,
        color: AppColors.income,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddTransactionScreen(initialType: 'income'),
          ),
        ),
      ),
      _QuickAction(
        title: 'Thêm chi',
        icon: Icons.remove_circle_outline,
        color: AppColors.expense,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddTransactionScreen(initialType: 'expense'),
          ),
        ),
      ),
      _QuickAction(
        title: 'Chuyển ví',
        icon: Icons.swap_horiz,
        color: AppColors.primary,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WalletScreen()),
        ),
      ),
      _QuickAction(
        title: 'Mục tiêu',
        icon: Icons.flag_outlined,
        color: AppColors.warning,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SavingGoalScreen()),
        ),
      ),
      _QuickAction(
        title: 'Ngân sách',
        icon: Icons.track_changes_outlined,
        color: AppColors.expense,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BudgetScreen()),
        ),
      ),
      _QuickAction(
        title: 'Báo cáo',
        icon: Icons.summarize_outlined,
        color: AppColors.primaryDark,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportScreen()),
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) => _QuickActionTile(action: actions[index]),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _QuickActionTile extends StatefulWidget {
  const _QuickActionTile({required this.action});

  final _QuickAction action;

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTap: widget.action.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.action.color.withValues(alpha: 0.10),
                blurRadius: _isPressed ? 8 : 16,
                offset: Offset(0, _isPressed ? 4 : 9),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: widget.action.color.withValues(alpha: 0.12),
                child: Icon(widget.action.icon, color: widget.action.color),
              ),
              const SizedBox(height: 8),
              Text(
                widget.action.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
