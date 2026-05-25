import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';

class EditTransactionScreen extends StatefulWidget {
  const EditTransactionScreen({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late String _type;
  late String _category;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _titleController = TextEditingController(text: transaction.title);
    _amountController = TextEditingController(
      text: transaction.amount.toStringAsFixed(0),
    );
    _noteController = TextEditingController(text: transaction.note);
    _type = transaction.type;
    _category = transaction.category;
    _date = transaction.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    await context.read<TransactionProvider>().updateTransaction(
      widget.transaction.copyWith(
        title: _titleController.text.trim(),
        amount: amount,
        type: _type,
        category: _category,
        date: _date,
        note: _noteController.text.trim(),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final id = widget.transaction.id;
    if (id == null) return;
    await context.read<TransactionProvider>().deleteTransaction(id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sửa giao dịch')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'income', label: Text('Thu')),
                  ButtonSegment(value: 'expense', label: Text('Chi')),
                ],
                selected: {_type},
                onSelectionChanged: (values) {
                  setState(() {
                    _type = values.first;
                    _category = CategoryModel.byType(_type).first.name;
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
              DropdownButtonFormField<String>(
                initialValue:
                    CategoryModel.byType(
                      _type,
                    ).any((item) => item.name == _category)
                    ? _category
                    : CategoryModel.byType(_type).first.name,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: CategoryModel.byType(_type)
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.name,
                        child: Row(
                          children: [
                            Icon(item.icon, color: item.color, size: 20),
                            const SizedBox(width: 8),
                            Text(item.name),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
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
                label: 'Cập nhật',
                icon: Icons.check_circle_outline,
                onPressed: _update,
              ),
              const SizedBox(height: 10),
              CustomButton(
                label: 'Xóa',
                icon: Icons.delete_outline,
                backgroundColor: AppColors.expense,
                onPressed: _delete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty
        ? 'Vui lòng nhập thông tin'
        : null;
  }
}
