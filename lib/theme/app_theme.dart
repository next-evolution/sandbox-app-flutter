import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0D0D0D);
  static const surface = Color(0xFF1A1A1A);
  static const surfaceVariant = Color(0xFF242424);
  static const border = Color(0xFF2E2E2E);
  static const primary = Color(0xFF6C63FF);
  static const textPrimary = Color(0xFFE8E8E8);
  static const textSecondary = Color(0xFF888888);
  static const error = Color(0xFFFF4444);
  static const success = Color(0xFF44CC88);

  static const fxBuy = Color(0xFF4FC3F7);
  static const fxSell = Color(0xFFFF7043);
  static const fxBuyLg = Color(0xFF29B6F6);
  static const fxSellLg = Color(0xFFEF5350);
  static const simRed = Color(0xFFD32F2F);
  static const simTeal = Color(0xFF00695C);
  static const simAqua = Color(0xFF00838F);
  static const simBlue1 = Color(0xFF1565C0);
  static const simBlue2 = Color(0xFF0D47A1);
  static const simBlue3 = Color(0xFF01579B);

  static const importanceHighBg = Color(0xFF221A00);
  static const zzBgUp = Color(0xFF08142A);
  static const zzBgDw = Color(0xFF1E0808);
  static const zzSmaUp = Color(0xFF1565C0);
  static const zzSmaUpS = Color(0xFF42A5F5);
  static const zzSmaDw = Color(0xFFB71C1C);
  static const zzSmaDwS = Color(0xFFEF9A9A);
  static const zzSmaFlat = Color(0xFF555555);
  static const cellResistance = Color(0xFFB71C1C);
  static const cellSupport = Color(0xFF1565C0);
}

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
    ),
  );
}
