import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/currency_selector.dart';
import '../../../../../features/product/data/product_model.dart';
import '../../../../../gen_l10n/app_localizations.dart';
import '../../../../reviews/presentation/providers/review_provider.dart';

/// Bloc nom, catégorie, prix et sélecteur de quantité (2 lignes).
class ProductDetailProductInfo extends ConsumerWidget {
  const ProductDetailProductInfo({
    super.key,
    required this.product,
    this.heroSource = 'card',
    this.heroTagSuffix,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final ProductModel product;
  final String heroSource;
  final String? heroTagSuffix;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Hero(
                        tag: 'product-name-$heroSource-${product.id}${heroTagSuffix != null ? '-$heroTagSuffix' : ''}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            product.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _ProductRatingRow(productId: product.id, l10n: l10n),
                  ],
                ),
              ),
              Hero(
                tag: 'product-price-$heroSource-${product.id}${heroTagSuffix != null ? '-$heroTagSuffix' : ''}',
                child: Material(
                  color: Colors.transparent,
                  child: ProductPrice(
                    price: product.price,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.sportShoes,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              _QuantitySelector(
                quantity: quantity,
                onQuantityChanged: onQuantityChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductRatingRow extends ConsumerWidget {
  const _ProductRatingRow({
    required this.productId,
    required this.l10n,
  });

  final String productId;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final avgRating = ref.watch(averageRatingProvider(productId));
    final count = ref.watch(reviewCountProvider(productId));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: 20,
          color: Colors.amber.shade700,
        ),
        const SizedBox(width: 4),
        Text(
          avgRating.toStringAsFixed(1),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${l10n.reviewsCount(count)})',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onQuantityChanged,
  });

  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QuantityButton(
          icon: Icons.remove,
          onTap: () => onQuantityChanged(quantity > 1 ? quantity - 1 : 1),
          theme: theme,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '$quantity',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        _QuantityButton(
          icon: Icons.add,
          onTap: () => onQuantityChanged(quantity + 1),
          theme: theme,
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.theme,
  });

  final IconData icon;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
