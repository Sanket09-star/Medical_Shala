import 'package:flutter/material.dart';

// Use 'sealed class' if on Dart 3.0+, otherwise use 'abstract class'
sealed class AppColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color secondary = Color(0xFF42A5F5);
  static const Color accent = Color(0xFFFFC107);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color border = Color(0xFFE0E0E0);

  // Grouped example (optional)
  static const NavBar navBar = NavBar();
}

class NavBar {
  const NavBar();
  Color get selected => AppColors.primary;
  Color get unselected => Colors.black;
  Color get background => Colors.white;
} 