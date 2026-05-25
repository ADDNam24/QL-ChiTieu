import '../../models/transaction_model.dart';
import '../database/app_database.dart';

class TransactionRepository {
  TransactionRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> insertTransaction(TransactionModel transaction) {
    return _database.insertTransaction(transaction);
  }

  Future<int> updateTransaction(TransactionModel transaction) {
    return _database.updateTransaction(transaction);
  }

  Future<int> deleteTransaction(int id) {
    return _database.deleteTransaction(id);
  }

  Future<List<TransactionModel>> getAllTransactions() {
    return _database.getAllTransactions();
  }

  Future<TransactionModel?> getTransactionById(int id) {
    return _database.getTransactionById(id);
  }
}
