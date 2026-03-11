import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_shadows.dart';
import 'package:colways/core/providers/currency_provider.dart';
import '../../../../core/responsive/responsive_module.dart';
import '../../../../core/utils/image_optimizer.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../core/router/navigation_extensions.dart';
import '../../../product/data/product_model.dart';

/// Carte produit « New Arrivals » — exactement comme l'image de référence :
/// BEST CHOICE, nom, prix, image. Rien d'autre.
class FeaturedProductCard extends ConsumerWidget {
  const FeaturedProductCard({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final r = context.responsive;
    final l10n = AppLocalizations.of(context)!;
    final formatter = ref.watch(currencyFormatterProvider);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white;

    return GestureDetector(
      onTap: () => context.pushProductDetail(
        product.id,
        imageUrl: product.firstImageUrl,
        heroSource: 'featured',
      ),
        child: Padding(
        padding: EdgeInsets.fromLTRB(r.horizontalPadding, 8, r.horizontalPadding, 6),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShadows.card(context),
          ),
          child: Material(
            color: cardColor,
            elevation: 0,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.all(r.isCompactSmall ? 10 : 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                flex: 5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.bestChoice.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        height: 1.2,
                        fontSize: r.isCompactSmall ? 14 : 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format(product.price),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                ),
                const SizedBox(width: 12),
                Expanded(
                flex: 4,
                child: SizedBox(
                  height: r.isCompactSmall ? 65 : 75,
                  child: product.firstImageUrl != null && product.firstImageUrl!.isNotEmpty
                      ? Hero(
                          tag: 'product-image-featured-${product.id}',
                          child: ImageOptimizer.optimizedNetworkImage(
                            imageUrl: product.firstImageUrl!,
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) => Icon(
                              Icons.shopping_bag_outlined,
                              size: 36,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.shopping_bag_outlined,
                          size: 36,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.4),
                        ),
                ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}
