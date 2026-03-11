import 'dart:async';

import 'package:flutter/material.dart';

import '../../gen_l10n/app_localizations.dart';
import '../error/app_failure.dart';
import '../widgets/product_list_shimmer.dart';
import 'error_retry_widget.dart';

/// Placeholder élégant pour erreurs de connexion : shimmer + réessai automatique.
/// N'affiche jamais le bloc d'erreur brut "Pas de connexion" — expérience premium.
class ConnectionElegantPlaceholder extends StatefulWidget {
  const ConnectionElegantPlaceholder({
    super.key,
    required this.error,
    required this.onRetry,
    this.compact = false,
    this.useSliver = true,
  });

  final Object error;
  final VoidCallback onRetry;
  final bool compact;
  /// Si true, retourne un Sliver (pour CustomScrollView). Sinon un Widget.
  final bool useSliver;

  static bool isConnectionError(Object error) {
    final failure = error is AppFailure ? error : error.toAppFailure();
    return failure.type == AppFailureType.connection ||
        failure.type == AppFailureType.timeout;
  }

  @override
  State<ConnectionElegantPlaceholder> createState() =>
      _ConnectionElegantPlaceholderState();
}

class _ConnectionElegantPlaceholderState
    extends State<ConnectionElegantPlaceholder> {
  int _retryCount = 0;
  static const int _maxAutoRetries = 4;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    if (ConnectionElegantPlaceholder.isConnectionError(widget.error)) {
      _scheduleRetry();
    }
  }

  @override
  void didUpdateWidget(ConnectionElegantPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.error != widget.error && widget.error != oldWidget.error) {
      _retryTimer?.cancel();
      if (ConnectionElegantPlaceholder.isConnectionError(widget.error)) {
        _scheduleRetry();
      }
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    if (_retryCount >= _maxAutoRetries) return;
    _retryTimer = Timer(
      const Duration(seconds: 3),
      () {
        if (!mounted) return;
        _retryCount++;
        try {
          widget.onRetry();
        } catch (_) {
          // Ignore si le provider/context n'est plus valide (changement d'onglet).
        }
      },
    );
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnection = ConnectionElegantPlaceholder.isConnectionError(widget.error);

    if (isConnection) {
      // Même rendu que le chargement : l'utilisateur voit un shimmer, pas d'erreur.
      if (widget.useSliver) {
        return const ProductRowShimmer(rowCount: 2);
      }
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                l10n.loading,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final errorWidget = ErrorRetryWidget(
      error: widget.error,
      onRetry: widget.onRetry,
      compact: widget.compact,
    );
    return widget.useSliver
        ? SliverToBoxAdapter(child: errorWidget)
        : errorWidget;
  }
}
