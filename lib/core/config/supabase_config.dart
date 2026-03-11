import 'env_config.dart';

/// Configuration Supabase — SOLMA.
///
/// SÉCURITÉ : En production, utiliser exclusivement --dart-define :
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
///   flutter build apk --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
///
/// Les valeurs _dev* ci-dessous sont des fallbacks pour le développement local uniquement.
/// Ne jamais committer de clés de production. Voir docs/ARCHITECTURE_ET_RECOMMANDATIONS.md.
class SupabaseConfig {
  SupabaseConfig._();

  // Valeurs de développement — surchargées par --dart-define en production.
  static const String _devUrl = 'https://zdqufipwgmxionjbrixs.supabase.co';
  // IMPORTANT: La clé Supabase anon doit être au format JWT (eyJ...).
  // Récupérez-la dans Supabase Dashboard > Project Settings > API > anon public.
  static const String _devAnonKey =
      'sb_publishable_-dmIseQl3hUS4t4Zk5g_7A_6pO_2xsJ';

  /// URL Supabase : --dart-define en priorité, sinon fallback dev.
  static String get url =>
      EnvConfig.supabaseUrl.isNotEmpty ? EnvConfig.supabaseUrl : _devUrl;

  /// Clé anon : --dart-define en priorité, sinon fallback dev.
  static String get anonKey =>
      EnvConfig.supabaseAnonKey.isNotEmpty ? EnvConfig.supabaseAnonKey : _devAnonKey;

  /// Alias utilisés dans main.dart.
  /// En release sans --dart-define, l'app utilisera les valeurs dev (à remplacer pour la prod).
  static String get urlSafe => url;
  static String get anonKeySafe => anonKey;

  static const String bucketProducts = 'products';
  static const String bucketAvatars = 'avatars';
  static const String bucketBanners = 'banners';
}
