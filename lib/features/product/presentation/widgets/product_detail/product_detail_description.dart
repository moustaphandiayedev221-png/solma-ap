import 'package:flutter/material.dart';
import '../../../../../gen_l10n/app_localizations.dart';
import '../../constants/product_detail_constants.dart';
import '../../../data/product_model.dart';

/// Section titre "Description" + texte de description produit.
class ProductDetailDescription extends StatelessWidget {
  const ProductDetailDescription({
    super.key,
    required this.product,
    this.showTitle = true,
  });

  final ProductModel product;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final description = product.description ?? ProductDetailConstants.defaultDescription;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ProductDetailConstants.horizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            Text(
              l10n.description,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.5,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.65,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
