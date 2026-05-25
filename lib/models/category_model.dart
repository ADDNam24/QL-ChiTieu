import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class CategoryModel {
  const CategoryModel({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  final int? id;
  final String name;
  final IconData icon;
  final Color color;
  final String type;

  int get iconCodePoint => icon.codePoint;
  int get colorValue => color.toARGB32();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'icon_code_point': iconCodePoint,
    'color_value': colorValue,
    'created_at': DateTime.now().toIso8601String(),
  };

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      icon: IconData(
        map['icon_code_point'] as int,
        fontFamily: 'MaterialIcons',
      ),
      color: Color(map['color_value'] as int),
    );
  }

  static const incomeCategories = [
    CategoryModel(
      name: 'Lương',
      icon: Icons.payments_outlined,
      color: AppColors.income,
      type: 'income',
    ),
    CategoryModel(
      name: 'Thưởng',
      icon: Icons.card_giftcard_outlined,
      color: Color(0xFF26A69A),
      type: 'income',
    ),
    CategoryModel(
      name: 'Đầu tư',
      icon: Icons.trending_up,
      color: Color(0xFF43A047),
      type: 'income',
    ),
    CategoryModel(
      name: 'Khác',
      icon: Icons.add_circle_outline,
      color: AppColors.textSecondary,
      type: 'income',
    ),
  ];

  static const expenseCategories = [
    CategoryModel(
      name: 'Ăn uống',
      icon: Icons.restaurant_outlined,
      color: AppColors.expense,
      type: 'expense',
    ),
    CategoryModel(
      name: 'Di chuyển',
      icon: Icons.directions_bus_outlined,
      color: Color(0xFF7E57C2),
      type: 'expense',
    ),
    CategoryModel(
      name: 'Mua sắm',
      icon: Icons.shopping_bag_outlined,
      color: Color(0xFFFF7043),
      type: 'expense',
    ),
    CategoryModel(
      name: 'Hóa đơn',
      icon: Icons.receipt_long_outlined,
      color: Color(0xFF42A5F5),
      type: 'expense',
    ),
    CategoryModel(
      name: 'Giải trí',
      icon: Icons.movie_outlined,
      color: Color(0xFFFFB300),
      type: 'expense',
    ),
    CategoryModel(
      name: 'Khác',
      icon: Icons.more_horiz,
      color: AppColors.textSecondary,
      type: 'expense',
    ),
  ];

  static List<CategoryModel> byType(String type) {
    return type == 'income' ? incomeCategories : expenseCategories;
  }

  static CategoryModel find(String name, String type) {
    return byType(type).firstWhere(
      (category) => category.name == name,
      orElse: () => byType(type).last,
    );
  }
}
