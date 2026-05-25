import 'package:flutter/foundation.dart';

import '../data/database/app_database.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;
  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> byType(String type) =>
      _categories.where((item) => item.type == type).toList();

  Future<void> loadCategories() async {
    final rows = await _database.getAll(
      'categories',
      orderBy: 'type ASC, id ASC',
    );
    _categories = rows.map(CategoryModel.fromMap).toList();
    notifyListeners();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _database.insert('categories', category.toMap());
    await loadCategories();
  }

  Future<void> updateCategory(CategoryModel category) async {
    if (category.id == null) return;
    await _database.update('categories', category.toMap(), category.id!);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _database.delete('categories', id);
    await loadCategories();
  }
}
