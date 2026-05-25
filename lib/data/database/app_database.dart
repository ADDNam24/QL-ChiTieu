import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_colors.dart';
import '../../models/transaction_model.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'expense_manager.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await _createTransactionsTable(db);
        await _createSettingsTable(db);
        await _createPremiumTables(db);
        await _seedDefaults(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createSettingsTable(db);
        }
        if (oldVersion < 3) {
          await _safeAlter(
            db,
            'ALTER TABLE transactions ADD COLUMN wallet_id INTEGER NOT NULL DEFAULT 1',
          );
          await _createPremiumTables(db);
          await _seedDefaults(db);
        }
      },
      onOpen: (db) async {
        await _seedDefaults(db);
      },
    );
  }

  Future<void> _createTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        wallet_id INTEGER NOT NULL DEFAULT 1,
        date TEXT NOT NULL,
        note TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createPremiumTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS wallets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        balance REAL NOT NULL,
        icon_code_point INTEGER NOT NULL,
        color_value INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon_code_point INTEGER NOT NULL,
        color_value INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month_key TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS saving_goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL,
        due_date TEXT NOT NULL,
        note TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS recurring_transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        wallet_id INTEGER NOT NULL,
        cycle TEXT NOT NULL,
        next_run_date TEXT NOT NULL,
        note TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reminders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        time_text TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _safeAlter(Database db, String sql) async {
    try {
      await db.execute(sql);
    } on DatabaseException {
      // Column already exists on some development databases.
    }
  }

  Future<void> _seedDefaults(Database db) async {
    final now = DateTime.now().toIso8601String();
    final walletCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM wallets'),
    );
    if ((walletCount ?? 0) == 0) {
      final wallets = [
        [
          'Ví tiền mặt',
          'cash',
          0.0,
          Icons.payments_outlined.codePoint,
          AppColors.primary.toARGB32(),
        ],
        [
          'Ví ngân hàng',
          'bank',
          0.0,
          Icons.account_balance_outlined.codePoint,
          AppColors.income.toARGB32(),
        ],
        [
          'Ví tiết kiệm',
          'saving',
          0.0,
          Icons.savings_outlined.codePoint,
          AppColors.warning.toARGB32(),
        ],
        [
          'Ví khác',
          'other',
          0.0,
          Icons.account_balance_wallet_outlined.codePoint,
          AppColors.primaryDark.toARGB32(),
        ],
      ];
      for (final wallet in wallets) {
        await db.insert('wallets', {
          'name': wallet[0],
          'type': wallet[1],
          'balance': wallet[2],
          'icon_code_point': wallet[3],
          'color_value': wallet[4],
          'created_at': now,
        });
      }
    }

    final categoryCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM categories'),
    );
    if ((categoryCount ?? 0) == 0) {
      final categories = [
        [
          'Ăn uống',
          'expense',
          Icons.restaurant_outlined.codePoint,
          AppColors.expense.toARGB32(),
        ],
        [
          'Di chuyển',
          'expense',
          Icons.directions_bus_outlined.codePoint,
          0xFF7E57C2,
        ],
        [
          'Mua sắm',
          'expense',
          Icons.shopping_bag_outlined.codePoint,
          0xFFFF7043,
        ],
        ['Học tập', 'expense', Icons.school_outlined.codePoint, 0xFF42A5F5],
        [
          'Giải trí',
          'expense',
          Icons.movie_outlined.codePoint,
          AppColors.warning.toARGB32(),
        ],
        [
          'Sức khỏe',
          'expense',
          Icons.health_and_safety_outlined.codePoint,
          0xFF26A69A,
        ],
        [
          'Khác',
          'expense',
          Icons.more_horiz.codePoint,
          AppColors.textSecondary.toARGB32(),
        ],
        [
          'Lương',
          'income',
          Icons.payments_outlined.codePoint,
          AppColors.income.toARGB32(),
        ],
        [
          'Thưởng',
          'income',
          Icons.card_giftcard_outlined.codePoint,
          0xFF26A69A,
        ],
        [
          'Khác',
          'income',
          Icons.add_circle_outline.codePoint,
          AppColors.textSecondary.toARGB32(),
        ],
      ];
      for (final category in categories) {
        await db.insert('categories', {
          'name': category[0],
          'type': category[1],
          'icon_code_point': category[2],
          'color_value': category[3],
          'created_at': now,
        });
      }
    }

    final reminderCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM reminders'),
    );
    if ((reminderCount ?? 0) == 0) {
      for (final reminder in [
        ['Nhập chi tiêu cuối ngày', 'daily_expense', '21:00'],
        ['Kiểm tra ngân sách', 'budget_check', '08:30'],
      ]) {
        await db.insert('reminders', {
          'title': reminder[0],
          'type': reminder[1],
          'time_text': reminder[2],
          'is_active': 1,
          'created_at': now,
        });
      }
    }
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return db.insert('transactions', transaction.toMap());
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC, id DESC');
    return maps.map(TransactionModel.fromMap).toList();
  }

  Future<TransactionModel?> getTransactionById(int id) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return TransactionModel.fromMap(maps.first);
  }

  Future<List<Map<String, dynamic>>> getAll(
    String table, {
    String? orderBy,
  }) async {
    final db = await database;
    return db.query(table, orderBy: orderBy ?? 'id DESC');
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return db.insert(table, values);
  }

  Future<int> update(String table, Map<String, dynamic> values, int id) async {
    final db = await database;
    return db.update(table, values, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query(
      'settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
