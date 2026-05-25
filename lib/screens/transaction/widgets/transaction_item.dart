import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/currency_helper.dart';
import '../../../core/helpers/date_helper.dart';
import '../../../models/category_model.dart';
import '../../../models/transaction_model.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    super.key,
    required this.transaction,
    required this.onTap,
    this.onDelete,
  });

  final TransactionModel transaction;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final category = CategoryModel.find(transaction.category, transaction.type);
    final color = transaction.isIncome ? AppColors.income : AppColors.expense;
    final amountPrefix = transaction.isIncome ? '+' : '-';

    final item = Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: category.color.withValues(alpha: 0.12),
          child: Icon(category.icon, color: category.color),
        ),
        title: Text(
          transaction.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${transaction.category} • ${DateHelper.formatDate(transaction.date)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$amountPrefix${CurrencyHelper.format(transaction.amount)}',
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
            if (onDelete != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.textMuted,
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );

    if (onDelete == null) return item;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 18),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: item,
    );
  }
}
