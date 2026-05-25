import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/transaction_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key, this.initialType = 'expense'});

  final String initialType;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late String _type;
  String? _category;
  int? _walletId;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    final transaction = TransactionModel(
      title: _titleController.text.trim(),
      amount: amount,
      type: _type,
      category: _category ?? 'Khác',
      walletId: _walletId ?? 1,
      date: _date,
      note: _noteController.text.trim(),
      createdAt: DateTime.now(),
    );
    await context.read<TransactionProvider>().addTransaction(transaction);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().byType(_type);
    final wallets = context.watch<WalletProvider>().wallets;
    _category ??= categories.isEmpty ? 'Khác' : categories.first.name;
    _walletId ??= wallets.isEmpty ? 1 : wallets.first.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm giao dịch')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'income',
                    icon: Icon(Icons.arrow_downward),
                    label: Text('Thu'),
                  ),
                  ButtonSegment(
                    value: 'expense',
                    icon: Icon(Icons.arrow_upward),
                    label: Text('Chi'),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (values) {
                  setState(() {
                    _type = values.first;
                    final nextCategories = context
                        .read<CategoryProvider>()
                        .byType(_type);
                    _category = nextCategories.isEmpty
                        ? 'Khác'
                        : nextCategories.first.name;
                  });
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _titleController,
                label: 'Tiêu đề',
                icon: Icons.edit_note,
                validator: _required,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _amountController,
                label: 'Số tiền',
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final amount = double.tryParse(
                    (value ?? '').replaceAll(',', '.'),
                  );
                  if (amount == null || amount <= 0) {
                    return 'Số tiền không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                initialValue: _walletId,
                decoration: const InputDecoration(
                  labelText: 'Ví',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                items: wallets
                    .map(
                      (wallet) => DropdownMenuItem(
                        value: wallet.id,
                        child: Text(wallet.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _walletId = value),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: categories
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.name,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _category = value),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(DateTime.now().year - 5),
                    lastDate: DateTime(DateTime.now().year + 2),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text('Ngày: ${DateHelper.formatDate(_date)}'),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _noteController,
                label: 'Ghi chú',
                icon: Icons.notes_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Lưu giao dịch',
                icon: Icons.save_outlined,
                backgroundColor: _type == 'income'
                    ? AppColors.income
                    : AppColors.primary,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Vui lòng nhập thông tin' : null;
}
