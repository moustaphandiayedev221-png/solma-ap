/// Type d'erreur pour afficher un message localisé à l'utilisateur.
enum AppFailureType {
  timeout,
  connection,
  unauthorized,
  notFound,
  server,
  generic,
}

/// Échec métier ou technique avec message affichable à l'utilisateur.
class AppFailure implements Exception {
  const AppFailure({
    required this.message,
    required this.type,
    this.code,
    this.originalError,
  });

  final String message;
  final AppFailureType type;
  final String? code;
  final Object? originalError;

  @override
  String toString() => 'AppFailure($code): $message';
}

/// Extensions pour convertir des erreurs en [AppFailure].
extension AppFailureX on Object {
  AppFailure toAppFailure({String? fallbackMessage}) {
    if (this is AppFailure) return this as AppFailure;
    final (msg, type) = _defaultMessageAndType(this);
    return AppFailure(
      message: fallbackMessage ?? msg,
      type: type,
      originalError: this,
    );
  }
}

(String, AppFailureType) _defaultMessageAndType(Object e) {
  final s = e.toString().toLowerCase();
  if (s.contains('timed out') || s.contains('operation timed out')) {
    return ('La connexion a expiré. Réessayez.', AppFailureType.timeout);
  }
  if (s.contains('socketexception') ||
      s.contains('connection refused') ||
      s.contains('network')) {
    return ('Pas de connexion. Vérifiez votre réseau.', AppFailureType.connection);
  }
  if (s.contains('401') || s.contains('unauthorized')) {
    return ('Session expirée. Veuillez vous reconnecter.', AppFailureType.unauthorized);
  }
  if (s.contains('404')) {
    return ('Ressource introuvable.', AppFailureType.notFound);
  }
  if (s.contains('500')) {
    return ('Erreur serveur. Réessayez plus tard.', AppFailureType.server);
  }
  return ('Une erreur est survenue. Réessayez.', AppFailureType.generic);
}
