import 'package:flutter/foundation.dart';

import '../data/database/app_database.dart';
import '../models/recurring_transaction_model.dart';
import '../models/transaction_model.dart';
import 'transaction_provider.dart';

class RecurringProvider extends ChangeNotifier {
  RecurringProvider({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;
  List<RecurringTransactionModel> _items = [];

  List<RecurringTransactionModel> get items => _items;

  Future<void> loadRecurring() async {
    final rows = await _database.getAll(
      'recurring_transactions',
      orderBy: 'next_run_date ASC',
    );
    _items = rows.map(RecurringTransactionModel.fromMap).toList();
    notifyListeners();
  }

  Future<void> addRecurring(RecurringTransactionModel item) async {
    await _database.insert('recurring_transactions', item.toMap());
    await loadRecurring();
  }

  Future<void> deleteRecurring(int id) async {
    await _database.delete('recurring_transactions', id);
    await loadRecurring();
  }

  Future<void> processDueTransactions(
    TransactionProvider transactionProvider,
  ) async {
    await loadRecurring();
    final now = DateTime.now();
    for (final item in _items.where((item) => item.isActive)) {
      var nextRun = item.nextRunDate;
      var changed = false;
      while (!nextRun.isAfter(now)) {
        await transactionProvider.addTransaction(
          TransactionModel(
            title: item.title,
            amount: item.amount,
            type: item.type,
            category: item.category,
            walletId: item.walletId,
            date: nextRun,
            note: 'Tự động từ giao dịch định kỳ. ${item.note}',
            createdAt: DateTime.now(),
          ),
        );
        nextRun = _nextDate(nextRun, item.cycle);
        changed = true;
      }
      if (changed && item.id != null) {
        await _database.update(
          'recurring_transactions',
          item.copyWith(nextRunDate: nextRun).toMap(),
          item.id!,
        );
      }
    }
    await loadRecurring();
  }

  DateTime _nextDate(DateTime date, String cycle) {
    return switch (cycle) {
      'daily' => date.add(const Duration(days: 1)),
      'weekly' => date.add(const Duration(days: 7)),
      _ => DateTime(date.year, date.month + 1, date.day),
    };
  }
}
