import 'package:flutter/material.dart';
import '../../../../../core/responsive/responsive_module.dart';
import '../../../../../gen_l10n/app_localizations.dart';
import '../../constants/product_detail_constants.dart';

/// Boutons "Acheter maintenant" + panier en bas. Fond transparent, seuls les boutons sont visibles.
class ProductDetailBottomActions extends StatelessWidget {
  const ProductDetailBottomActions({
    super.key,
    required this.onBuyNow,
    required this.onCartTap,
  });

  final VoidCallback onBuyNow;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final r = context.responsive;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        r.horizontalPadding,
        ProductDetailConstants.bottomBarVerticalPadding,
        r.horizontalPadding,
        bottomPadding + ProductDetailConstants.bottomBarVerticalPadding,
      ),
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onBuyNow,
              child: Container(
                height: ProductDetailConstants.bottomBarButtonHeight,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n.buyNow,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onCartTap,
            child: Container(
              width: ProductDetailConstants.bottomBarButtonHeight,
              height: ProductDetailConstants.bottomBarButtonHeight,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.add_shopping_cart,
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
