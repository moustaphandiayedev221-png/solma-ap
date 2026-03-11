import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../gen_l10n/app_localizations.dart';
import 'page_transitions.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/main_navigation/main_navigation_screen.dart';
import '../../features/product/presentation/screens/product_detail_screen.dart';
import '../../features/product/presentation/screens/product_list_screen.dart';
import '../../features/product/presentation/screens/product_list_by_category_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/profile/presentation/screens/order_history_screen.dart';
import '../../features/profile/presentation/screens/wishlist_screen.dart';
import '../../features/profile/presentation/screens/addresses_screen.dart';
import '../../features/profile/presentation/screens/address_form_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/payment_methods_screen.dart';
import '../../features/profile/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/order_detail_route_screen.dart';
import '../../features/profile/presentation/screens/faq_screen.dart';
import '../../features/profile/presentation/screens/help_center_screen.dart';
import '../../features/profile/presentation/screens/privacy_policy_screen.dart';
import '../../features/profile/presentation/screens/privacy_security_screen.dart';
import '../../features/profile/presentation/screens/chat_assistant_screen.dart';
import '../../features/publicites/presentation/screens/publicites_list_screen.dart';
import '../../core/widgets/currency_settings_screen.dart';

/// Routes names (alias pour compatibilité)
class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String main = '/main';
  static const String product = '/product';
  static const String productsSection = '/products/section';
  static const String productsCategory = '/products/category';
  static const String publicites = '/publicites';
  static const String checkout = '/checkout';
  static const String orderHistory = '/orders';
  static const String orderDetail = '/orders/detail';
  static const String wishlist = '/wishlist';
  static const String addresses = '/addresses';
  static const String addressNew = '/addresses/new';
  static const String addressEdit = '/addresses/edit';
  static const String editProfile = '/profile/edit';
  static const String paymentMethods = '/payment-methods';
  static const String notifications = '/notifications';
  static const String faq = '/faq';
  static const String helpCenter = '/help-center';
  static const String chatAssistant = '/help-center/chat';
  static const String privacyPolicy = '/privacy-policy';
  static const String privacySecurity = '/privacy-security';
  static const String currency = '/currency';
}

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>();

const List<String> _protectedPaths = [
  AppRoutes.checkout,
  AppRoutes.orderHistory,
  AppRoutes.orderDetail,
  AppRoutes.wishlist,
  AppRoutes.addresses,
  AppRoutes.editProfile,
  AppRoutes.paymentMethods,
  AppRoutes.notifications,
  AppRoutes.privacySecurity,
  AppRoutes.currency,
];

bool _isProtected(String location) {
  return _protectedPaths.any((p) => location.startsWith(p) || location == p);
}

