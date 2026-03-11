import 'package:flutter/material.dart';

/// Couleurs sémantiques de l'application. À utiliser plutôt que des literaux.
/// Cohérent avec [AppTheme] (primary = noir, onPrimary = blanc).
class AppColors {
  AppColors._();

  // --- Thème global (aligné AppTheme) ---
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color outline = Color(0xFFE0E0E0);
  static const Color error = Color(0xFFB00020);

  /// Fond unifié de toutes les pages (aligné sur le thème scaffold).
  static const Color scaffoldBackground = Color(0xFFF5F5F0);

  /// Plan blanc avec bordure pour affichage 3D produit.
  static const Color productDetailPlaneFill = Color(0xFFFFFFFF);
  static const Color productDetailPlaneBorder = Color(0xFF000000);

  /// Ombre légère (alpha 6%).
  static Color shadowLight(BuildContext context) =>
      Colors.black.withValues(alpha: 0.06);
  static Color shadowMedium(BuildContext context) =>
      Colors.black.withValues(alpha: 0.12);
}
