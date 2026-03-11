import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../data/promo_repository.dart';
import '../providers/promo_provider.dart';

/// Champ de saisie de code promo avec bouton "Appliquer".
class PromoCodeInput extends ConsumerStatefulWidget {
  const PromoCodeInput({
    super.key,
    required this.subtotal,
    this.userId,
  });

  /// Le sous-total actuel de la commande (pour validation min_order).
  final double subtotal;

  /// ID utilisateur (pour limite max_uses_per_user).
  final String? userId;

  @override
  ConsumerState<PromoCodeInput> createState() => _PromoCodeInputState();
}

class _PromoCodeInputState extends ConsumerState<PromoCodeInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _errorMessage(AppLocalizations l10n, PromoErrorCode code) {
    switch (code) {
      case PromoErrorCode.notFound:
        return l10n.promoNotFound;
      case PromoErrorCode.inactive:
        return l10n.promoNotFound;
      case PromoErrorCode.expired:
        return l10n.promoExpired;
      case PromoErrorCode.notStarted:
        return l10n.promoNotFound;
      case PromoErrorCode.maxUsesReached:
      case PromoErrorCode.maxUsesPerUserReached:
        return l10n.promoMaxUsed;
      case PromoErrorCode.minOrderNotMet:
        return l10n.promoMinOrder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final promoState = ref.watch(promoProvider);

    // Si un code est appliqué, afficher le résumé au lieu du champ de saisie
    if (promoState is PromoApplied) {
      return _AppliedPromoCard(
        promo: promoState,
        onRemove: () => ref.read(promoProvider.notifier).clear(),
      );
    }

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.promoCode,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: l10n.promoCodePlaceholder,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: promoState is PromoLoading
                    ? null
                    : () {
                        ref.read(promoProvider.notifier).applyCode(
                              _controller.text,
                              widget.subtotal,
                              userId: widget.userId,
                            );
                      },
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: promoState is PromoLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.apply),
              ),
            ],
          ),
          if (promoState is PromoError) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage(l10n, promoState.errorCode),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Carte affichant le code promo appliqué avec possibilité de le retirer.
class _AppliedPromoCard extends ConsumerWidget {
  const _AppliedPromoCard({
    required this.promo,
    required this.onRemove,
  });

  final PromoApplied promo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final formatter = ref.watch(currencyFormatterProvider);

    return SoftCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo.promo.code,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '-${formatter.format(promo.discountAmount)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onRemove,
            child: Text(
              l10n.removePromo,
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
