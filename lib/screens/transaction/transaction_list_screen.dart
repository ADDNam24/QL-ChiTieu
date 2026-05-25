import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';
import 'widgets/transaction_filter_bar.dart';
import 'widgets/transaction_item.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch'),
        actions: [
          IconButton(
            onPressed: () => _showFilterSheet(context),
            icon: const Icon(Icons.tune),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadTransactions,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.padding),
          children: [
            TransactionFilterBar(
              searchController: _searchController,
              type: provider.typeFilter,
              month: provider.monthFilter,
              onSearchChanged: provider.searchTransactions,
              onTypeChanged: provider.filterByType,
              onMonthChanged: provider.filterByMonth,
            ),
            const SizedBox(height: 18),
            if (provider.transactions.isEmpty)
              const EmptyState(
                title: 'Không có giao dịch',
                message: 'Thử đổi bộ lọc hoặc thêm giao dịch mới.',
              )
            else
              ...provider.transactions.map(
                (transaction) => TransactionItem(
                  transaction: transaction,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditTransactionScreen(transaction: transaction),
                      ),
                    );
                  },
                  onDelete: () {
                    final id = transaction.id;
                    if (id != null) provider.deleteTransaction(id);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final transactionProvider = context.read<TransactionProvider>();
    final wallets = context.read<WalletProvider>().wallets;
    final categories = context.read<CategoryProvider>().categories;
    var type = transactionProvider.typeFilter;
    int? walletId = transactionProvider.walletFilter;
    String? category = transactionProvider.categoryFilter;
    var sort = transactionProvider.sortMode;
    final minAmount = TextEditingController(
      text: transactionProvider.minAmount?.toStringAsFixed(0) ?? '',
    );
    final maxAmount = TextEditingController(
      text: transactionProvider.maxAmount?.toStringAsFixed(0) ?? '',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bộ lọc nâng cao',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Loại'),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                    DropdownMenuItem(value: 'income', child: Text('Thu')),
                    DropdownMenuItem(value: 'expense', child: Text('Chi')),
                  ],
                  onChanged: (value) => setState(() => type = value ?? type),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: walletId,
                  decoration: const InputDecoration(labelText: 'Ví'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Tất cả ví'),
                    ),
                    ...wallets.map(
                      (wallet) => DropdownMenuItem<int?>(
                        value: wallet.id,
                        child: Text(wallet.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => walletId = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tất cả danh mục'),
                    ),
                    ...categories.map(
                      (item) => DropdownMenuItem<String?>(
                        value: item.name,
                        child: Text(item.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => category = value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minAmount,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Từ tiền'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: maxAmount,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Đến tiền',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: sort,
                  decoration: const InputDecoration(labelText: 'Sắp xếp'),
                  items: const [
                    DropdownMenuItem(value: 'newest', child: Text('Mới nhất')),
                    DropdownMenuItem(value: 'oldest', child: Text('Cũ nhất')),
                    DropdownMenuItem(
                      value: 'amount_asc',
                      child: Text('Số tiền tăng dần'),
                    ),
                    DropdownMenuItem(
                      value: 'amount_desc',
                      child: Text('Số tiền giảm dần'),
                    ),
                  ],
                  onChanged: (value) => setState(() => sort = value ?? sort),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          transactionProvider.clearAdvancedFilters();
                          Navigator.pop(sheetContext);
                        },
                        child: const Text('Xóa lọc'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          transactionProvider.applyAdvancedFilters(
                            type: type,
                            walletId: walletId,
                            category: category,
                            minAmount: double.tryParse(minAmount.text),
                            maxAmount: double.tryParse(maxAmount.text),
                            sortMode: sort,
                          );
                          Navigator.pop(sheetContext);
                        },
                        child: const Text('Áp dụng'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
