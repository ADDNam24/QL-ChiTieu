import 'package:flutter/foundation.dart';

import '../data/database/app_database.dart';
import '../models/reminder_model.dart';

class ReminderProvider extends ChangeNotifier {
  ReminderProvider({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;
  List<ReminderModel> _reminders = [];

  List<ReminderModel> get reminders => _reminders;

  Future<void> loadReminders() async {
    final rows = await _database.getAll('reminders', orderBy: 'id DESC');
    _reminders = rows.map(ReminderModel.fromMap).toList();
    notifyListeners();
  }

  Future<void> addReminder(ReminderModel reminder) async {
    await _database.insert('reminders', reminder.toMap());
    await loadReminders();
  }

  Future<void> deleteReminder(int id) async {
    await _database.delete('reminders', id);
    await loadReminders();
  }
}
