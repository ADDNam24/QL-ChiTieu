import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFD81B8C);
  static const primaryDark = Color(0xFF8E24AA);
  static const secondary = Color(0xFFFF6FB1);
  static const background = Color(0xFFFFF7FC);
  static const surface = Color(0xFFFFFFFF);
  static const inputFill = Color(0xFFF8ECF5);
  static const textPrimary = Color(0xFF241323);
  static const textSecondary = Color(0xFF6E5369);
  static const textMuted = Color(0xFF9C8196);
  static const income = Color(0xFF0EA66B);
  static const expense = Color(0xFFE5395F);
  static const warning = Color(0xFFFFA726);
  static const divider = Color(0xFFF0DCEB);

  static const gradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
