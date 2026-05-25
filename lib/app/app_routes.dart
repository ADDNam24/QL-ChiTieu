import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/main/main_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const main = '/main';

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    main: (_) => const MainScreen(),
  };
}
