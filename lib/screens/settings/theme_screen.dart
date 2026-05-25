import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/widgets/premium_card.dart';
import '../../providers/theme_provider.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Giao diện')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.padding),
        children: [
          PremiumCard(
            child: Column(
              children: [
                _ThemeTile(
                  title: 'Theo hệ thống',
                  icon: Icons.settings_suggest_outlined,
                  selected: provider.themeMode == ThemeMode.system,
                  onTap: () => provider.setThemeMode(ThemeMode.system),
                ),
                _ThemeTile(
                  title: 'Sáng',
                  icon: Icons.light_mode_outlined,
                  selected: provider.themeMode == ThemeMode.light,
                  onTap: () => provider.setThemeMode(ThemeMode.light),
                ),
                _ThemeTile(
                  title: 'Tối',
                  icon: Icons.dark_mode_outlined,
                  selected: provider.themeMode == ThemeMode.dark,
                  onTap: () => provider.setThemeMode(ThemeMode.dark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: selected ? const Icon(Icons.check_circle) : null,
      onTap: onTap,
    );
  }
}
