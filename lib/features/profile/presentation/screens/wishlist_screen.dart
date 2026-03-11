import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/currency_selector.dart';
import '../../../../features/product/data/product_model.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/error_retry_widget.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../main_navigation/providers/main_nav_index_provider.dart';

/// Page Favoris : liste des produits mis en favoris (depuis le provider).
/// [inMainNav] : si true, affiché dans la bottom bar (sans bouton retour).
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key, this.inMainNav = false});

  final bool inMainNav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final productsAsync = ref.watch(wishlistProductsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: inMainNav
            ? null
            : IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: Text(l10n.wishlist),
        actions: [
          productsAsync.whenOrNull(
            data: (products) {
              if (products.isEmpty) return null;
              return IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                tooltip: l10n.addAllToCart,
                onPressed: () {
                  for (final product in products) {
                    ref.read(cartProvider.notifier).addItem(product.id);
                    ref.read(favoritesProvider.notifier).remove(product.id);
                  }
                  ref.read(mainNavIndexProvider.notifier).state = 3;
                  if (!inMainNav) context.go(AppRoutes.main);
                },
              );
            },
          ) ?? const SizedBox.shrink(),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              key: const ValueKey('wishlist_empty'),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.wishlist,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.wishlistEmptySubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            key: const ValueKey('wishlist_list'),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final product = products[i];
              return KeyedSubtree(
                key: ValueKey(product.id),
                child: _WishlistTile(
                  product: product,
                  onTap: () =>
                      context.push('${AppRoutes.product}/${product.id}'),
                  onRemove: () =>
                      ref.read(favoritesProvider.notifier).remove(product.id),
                  onAddCart: () {
                    ref.read(cartProvider.notifier).addItem(product.id);
                  },
                ),
              );
            },
          );
        },
        loading: () => AppPageLoader(
          key: const ValueKey('wishlist_loading'),
          minHeight: 180,
        ),
        error: (err, _) => ErrorRetryWidget(
          error: err,
          onRetry: () => ref.invalidate(wishlistProductsProvider),
          compact: true,
        ),
      ),
    );
  }
}

class _WishlistTile extends StatelessWidget {
  const _WishlistTile({
    required this.product,
    required this.onTap,
    required this.onRemove,
    required this.onAddCart,
  });

  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onAddCart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card(context),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: product.firstImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: product.firstImageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Icon(
                            Icons.image_not_supported,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : Icon(
                          Icons.shopping_bag_outlined,
                          size: 40,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    ProductPrice(
                      price: product.price,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.favorite),
                color: const Color(0xFFE53935),
                tooltip: AppLocalizations.of(context)!.removeFromWishlist,
              ),
              IconButton(
                onPressed: onAddCart,
                icon: const Icon(Icons.add_shopping_cart_outlined),
                tooltip: AppLocalizations.of(context)!.addToCart,
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
