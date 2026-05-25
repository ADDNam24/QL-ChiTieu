import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app_routes.dart';
import 'app/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'providers/auth_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/category_provider.dart';
import 'providers/recurring_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/security_provider.dart';
import 'providers/saving_goal_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/wallet_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadAuthState()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(
          create: (_) => SecurityProvider()..loadSecurity(),
        ),
        ChangeNotifierProvider(create: (_) => WalletProvider()..loadWallets()),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider()..loadCategories(),
        ),
        ChangeNotifierProvider(create: (_) => BudgetProvider()..loadBudgets()),
        ChangeNotifierProvider(
          create: (_) => SavingGoalProvider()..loadGoals(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReminderProvider()..loadReminders(),
        ),
        ChangeNotifierProvider(
          create: (_) => RecurringProvider()..loadRecurring(),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider()..loadTransactions(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.themeMode,
          routes: AppRoutes.routes,
          home: const AuthGate(),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final security = context.watch<SecurityProvider>();
    if (!auth.isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!auth.isLoggedIn) return const LoginScreen();
    if (security.needsUnlock) return const PinUnlockScreen();
    return const MainScreen();
  }
}

class PinUnlockScreen extends StatefulWidget {
  const PinUnlockScreen({super.key});

  @override
  State<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends State<PinUnlockScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 34,
                child: Icon(Icons.pin_outlined, size: 32),
              ),
              const SizedBox(height: 18),
              Text(
                'Nhập mã PIN',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(labelText: 'PIN 4 số'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  final ok = context.read<SecurityProvider>().verifyPin(
                    _controller.text,
                  );
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN không đúng')),
                    );
                  }
                },
                child: const Text('Mở khóa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
