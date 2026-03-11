/// Constantes propres à l'écran détail produit (dimensions, durées, valeurs par défaut).
class ProductDetailConstants {
  ProductDetailConstants._();

  // --- Images par défaut (fallback si produit sans images) ---
  static const List<String> defaultImageUrls = [
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=80',
    'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600&q=80',
    'https://images.unsplash.com/photo-1597045566677-8cf032ed6634?w=600&q=80',
  ];

  // --- Tailles par défaut ---
  static const List<String> defaultSizes = ['34', '38', '42', '46'];

  // --- Description par défaut ---
  static const String defaultDescription =
      "Where heritage meets modern comfort. The Nike Men's Jordan Air 4 Retro "
      "delivers legendary style, responsive Air cushioning, and durable "
      "construction crafted for those who live the game on and off the court.";

  // --- Dimensions ---
  static const double horizontalPadding = 24.0;
  static const double horizontalPaddingTight = 20.0;
  static const double imageCarouselHeight = 340.0;
  /// Hauteur de l'image produit.
  static const double imageHeight = 320.0;
  static const double planeHeight = 200.0;
  static const double planeBorderRadius = 160.0;
  static const double viewModeButtonSize = 48.0;
  static const double thumbnailWidth = 64.0;
  static const double thumbnailHeight = 48.0;
  static const double sizeButtonHorizontalPadding = 20.0;
  static const double sizeButtonVerticalPadding = 14.0;
  static const double bottomBarButtonHeight = 56.0;
  static const double bottomBarVerticalPadding = 14.0;
  static const double bottomBarHorizontalPadding = 24.0;
  static const int carouselIndicatorMaxDots = 8;

  // --- Animations ---
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 350);
}
