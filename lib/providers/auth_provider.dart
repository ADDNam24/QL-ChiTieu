import 'package:flutter/foundation.dart';

import '../core/constants/app_strings.dart';
import '../data/database/app_database.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  static const _passwordKey = 'app_password';
  static const _userNameKey = 'user_name';

  final AppDatabase _database;

  bool _isReady = false;
  bool _isLoggedIn = false;
  String? _savedPassword;
  String _name = AppStrings.userFallback;

  bool get isReady => _isReady;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasPassword => _savedPassword != null && _savedPassword!.isNotEmpty;
  String get name => _name;

  Future<void> loadAuthState() async {
    _savedPassword = await _database.getSetting(_passwordKey);
    _name = await _database.getSetting(_userNameKey) ?? AppStrings.userFallback;
    _isReady = true;
    notifyListeners();
  }

  Future<bool> setupPassword(String password) async {
    final trimmedPassword = password.trim();
    if (trimmedPassword.isEmpty) return false;

    await _database.setSetting(_passwordKey, trimmedPassword);
    await _database.setSetting(_userNameKey, _name);
    _savedPassword = trimmedPassword;
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  bool login(String password) {
    if (!hasPassword) return false;
    if (password.trim() != _savedPassword) return false;

    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  Future<void> updateName(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;
    _name = trimmedName;
    await _database.setSetting(_userNameKey, trimmedName);
    notifyListeners();
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final trimmedCurrentPassword = currentPassword.trim();
    final trimmedNewPassword = newPassword.trim();

    if (!hasPassword || trimmedCurrentPassword != _savedPassword) return false;
    if (trimmedNewPassword.length < 4) return false;

    await _database.setSetting(_passwordKey, trimmedNewPassword);
    _savedPassword = trimmedNewPassword;
    notifyListeners();
    return true;
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
