import 'package:flutter/foundation.dart';

import '../data/database/app_database.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

class WalletProvider extends ChangeNotifier {
  WalletProvider({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;
  List<WalletModel> _wallets = [];

  List<WalletModel> get wallets => _wallets;
  int get walletCount => _wallets.length;

  WalletModel? byId(int id) {
    try {
      return _wallets.firstWhere((wallet) => wallet.id == id);
    } catch (_) {
      return _wallets.isEmpty ? null : _wallets.first;
    }
  }

  Future<void> loadWallets() async {
    final rows = await _database.getAll('wallets', orderBy: 'id ASC');
    _wallets = rows.map(WalletModel.fromMap).toList();
    notifyListeners();
  }

  Future<void> addWallet(WalletModel wallet) async {
    await _database.insert('wallets', wallet.toMap());
    await loadWallets();
  }

  Future<void> updateWallet(WalletModel wallet) async {
    if (wallet.id == null) return;
    await _database.update('wallets', wallet.toMap(), wallet.id!);
    await loadWallets();
  }

  Future<void> deleteWallet(int id) async {
    await _database.delete('wallets', id);
    await loadWallets();
  }

  Future<void> transfer({
    required WalletModel from,
    required WalletModel to,
    required double amount,
  }) async {
    if (from.id == null || to.id == null || amount <= 0) return;
    await updateWallet(from.copyWith(balance: from.balance - amount));
    await updateWallet(to.copyWith(balance: to.balance + amount));
  }

  double walletBalance(int walletId, List<TransactionModel> transactions) {
    final wallet = byId(walletId);
    final initial = wallet?.balance ?? 0;
    return transactions
        .where((item) => item.walletId == walletId)
        .fold(
          initial,
          (sum, item) => item.isIncome ? sum + item.amount : sum - item.amount,
        );
  }
}
