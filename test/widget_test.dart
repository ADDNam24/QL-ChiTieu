import 'package:expense_manager_app/providers/auth_provider.dart';
import 'package:expense_manager_app/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App shows first-time password setup screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Tạo mật khẩu'), findsOneWidget);
    expect(find.text('Tạo và vào app'), findsOneWidget);
  });
}
