/// Configuration via environnement (--dart-define en release).
/// Exemple : flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
class EnvConfig {
  EnvConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  /// Google Sign-In — Client ID Web (pour Supabase).
  /// Ex: xxx.apps.googleusercontent.com
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  /// Google Sign-In — Client ID iOS (optionnel, pour sign-in natif).
  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '',
  );

  static bool get useEnv => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Active la connexion native Google/Apple sur iOS.
  static bool get useNativeAuthOnIos => googleWebClientId.isNotEmpty;
}
