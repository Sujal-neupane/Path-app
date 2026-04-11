import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Access theme data throughout the app using Riverpod
final appThemeProvider = Provider<AppTheme>((ref) {
  // Can be extended to watch a dynamic theme mode (light/dark)
  return AppTheme(isDark: true);
});

class AppTheme {
  final bool isDark;
  final AppColors colors;

  AppTheme({required this.isDark}) : colors = AppColors(isDark);

  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: colors.primary,
        onPrimary: Colors.white,
        secondary: colors.accent,
        surface: colors.surface,
        error: colors.error,
      ),
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h2.copyWith(color: colors.textPrimary),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTextStyles.button,
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),
    );
  }


  TextTheme get _textTheme {
    return TextTheme(
      displayLarge: AppTextStyles.h1.copyWith(color: colors.textPrimary),
      displayMedium: AppTextStyles.h2.copyWith(color: colors.textPrimary),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: colors.textPrimary),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
      labelLarge: AppTextStyles.button.copyWith(color: colors.textPrimary),
    );
  }
}
