import 'package:flutter/material.dart';

class AppColors {
  static const brandBrown = Color(0xFFB27452);
  static const pageBackground = Color(0xFFF7F3EE);
  static const textColor = Color(0xFF4A3426);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.pageBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandBrown,
        brightness: Brightness.light,
      ),
      textTheme: ThemeData.light().textTheme.apply(
            bodyColor: AppColors.textColor,
            displayColor: AppColors.textColor,
          ),
    );
  }
}

