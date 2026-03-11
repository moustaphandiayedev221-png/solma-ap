import 'package:flutter/material.dart';

/// Police principale : Inter (bundle locale) — pas de téléchargement réseau.
TextStyle _font(double size, FontWeight weight, [Color? color]) =>
    TextStyle(
      fontFamily: 'Inter',
      fontSize: size,
      fontWeight: weight,
      color: color,
    );

/// Thème premium — fond clair, boutons noirs, typographie Inter
class AppTheme {
  AppTheme._();

  /// Retourne un [TextStyle] avec Inter (pour styles personnalisés).
  static TextStyle textStyle(double size, FontWeight weight, [Color? color]) =>
      _font(size, weight, color);

  static const Color _primary = Color(0xFF000000);
  static const Color _surface = Color(0xFFFAFAFA);
  static const Color _surfaceVariant = Color(0xFFF5F5F5);
  static const Color _scaffoldBackground = Color(0xFFF5F5F0);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF1A1A1A);
  static const Color _onSurfaceVariant = Color(0xFF757575);
  static const Color _outline = Color(0xFFE0E0E0);
  static const Color _error = Color(0xFFB00020);

  static ThemeData get light {
    final base = Typography.material2021().black;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primary,
        onPrimary: _onPrimary,
        surface: _surface,
        onSurface: _onSurface,
        surfaceContainerHighest: _surfaceVariant,
        onSurfaceVariant: _onSurfaceVariant,
        outline: _outline,
        error: _error,
        onError: _onPrimary,
      ),
      scaffoldBackgroundColor: _scaffoldBackground,
      fontFamily: 'Inter',
      textTheme: _textTheme(base, _onSurface, _onSurfaceVariant),
      appBarTheme: AppBarTheme(
        backgroundColor: _scaffoldBackground,
        foregroundColor: _onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _font(18, FontWeight.w600, _onSurface),
        leadingWidth: 48,
        iconTheme: const IconThemeData(size: 28),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: _font(16, FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: _font(16, FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _onSurface,
          side: const BorderSide(color: _outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.06),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: _font(14, FontWeight.w400, _onSurfaceVariant),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _primary,
        selectedItemColor: _onPrimary,
        unselectedItemColor: const Color(0xFFB0B0B0),
        selectedLabelStyle: _font(12, FontWeight.w600, _onPrimary),
        unselectedLabelStyle: _font(12, FontWeight.w500, const Color(0xFFB0B0B0)),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerColor: _outline,
    );
  }

  static ThemeData get dark {
    const Color dSurface = Color(0xFF121212);
    const Color dSurfaceVariant = Color(0xFF1E1E1E);
    const Color dOnSurface = Color(0xFFF5F5F5);
    const Color dOnSurfaceVariant = Color(0xFFB0B0B0);
    const Color dOutline = Color(0xFF2C2C2C);

    final base = Typography.material2021().white;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _onPrimary,
        onPrimary: _primary,
        surface: dSurface,
        onSurface: dOnSurface,
        surfaceContainerHighest: dSurfaceVariant,
        onSurfaceVariant: dOnSurfaceVariant,
        outline: dOutline,
        error: _error,
        onError: _onPrimary,
      ),
      scaffoldBackgroundColor: dSurface,
      fontFamily: 'Inter',
      textTheme: _textTheme(base, dOnSurface, dOnSurfaceVariant),
      appBarTheme: AppBarTheme(
        backgroundColor: dSurface,
        foregroundColor: dOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _font(18, FontWeight.w600, dOnSurface),
        leadingWidth: 48,
        iconTheme: const IconThemeData(size: 28),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _onPrimary,
          foregroundColor: _primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: _font(16, FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: _font(16, FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: dSurfaceVariant,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.3),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dSurfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _onPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: _font(14, FontWeight.w400, dOnSurfaceVariant),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: dSurfaceVariant,
        selectedItemColor: _onPrimary,
        unselectedItemColor: dOnSurfaceVariant,
        selectedLabelStyle: _font(12, FontWeight.w600, _onPrimary),
        unselectedLabelStyle: _font(12, FontWeight.w500, dOnSurfaceVariant),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerColor: dOutline,
    );
  }

  static TextTheme _textTheme(
    TextTheme base,
    Color onSurface,
    Color onSurfaceVariant,
  ) {
    return TextTheme(
      displayLarge: _font(57, FontWeight.w700, onSurface).merge(base.displayLarge),
      displayMedium: _font(45, FontWeight.w700, onSurface).merge(base.displayMedium),
      displaySmall: _font(36, FontWeight.w600, onSurface).merge(base.displaySmall),
      headlineLarge: _font(32, FontWeight.w600, onSurface).merge(base.headlineLarge),
      headlineMedium: _font(28, FontWeight.w600, onSurface).merge(base.headlineMedium),
      headlineSmall: _font(24, FontWeight.w600, onSurface).merge(base.headlineSmall),
      titleLarge: _font(22, FontWeight.w600, onSurface).merge(base.titleLarge),
      titleMedium: _font(16, FontWeight.w600, onSurface).merge(base.titleMedium),
      titleSmall: _font(14, FontWeight.w600, onSurface).merge(base.titleSmall),
      bodyLarge: _font(16, FontWeight.w400, onSurface).merge(base.bodyLarge),
      bodyMedium: _font(14, FontWeight.w400, onSurface).merge(base.bodyMedium),
      bodySmall: _font(12, FontWeight.w400, onSurfaceVariant).merge(base.bodySmall),
      labelLarge: _font(14, FontWeight.w500, onSurface).merge(base.labelLarge),
      labelMedium: _font(12, FontWeight.w500, onSurfaceVariant).merge(base.labelMedium),
      labelSmall: _font(11, FontWeight.w500, onSurfaceVariant).merge(base.labelSmall),
    );
  }
}
