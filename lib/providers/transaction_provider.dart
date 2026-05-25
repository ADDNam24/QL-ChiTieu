import 'package:flutter/foundation.dart';

import '../core/helpers/date_helper.dart';
import '../data/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  TransactionProvider({TransactionRepository? repository})
    : _repository = repository ?? TransactionRepository();

  final TransactionRepository _repository;

  List<TransactionModel> _transactions = [];
  List<TransactionModel> _visibleTransactions = [];
  String _query = '';
  String _typeFilter = 'all';
  int? _walletFilter;
  String? _categoryFilter;
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;
  String _sortMode = 'newest';
  DateTime? _monthFilter;
  bool _isLoading = false;

  List<TransactionModel> get transactions => _visibleTransactions;
  List<TransactionModel> get allTransactions => _transactions;
  bool get isLoading => _isLoading;
  String get typeFilter => _typeFilter;
  DateTime? get monthFilter => _monthFilter;
  int? get walletFilter => _walletFilter;
  String? get categoryFilter => _categoryFilter;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  double? get minAmount => _minAmount;
  double? get maxAmount => _maxAmount;
  String get sortMode => _sortMode;

  double get totalIncome => _sumByType(_transactions, 'income');
  double get totalExpense => _sumByType(_transactions, 'expense');
  double get balance => totalIncome - totalExpense;
  double get currentMonthIncome => _sumByMonth('income', DateTime.now());
  double get currentMonthExpense => _sumByMonth('expense', DateTime.now());
  double get previousMonthExpense => _sumByMonth(
    'expense',
    DateTime(DateTime.now().year, DateTime.now().month - 1),
  );
  double get expenseChangePercent {
    if (previousMonthExpense <= 0) return currentMonthExpense > 0 ? 100 : 0;
    return ((currentMonthExpense - previousMonthExpense) /
            previousMonthExpense) *
        100;
  }

  List<TransactionModel> get recentTransactions {
    return _transactions.take(5).toList();
  }

  Map<String, double> get expenseByCategory {
    final data = <String, double>{};
    for (final transaction in _transactions.where(
      (item) => item.type == 'expense',
    )) {
      data.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    return data;
  }

  Map<String, Map<String, double>> get monthlySummary {
    final data = <String, Map<String, double>>{};
    for (final transaction in _transactions) {
      final key = DateHelper.monthKey(transaction.date);
      data.putIfAbsent(key, () => {'income': 0, 'expense': 0});
      data[key]![transaction.type] =
          (data[key]![transaction.type] ?? 0) + transaction.amount;
    }
    return data;
  }

  double _sumByType(List<TransactionModel> source, String type) {
    return source
        .where((transaction) => transaction.type == type)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double _sumByMonth(String type, DateTime month) {
    return _transactions
        .where(
          (transaction) =>
              transaction.type == type &&
              transaction.date.year == month.year &&
              transaction.date.month == month.month,
        )
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    _transactions = await _repository.getAllTransactions();
    _applyFilters();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _repository.insertTransaction(transaction);
    await loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _repository.updateTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _repository.deleteTransaction(id);
    await loadTransactions();
  }

  void searchTransactions(String query) {
    _query = query.trim().toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void filterByType(String type) {
    _typeFilter = type;
    _applyFilters();
    notifyListeners();
  }

  void filterByMonth(DateTime? month) {
    _monthFilter = month;
    _applyFilters();
    notifyListeners();
  }

  void applyAdvancedFilters({
    String? type,
    int? walletId,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? sortMode,
  }) {
    _typeFilter = type ?? _typeFilter;
    _walletFilter = walletId;
    _categoryFilter = category;
    _startDate = startDate;
    _endDate = endDate;
    _minAmount = minAmount;
    _maxAmount = maxAmount;
    _sortMode = sortMode ?? _sortMode;
    _applyFilters();
    notifyListeners();
  }

  void clearAdvancedFilters() {
    _typeFilter = 'all';
    _walletFilter = null;
    _categoryFilter = null;
    _startDate = null;
    _endDate = null;
    _minAmount = null;
    _maxAmount = null;
    _sortMode = 'newest';
    _monthFilter = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    Iterable<TransactionModel> result = _transactions;

    if (_query.isNotEmpty) {
      result = result.where(
        (transaction) =>
            transaction.title.toLowerCase().contains(_query) ||
            transaction.note.toLowerCase().contains(_query) ||
            transaction.category.toLowerCase().contains(_query),
      );
    }

    if (_typeFilter != 'all') {
      result = result.where((transaction) => transaction.type == _typeFilter);
    }

    if (_monthFilter != null) {
      result = result.where(
        (transaction) =>
            transaction.date.year == _monthFilter!.year &&
            transaction.date.month == _monthFilter!.month,
      );
    }

    if (_walletFilter != null) {
      result = result.where(
        (transaction) => transaction.walletId == _walletFilter,
      );
    }

    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      result = result.where(
        (transaction) => transaction.category == _categoryFilter,
      );
    }

    if (_startDate != null) {
      result = result.where(
        (transaction) => !transaction.date.isBefore(_startDate!),
      );
    }

    if (_endDate != null) {
      result = result.where(
        (transaction) => !transaction.date.isAfter(_endDate!),
      );
    }

    if (_minAmount != null) {
      result = result.where((transaction) => transaction.amount >= _minAmount!);
    }

    if (_maxAmount != null) {
      result = result.where((transaction) => transaction.amount <= _maxAmount!);
    }

    _visibleTransactions = result.toList();
    switch (_sortMode) {
      case 'oldest':
        _visibleTransactions.sort((a, b) => a.date.compareTo(b.date));
      case 'amount_asc':
        _visibleTransactions.sort((a, b) => a.amount.compareTo(b.amount));
      case 'amount_desc':
        _visibleTransactions.sort((a, b) => b.amount.compareTo(a.amount));
      default:
        _visibleTransactions.sort((a, b) => b.date.compareTo(a.date));
    }
  }
}