GoRouter _createGoRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    // Deep linking : go_router parse automatiquement les URLs
    // Ex: https://app.com/product/abc123 -> /product/abc123
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (_isProtected(loc)) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) return AppRoutes.login;
      }
      // /products?category=men -> /products/category/men (évite "Page non trouvée")
      final uri = state.uri;
      if (uri.path == '/products') {
        final cat = uri.queryParameters['category'];
        if (cat != null && cat.isNotEmpty) {
          return '${AppRoutes.productsCategory}/$cat';
        }
      }
      return null;
    },
    routes: [
      // Splash — fade-in léger à l'entrée
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => buildFadeSlideTransition(
          context: context,
          state: state,
          child: const SplashScreen(),
          duration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => buildFadeSlideTransition(
          context: context, state: state,
          child: const OnboardingScreen(),
          duration: const Duration(milliseconds: 500),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => buildFadeSlideTransition(
          context: context, state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        pageBuilder: (context, state) => buildFadeSlideTransition(
          context: context, state: state,
          child: const SignupScreen(),
        ),
      ),
      // Callback OAuth (Google/Apple) — redirige vers main après connexion
      GoRoute(
        path: '/login-callback',
        redirect: (context, state) => AppRoutes.main,
      ),
      GoRoute(
        path: AppRoutes.main,
        name: 'main',
        pageBuilder: (context, state) => buildFadeSlideTransition(
          context: context, state: state,
          child: const MainNavigationScreen(),
          duration: const Duration(milliseconds: 450),
        ),
      ),
      // Produit — slide horizontal (détail)
      GoRoute(
        path: '${AppRoutes.product}/:id',
        name: 'product',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final extra = state.extra;
          final heroSource = extra is Map
              ? (extra['heroSource'] as String?)
              : null;
          final heroTagSuffix = extra is Map
              ? (extra['heroTagSuffix'] as String?)
              : null;
          return buildSlideTransition(
            context: context, state: state,
            child: ProductDetailScreen(
              productId: id,
              heroSource: heroSource ?? 'card',
              heroTagSuffix: heroTagSuffix,
            ),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.productsSection}/:section',
        name: 'productsSection',
        pageBuilder: (context, state) {
          final section = state.pathParameters['section'] ?? 'popular';
          return buildSlideTransition(
            context: context, state: state,
            child: ProductListScreen(section: section),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.productsCategory}/:slug',
        name: 'productsCategory',
        pageBuilder: (context, state) {
          final slug = state.pathParameters['slug'] ?? 'men';
          return buildSlideTransition(
            context: context, state: state,
            child: ProductListByCategoryScreen(categorySlug: slug),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.publicites,
        name: 'publicites',
        pageBuilder: (context, state) => buildSlideTransition(
          context: context, state: state,
          child: const PublicitesListScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        name: 'checkout',
        pageBuilder: (context, state) => buildSlideTransition(
          context: context, state: state,
          child: const CheckoutScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.orderHistory,
        name: 'orderHistory',
        pageBuilder: (context, state) => buildSlideTransition(
          context: context, state: state,
          child: const OrderHistoryScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.orderDetail}/:id',
        name: 'orderDetail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return buildSlideTransition(
            context: context,
            state: state,
            child: OrderDetailRouteScreen(orderId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.wishlist,
        name: 'wishlist',
        pageBuilder: (context, state) => buildSlideTransition(
          context: context, state: state,
          child: const WishlistScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.addresses,
        name: 'addresses',
        pageBuilder: (context, state) => buildSlideTransition(
          context: context, state: state,
          child: const AddressesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.addressNew,
        name: 'addressNew',
        pageBuilder: (context, state) => buildSlideTransition(
          context: context, state: state,
          child: const AddressFormScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.addressEdit}/:id',
        name: 'addressEdit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return buildSlideTransition(
            context: context, state: state,
            child: AddressFormScreen(addressId: id.isEmpty ? null : id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        pageBuilder: (context, state) => buildSlideTransition(
          context: context, state: state,
          child: const EditProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.paymentMethods,
        name: 'paymentMethods',
        pageBuilder: (context, state) => buildSlideTransition(
          context: context, state: state,
          child: const PaymentMethodsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        pageBuilder: (context, state) => buildSlideTransition(
          context: context, state: state,
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.faq,
        name: 'faq',
        pageBuilder: (context, state) => buildFadeSlideTransition(
          context: context, state: state,
          child: const FaqScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.helpCenter,
        name: 'helpCenter',
        pageBuilder: (context, state) => buildFadeSlideTransition(
          context: context, state: state,
          child: const HelpCenterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.chatAssistant,
        name: 'chatAssistant',
        pageBuilder: (context, state) => buildFadeSlideTransition(
          context: context, state: state,
          child: const ChatAssistantScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        name: 'privacyPolicy',
        pageBuilder: (context, state) => buildFadeSlideTransition(
          context: context, state: state,
          child: const PrivacyPolicyScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.privacySecurity,
        name: 'privacySecurity',
        pageBuilder: (context, state) => buildFadeSlideTransition(
          context: context, state: state,
          child: const PrivacySecurityScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.currency,
        name: 'currency',
        pageBuilder: (context, state) => buildFadeSlideTransition(
          context: context, state: state,
          child: const CurrencySettingsScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        body: Center(
          child: Text(l10n.pageNotFound(state.uri.toString())),
        ),
      );
    },
  );
}

/// Instance singleton du routeur — créée une seule fois pour toute la durée de vie
/// de l'application. Évite la réinitialisation de la navigation lors des rebuilds
/// (ex. changement de thème, mise à jour d'un provider).
final GoRouter _appRouterInstance = _createGoRouter();

/// Provider exposant le singleton GoRouter.
final goRouterProvider = Provider<GoRouter>((ref) => _appRouterInstance);
