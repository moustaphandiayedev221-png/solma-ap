import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/router/app_router.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../data/session_manager.dart';
/// Widget wrapper qui écoute les événements de session et redirige vers
/// le login quand la session expire ou que le refresh échoue.
class SessionExpirationListener extends ConsumerStatefulWidget {
  const SessionExpirationListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SessionExpirationListener> createState() =>
      _SessionExpirationListenerState();
}

class _SessionExpirationListenerState
    extends ConsumerState<SessionExpirationListener> {
  late final SessionManager _sessionManager;
  StreamSubscription<SessionEvent>? _sub;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _sessionManager = SessionManager();
    _sessionManager.startListening();

    _sub = _sessionManager.sessionEvents.listen(_handleSessionEvent);
  }

  void _handleSessionEvent(SessionEvent event) {
    if (!mounted) return;

    switch (event) {
      case SessionEvent.tokenRefreshFailed:
      case SessionEvent.expired:
        _showExpiredDialog();
        break;
      case SessionEvent.signedOut:
        // Le signOut normal est géré par le flow auth classique.
        // On ne montre le dialog que si c'est inattendu.
        break;
    }
  }

  void _showExpiredDialog() {
    if (_dialogShown || !mounted) return;
    _dialogShown = true;

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: Icon(
          Icons.lock_clock_rounded,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          l10n?.sessionExpired ?? 'Session expirée',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          l10n?.sessionExpiredMessage ??
              'Votre session a expiré ou la connexion a échoué. Vérifiez votre connexion internet et reconnectez-vous.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _dialogShown = false;
                _clearStateAndRedirect();
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                l10n?.reconnect ?? 'Se reconnecter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Nettoie l'état local (panier, favoris) et redirige vers le login.
  void _clearStateAndRedirect() {
    ref.invalidate(cartProvider);
    ref.invalidate(favoritesProvider);
    Supabase.instance.client.auth.signOut();

    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sessionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
