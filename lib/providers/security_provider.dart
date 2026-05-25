import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityProvider extends ChangeNotifier {
  static const _enabledKey = 'pin_enabled';
  static const _pinKey = 'pin_code';

  bool _isPinEnabled = false;
  String? _pin;
  bool _isUnlocked = false;

  bool get isPinEnabled => _isPinEnabled;
  bool get hasPin => _pin != null && _pin!.isNotEmpty;
  bool get needsUnlock => _isPinEnabled && !_isUnlocked;

  Future<void> loadSecurity() async {
    final prefs = await SharedPreferences.getInstance();
    _isPinEnabled = prefs.getBool(_enabledKey) ?? false;
    _pin = prefs.getString(_pinKey);
    notifyListeners();
  }

  Future<bool> setPin(String pin) async {
    final trimmedPin = pin.trim();
    if (trimmedPin.length != 4 || int.tryParse(trimmedPin) == null) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, trimmedPin);
    await prefs.setBool(_enabledKey, true);
    _pin = trimmedPin;
    _isPinEnabled = true;
    notifyListeners();
    return true;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    _isPinEnabled = enabled;
    notifyListeners();
  }

  bool verifyPin(String pin) {
    if (!_isPinEnabled) {
      return true;
    }
    final ok = pin.trim() == _pin;
    if (ok) {
      _isUnlocked = true;
      notifyListeners();
    }
    return ok;
  }

  void lock() {
    _isUnlocked = false;
    notifyListeners();
  }
}
