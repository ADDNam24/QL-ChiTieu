import 'package:flutter/foundation.dart';

import '../data/database/app_database.dart';
import '../models/saving_goal_model.dart';

class SavingGoalProvider extends ChangeNotifier {
  SavingGoalProvider({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;
  List<SavingGoalModel> _goals = [];

  List<SavingGoalModel> get goals => _goals;
  int get goalCount => _goals.length;

  Future<void> loadGoals() async {
    final rows = await _database.getAll('saving_goals', orderBy: 'id DESC');
    _goals = rows.map(SavingGoalModel.fromMap).toList();
    notifyListeners();
  }

  Future<void> addGoal(SavingGoalModel goal) async {
    await _database.insert('saving_goals', goal.toMap());
    await loadGoals();
  }

  Future<void> addMoney(SavingGoalModel goal, double amount) async {
    if (goal.id == null || amount <= 0) return;
    await _database.update(
      'saving_goals',
      goal.copyWith(currentAmount: goal.currentAmount + amount).toMap(),
      goal.id!,
    );
    await loadGoals();
  }

  Future<void> deleteGoal(int id) async {
    await _database.delete('saving_goals', id);
    await loadGoals();
  }
}
