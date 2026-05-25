import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/recurring_provider.dart';
import '../../providers/transaction_provider.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../statistics/statistics_screen.dart';
import '../transaction/transaction_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _processedRecurring = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_processedRecurring) return;
    _processedRecurring = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RecurringProvider>().processDueTransactions(
        context.read<TransactionProvider>(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onTabSelected: _selectTab),
      const TransactionListScreen(),
      const StatisticsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _selectTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Giao dịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_rounded),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
  }
}
