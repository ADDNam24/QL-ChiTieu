import 'package:flutter/foundation.dart';

import '../core/helpers/date_helper.dart';
import '../data/database/app_database.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';

class BudgetProvider extends ChangeNotifier {
  BudgetProvider({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;
  List<BudgetModel> _budgets = [];

  List<BudgetModel> get budgets => _budgets;
  double get totalMonthlyBudget => _budgets
      .where((item) => item.monthKey == DateHelper.monthKey(DateTime.now()))
      .fold(0, (sum, item) => sum + item.amount);

  Future<void> loadBudgets() async {
    final rows = await _database.getAll('budgets', orderBy: 'month_key DESC');
    _budgets = rows.map(BudgetModel.fromMap).toList();
    notifyListeners();
  }

  Future<void> addBudget(BudgetModel budget) async {
    await _database.insert('budgets', budget.toMap());
    await loadBudgets();
  }

  Future<void> deleteBudget(int id) async {
    await _database.delete('budgets', id);
    await loadBudgets();
  }

  double spentFor(BudgetModel budget, List<TransactionModel> transactions) {
    return transactions
        .where(
          (item) =>
              item.type == 'expense' &&
              item.category == budget.category &&
              DateHelper.monthKey(item.date) == budget.monthKey,
        )
        .fold(0, (sum, item) => sum + item.amount);
  }

  bool isOverBudget(List<TransactionModel> transactions) {
    final monthKey = DateHelper.monthKey(DateTime.now());
    final budget = _budgets
        .where((item) => item.monthKey == monthKey)
        .fold(0.0, (sum, item) => sum + item.amount);
    if (budget <= 0) return false;
    final spent = transactions
        .where(
          (item) =>
              item.type == 'expense' &&
              DateHelper.monthKey(item.date) == monthKey,
        )
        .fold(0.0, (sum, item) => sum + item.amount);
    return spent >= budget * 0.8;
  }
}
