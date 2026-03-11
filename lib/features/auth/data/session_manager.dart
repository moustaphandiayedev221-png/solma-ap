import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_provider.dart';

/// Événements de session gérés par le SessionManager.
enum SessionEvent {
  /// Le refresh du token a échoué (session expirée côté serveur).
  tokenRefreshFailed,

  /// L'utilisateur a été déconnecté (volontairement ou par le serveur).
  signedOut,

  /// La session a expiré localement (timestamp expiresAt dépassé).
  expired,
}

/// Gestionnaire de session — écoute les expirations et changements d'état
/// pour permettre au listener UI de réagir (redirection login, nettoyage état).
class SessionManager {
  SessionManager([SupabaseClient? client])
      : _client = client ?? supabaseClient;

  final SupabaseClient _client;
  StreamSubscription<AuthState>? _authSub;
  Timer? _expirationTimer;

  final _controller = StreamController<SessionEvent>.broadcast();

  /// Stream d'événements de session (expired, refreshFailed, signedOut).
  Stream<SessionEvent> get sessionEvents => _controller.stream;

  /// Vérifie si la session courante est valide (non null et non expirée).
  bool get isSessionValid {
    final session = _client.auth.currentSession;
    if (session == null) return false;
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;
    final expiresDate =
        DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    return DateTime.now().isBefore(expiresDate);
  }

  /// Démarre l'écoute des événements d'authentification.
  void startListening() {
    _authSub?.cancel();
    _authSub = _client.auth.onAuthStateChange.listen((authState) {
      final event = authState.event;

      if (event == AuthChangeEvent.tokenRefreshed) {
        // Token rafraîchi — relancer le timer d'expiration
        _scheduleExpirationCheck();
      } else if (event == AuthChangeEvent.signedOut) {
        _cancelExpirationTimer();
        _controller.add(SessionEvent.signedOut);
      }
    }, onError: (error) {
      // En cas d'erreur (réseau, token expiré) : déconnecter immédiatement
      // pour arrêter les retries Supabase qui saturent le main thread.
      debugPrint('[SessionManager] Auth stream error: $error');
      _controller.add(SessionEvent.tokenRefreshFailed);
      _client.auth.signOut();
    });

    // Vérification initiale
    _scheduleExpirationCheck();
  }

  /// Programme un timer pour vérifier l'expiration du token.
  void _scheduleExpirationCheck() {
    _cancelExpirationTimer();
    final session = _client.auth.currentSession;
    if (session == null) return;

    final expiresAt = session.expiresAt;
    if (expiresAt == null) return;

    final expiresDate =
        DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    final remaining = expiresDate.difference(DateTime.now());

    if (remaining.isNegative) {
      _controller.add(SessionEvent.expired);
      return;
    }

    // Vérifier 30 secondes avant l'expiration
    final checkDelay = remaining - const Duration(seconds: 30);
    final effectiveDelay =
        checkDelay.isNegative ? remaining : checkDelay;

    _expirationTimer = Timer(effectiveDelay, () {
      if (!isSessionValid) {
        _controller.add(SessionEvent.expired);
      }
    });
  }

  void _cancelExpirationTimer() {
    _expirationTimer?.cancel();
    _expirationTimer = null;
  }

  /// Arrête l'écoute et libère les ressources.
  void dispose() {
    _authSub?.cancel();
    _cancelExpirationTimer();
    _controller.close();
  }
}
