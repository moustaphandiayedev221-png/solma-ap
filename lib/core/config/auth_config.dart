import 'env_config.dart';

/// Configuration des clients OAuth natifs (Google, Apple).
///
/// Permet d'utiliser la connexion native (sans quitter l'app, sans webview) :
/// - iOS : Google via google_sign_in, Apple via sign_in_with_apple
/// - Android : Google via google_sign_in
///
/// Remplir _devGoogleWebClientId avec ton Client ID Web (Google Cloud Console).
/// En production : --dart-define=GOOGLE_WEB_CLIENT_ID=xxx --dart-define=GOOGLE_IOS_CLIENT_ID=yyy
class AuthConfig {
  AuthConfig._();

  /// Client ID Web — obligatoire pour la connexion native Google.
  /// C'est le 1er Client ID dans Supabase (client OAuth type "Web application").
  /// À copier depuis Supabase (Provider Google → Client IDs, avant la virgule)
  /// ou Google Cloud Console (Credentials → client Web).
  static const String _devGoogleWebClientId = '';

  /// Client ID iOS — optionnel (utilise le bundle par défaut).
  static const String _devGoogleIosClientId =
      '438014545661-qb6iv2sjoctk9ga63lqqai9l29bjg7gn.apps.googleusercontent.com';

  static String get googleWebClientId => EnvConfig.googleWebClientId.isNotEmpty
      ? EnvConfig.googleWebClientId
      : _devGoogleWebClientId;

  static String get googleIosClientId => EnvConfig.googleIosClientId.isNotEmpty
      ? EnvConfig.googleIosClientId
      : _devGoogleIosClientId;
}
