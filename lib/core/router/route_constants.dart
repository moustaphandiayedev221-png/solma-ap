/// Constantes centralisées pour la navigation — architecture feature-first.
///
/// Usage:
/// ```dart
/// context.push(AppPaths.product(productId));
/// context.go(AppPaths.main);
/// ```
library;

/// Chemins et helpers pour le routing — deep linking compatible.
abstract final class AppPaths {
  AppPaths._();

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGES PRINCIPALES (e-commerce)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Home / Accueil
  static const String home = '/main';

  /// Liste des produits par section (popular, sports, new, etc.)
  static String productList(String section) => '/products/section/$section';

  /// Liste des produits par catégorie (men, women, etc.)
  static String productCategory(String slug) => '/products/category/$slug';

  /// Détail d'un produit — supporte deep link: /product/{id}
  static String product(String id) => '/product/$id';

  /// Panier
  static const String cart = '/main'; // Tab du panier dans main
  static const String checkout = '/checkout';

  /// Profil / Compte
  static const String profile = '/main'; // Tab profil dans main

  /// Historique des commandes
  static const String orderHistory = '/orders';

  /// Liste de souhaits
  static const String wishlist = '/wishlist';

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH & ONBOARDING
  // ═══════════════════════════════════════════════════════════════════════════

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFIL & PARAMÈTRES
  // ═══════════════════════════════════════════════════════════════════════════

  static const String addresses = '/addresses';
  static String addressEdit(String id) => '/addresses/edit/$id';
  static const String addressNew = '/addresses/new';
  static const String editProfile = '/profile/edit';
  static const String paymentMethods = '/payment-methods';
  static const String notifications = '/notifications';
  static const String faq = '/faq';
  static const String helpCenter = '/help-center';
  static const String chatAssistant = '/help-center/chat';
  static const String privacyPolicy = '/privacy-policy';
  static const String privacySecurity = '/privacy-security';
  static const String currency = '/currency';
  static const String publicites = '/publicites';
}
