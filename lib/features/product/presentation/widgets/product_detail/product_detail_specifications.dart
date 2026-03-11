import 'package:flutter/material.dart';
import '../../../../../gen_l10n/app_localizations.dart';
import '../../constants/product_detail_constants.dart';
import '../../../data/product_model.dart';

/// Section spécifications produit (tailles, couleurs, stock).
class ProductDetailSpecifications extends StatelessWidget {
  const ProductDetailSpecifications({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final specs = <_SpecRow>[
      _SpecRow(
        l10n.selectSize,
        product.sizes.isNotEmpty
            ? product.sizes.join(', ')
            : ProductDetailConstants.defaultSizes.join(', '),
      ),
      if (product.colors.isNotEmpty)
        _SpecRow(
          l10n.colors,
          product.colors.map((c) => c.name).join(', '),
        ),
      _SpecRow(l10n.stock, '${product.stock}'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ProductDetailConstants.horizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...specs.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      row.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecRow {
  const _SpecRow(this.label, this.value);
  final String label;
  final String value;
}
