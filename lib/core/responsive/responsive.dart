import 'package:flutter/material.dart';

/// Breakpoints type Material / grandes apps.
/// compactSmall : petits téléphones (iPhone SE 320, iPhone X 375, etc.)
class Breakpoint {
  Breakpoint._();
  /// < 380 : petit téléphone (iPhone SE, 8, X en largeur)
  static const double compactSmall = 380;
  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 840;
  static const double maxContentWidth = 1200;
  static const double maxReadingWidth = 720;
}

/// Valeurs responsive dérivées de la largeur d'écran.
class ResponsiveValues {
  ResponsiveValues(this.width);
  final double width;

  bool get isCompactSmall => width < Breakpoint.compactSmall;
  bool get isCompact => width < Breakpoint.compact;
  bool get isMedium => width >= Breakpoint.compact && width < Breakpoint.medium;
  bool get isExpanded => width >= Breakpoint.expanded;

  double get horizontalPadding {
    if (isCompactSmall) return 12;
    if (isCompact) return 16;
    if (isMedium) return 24;
    final pad = 32.0 + (width - Breakpoint.expanded) * 0.02;
    final maxPad = width * 0.1;
    return pad.clamp(32, maxPad);
  }

  double get verticalPadding {
    if (isCompactSmall) return 12;
    if (isCompact) return 16;
    if (isMedium) return 20;
    return 24;
  }

  double get gap {
    if (isCompactSmall) return 10;
    if (isCompact) return 12;
    if (isMedium) return 16;
    return 20;
  }

  int get gridCrossAxisCount {
    if (isCompact) return 2;
    if (isMedium) return 3;
    return 4;
  }

  /// Ratio largeur/hauteur des cellules grille. Plus petit = cellules plus hautes.
  double get gridChildAspectRatio => isCompactSmall ? 0.62 : 0.68;

  double get contentWidth =>
      width > Breakpoint.maxContentWidth ? Breakpoint.maxContentWidth : width;

  double get textScale {
    if (isCompactSmall) return 0.9;
    if (isCompact) return 1.0;
    if (isMedium) return 1.05;
    return 1.08;
  }

  /// Largeur d'une ProductCard en affichage 2 par rangée (liste horizontale home).
  double get productCardWidthHorizontal {
    final pad = horizontalPadding * 2;
    final g = gap;
    final maxW = width > Breakpoint.maxContentWidth ? Breakpoint.maxContentWidth : width;
    final available = maxW - pad - g;
    return (available / 2).clamp(130, 200);
  }

  /// Hauteur de la zone image de la ProductCard (proportionnelle à la largeur).
  /// Sur la page Home, cartes plus grandes pour une meilleure visibilité.
  double productCardImageHeight(double cardWidth) {
    final aspect = 170 / 200; // ratio légèrement augmenté pour cartes plus hautes
    return (cardWidth * aspect).clamp(125, 195);
  }

  /// Tailles de police adaptées aux petits écrans.
  double get bodyFontSize => isCompactSmall ? 13 : 14;
  double get titleFontSize => isCompactSmall ? 14 : 16;
  double get headlineFontSize => isCompactSmall ? 18 : 22;
  double get sectionTitleFontSize => isCompactSmall ? 18 : 24;

  double productCardWidth(double horizontalPadding, int crossAxisCount) {
    final pad = horizontalPadding * 2;
    final gaps = (crossAxisCount - 1) * gap;
    final w = width > Breakpoint.maxContentWidth ? Breakpoint.maxContentWidth : width;
    return (w - pad - gaps) / crossAxisCount;
  }
}

extension ResponsiveContext on BuildContext {
  ResponsiveValues get responsive =>
      ResponsiveValues(MediaQuery.sizeOf(this).width);
}
