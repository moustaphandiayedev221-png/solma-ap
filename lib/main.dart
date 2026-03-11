import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/env_config.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/theme_mode_provider.dart';
import 'core/providers/locale_provider.dart';
import 'features/notifications/data/local_notification_service.dart';
import 'features/auth/presentation/widgets/session_expiration_listener.dart';
import 'features/notifications/presentation/widgets/in_app_notification_banner.dart';
import 'features/notifications/presentation/widgets/notification_realtime_listener.dart';
import 'core/realtime/catalog_realtime_listener.dart';
import 'core/widgets/connectivity_gate.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:colways/gen_l10n/app_localizations.dart';
import 'firebase_options.dart';

/// Push reçu en arrière-plan ou app tuée : le système affiche la notification
/// automatiquement (payload FCM avec "notification"). On initialise Firebase pour le SDK.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Firebase — non bloquante si indisponible (ex. simulateur sans GoogleServices)
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await LocalNotificationService.initialize();
  } catch (e, st) {
    // Firebase est optionnel (notifications push). L'app reste fonctionnelle sans lui.
    // L'erreur est remontée en debug pour faciliter le diagnostic.
    if (kDebugMode) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: e,
          stack: st,
          library: 'Firebase',
          context: ErrorDescription('Initialisation Firebase échouée — notifications push désactivées'),
        ),
      );
    }
  }

  await Supabase.initialize(
    url: SupabaseConfig.urlSafe,
    anonKey: SupabaseConfig.anonKeySafe,
  );
  if (EnvConfig.stripePublishableKey.isNotEmpty) {
    Stripe.publishableKey = EnvConfig.stripePublishableKey;
    await Stripe.instance.applySettings();
  }
  runApp(
    const ProviderScope(
      child: ColwaysApp(),
    ),
  );
}

class ColwaysApp extends ConsumerStatefulWidget {
  const ColwaysApp({super.key});

  @override
  ConsumerState<ColwaysApp> createState() => _ColwaysAppState();
}

class _ColwaysAppState extends ConsumerState<ColwaysApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(themeModeProvider.notifier).load();
      ref.read(localeProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'SOLMA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        CountryLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        final theme = Theme.of(context);
        final textStyle = theme.textTheme.bodyLarge ??
            theme.textTheme.bodyMedium ??
            const TextStyle(fontSize: 16);
        return DefaultTextStyle(
          style: textStyle,
          child: ConnectivityGate(
            child: SessionExpirationListener(
              child: NotificationRealtimeListener(
                child: CatalogRealtimeListener(
                  child: InAppNotificationBanner(
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
