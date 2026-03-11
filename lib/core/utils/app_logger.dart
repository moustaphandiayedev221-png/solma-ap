import 'package:flutter/foundation.dart';

/// Logger centralisé pour l'application SOLMA.
///
/// En debug : affiche les logs dans la console via debugPrint.
/// En release : les logs sont silencieux (peut être remplacé par Sentry, Crashlytics, etc.).
class AppLogger {
  AppLogger._();

  /// Log d'information (flux normal).
  static void info(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] $message');
    }
  }

  /// Log d'avertissement (situation anormale mais non bloquante).
  static void warn(String tag, String message) {
    if (kDebugMode) {
      debugPrint('⚠️ [$tag] $message');
    }
  }

  /// Log d'erreur avec stack trace optionnelle.
  static void error(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('❌ [$tag] $message');
      if (error != null) debugPrint('  Error: $error');
      if (stackTrace != null) debugPrint('  Stack: $stackTrace');
    }
    // TODO: En production, envoyer à un service de monitoring (Sentry, Crashlytics).
  }
}
