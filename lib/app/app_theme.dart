import 'package:flutter/material.dart';

/// PRD §10.2：设计 Token（主题层集中，避免各页魔法数）。
abstract final class ChongbanTokens {
  static const Color primary = Color(0xFF5F7A74);
  static const Color background = Color(0xFFF5F5F7);
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6C6C70);
  static const Color divider = Color(0xFFE5E5EA);

  static const double radiusCard = 22;
  static const double radiusSecondary = 16;
  static const double radiusButton = 14;

  static const double spacePage = 20;
  static const double spaceCard = 12;
}

ThemeData buildChongbanTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: ChongbanTokens.primary,
      brightness: Brightness.light,
      surface: ChongbanTokens.background,
    ),
    useMaterial3: true,
  );

  return base.copyWith(
    scaffoldBackgroundColor: ChongbanTokens.background,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: ChongbanTokens.background,
      foregroundColor: ChongbanTokens.textPrimary,
    ),
    cardTheme: CardThemeData(
      color: ChongbanTokens.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ChongbanTokens.radiusCard),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ChongbanTokens.card,
      indicatorColor: ChongbanTokens.primary.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ChongbanTokens.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ChongbanTokens.radiusSecondary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ChongbanTokens.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ChongbanTokens.radiusButton),
        ),
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: ChongbanTokens.textPrimary,
      displayColor: ChongbanTokens.textPrimary,
    ).copyWith(
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: ChongbanTokens.textPrimary,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: ChongbanTokens.textSecondary,
      ),
    ),
  );
}
