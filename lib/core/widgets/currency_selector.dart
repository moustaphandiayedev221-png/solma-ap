import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/currency_config.dart';
import '../providers/currency_provider.dart';
import '../../gen_l10n/app_localizations.dart';

/// Widget pour sélectionner une devise
class CurrencySelector extends ConsumerWidget {
  const CurrencySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentCurrency = ref.watch(currencyProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: PopupMenuButton<CurrencyInfo>(
        initialValue: currentCurrency,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentCurrency.flag,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                currentCurrency.code,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        itemBuilder: (context) {
          return CurrencyConfig.supportedCurrencies.map((currency) {
            final isSelected = currency == currentCurrency;
            return PopupMenuItem<CurrencyInfo>(
              value: currency,
              child: Row(
                children: [
                  Text(
                    currency.flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currency.localizedName(l10n),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${currency.code} (${currency.symbol})',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                ],
              ),
            );
          }).toList();
        },
        onSelected: (currency) {
          ref.read(currencyProvider.notifier).setCurrency(currency);
        },
      ),
    );
  }
}

/// Widget pour afficher un montant formaté
class FormattedAmount extends ConsumerWidget {
  const FormattedAmount({
    super.key,
    required this.amount,
    this.style,
    this.showDetails = false,
    this.compact = false,
  });

  final double amount;
  final TextStyle? style;
  final bool showDetails;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final formatter = ref.watch(currencyFormatterProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String formatted;
    if (compact) {
      formatted = formatter.formatCompact(amount);
    } else if (showDetails) {
      formatted = formatter.formatWithDetails(amount, currency.localizedName(l10n));
    } else {
      formatted = formatter.format(amount);
    }

    return Text(
      formatted,
      style: style ?? TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    );
  }
}

/// Widget pour afficher un prix de produit
class ProductPrice extends ConsumerWidget {
  const ProductPrice({
    super.key,
    required this.price,
    this.originalPrice,
    this.style,
    this.originalStyle,
    this.showDiscount = true,
  });

  final double price;
  final double? originalPrice;
  final TextStyle? style;
  final TextStyle? originalStyle;
  final bool showDiscount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(currencyFormatterProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasDiscount = originalPrice != null && originalPrice! > price;
    final discountPercentage = hasDiscount
        ? ((originalPrice! - price) / originalPrice! * 100).round()
        : 0;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Prix actuel (taille réduite, CFA à droite avec espace)
          Text(
          formatter.format(price),
          style: style ?? TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        // Prix original barré
        if (hasDiscount && showDiscount) ...[
          const SizedBox(width: 6),
          Text(
            formatter.format(originalPrice!),
            style: originalStyle ?? TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
              decorationColor: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '-$discountPercentage%',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ],
      ),
    );
  }
}
