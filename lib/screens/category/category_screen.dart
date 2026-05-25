import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/premium_card.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Danh mục')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.padding),
        children: [
          CustomButton(
            label: 'Thêm danh mục',
            icon: Icons.add,
            onPressed: () => _showDialog(context),
          ),
          const SizedBox(height: 16),
          ...provider.categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PremiumCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: category.color.withValues(alpha: 0.14),
                    child: Icon(category.icon, color: category.color),
                  ),
                  title: Text(category.name),
                  subtitle: Text(category.type == 'income' ? 'Thu' : 'Chi'),
                  onTap: () => _showDialog(context, category: category),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: category.id == null
                        ? null
                        : () => provider.deleteCategory(category.id!),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, {CategoryModel? category}) {
    final controller = TextEditingController(text: category?.name ?? '');
    var type = category?.type ?? 'expense';
    var color = category?.color ?? AppColors.primary;
    var icon = category?.icon ?? Icons.category_outlined;
    final colors = [
      AppColors.primary,
      AppColors.expense,
      AppColors.income,
      AppColors.warning,
      const Color(0xFF42A5F5),
    ];
    final icons = [
      Icons.restaurant_outlined,
      Icons.directions_bus_outlined,
      Icons.shopping_bag_outlined,
      Icons.school_outlined,
      Icons.savings_outlined,
      Icons.more_horiz,
    ];

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(category == null ? 'Thêm danh mục' : 'Sửa danh mục'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'Tên danh mục'),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  selected: {type},
                  segments: const [
                    ButtonSegment(value: 'expense', label: Text('Chi')),
                    ButtonSegment(value: 'income', label: Text('Thu')),
                  ],
                  onSelectionChanged: (value) =>
                      setState(() => type = value.first),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: colors
                      .map(
                        (item) => ChoiceChip(
                          label: const Text(''),
                          selected: color == item,
                          avatar: CircleAvatar(backgroundColor: item),
                          onSelected: (_) => setState(() => color = item),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: icons
                      .map(
                        (item) => ChoiceChip(
                          label: Icon(item),
                          selected: icon == item,
                          onSelected: (_) => setState(() => icon = item),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                final model = CategoryModel(
                  id: category?.id,
                  name: name,
                  icon: icon,
                  color: color,
                  type: type,
                );
                final provider = context.read<CategoryProvider>();
                category == null
                    ? await provider.addCategory(model)
                    : await provider.updateCategory(model);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
