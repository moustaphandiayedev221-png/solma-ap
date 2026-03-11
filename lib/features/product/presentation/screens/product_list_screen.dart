import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/responsive/responsive_module.dart';
import '../../../../core/router/navigation_extensions.dart';
import '../../../../core/widgets/connection_elegant_placeholder.dart';
import '../../../../core/widgets/product_list_shimmer.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../sections/presentation/providers/sections_provider.dart';
import '../providers/product_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../home/presentation/widgets/product_card.dart';

/// Écran "Tout voir" pour une section (Populaire ou Sport).
class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key, required this.section});

  /// 'popular' ou 'sports'
  final String section;

  static const List<Color> _cardBackgroundColors = [
    Color(0xFFCCF0F8),
    Color(0xFFF5EDD8),
    Color(0xFFD8EED0),
    Color(0xFFE8D5C8),
    Color(0xFFB3E5FC),
    Color(0xFFFFF8E1),
  ];

  static Color _parseHexColor(String hex) {
    final h = hex.startsWith('#') ? hex.substring(1) : hex;
    if (h.length == 6) {
      return Color(int.parse('FF$h', radix: 16));
    }
    return const Color(0xFF9E9E9E);
  }

  String _titleFromL10n(AppLocalizations l10n) {
    return switch (section) {
      'popular' => l10n.sectionPopular,
      'sports' => l10n.sectionSports,
      'new' => l10n.sectionNew,
      'tenues-africaines' => l10n.sectionTenuesAfricaines,
      'sacs-a-main' => l10n.sectionSacsAMain,
      _ => section,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final r = context.responsive;
    final sectionsAsync = ref.watch(sectionsProvider);
    final sectionModel = sectionsAsync.valueOrNull?.where((s) => s.key == section).firstOrNull;
    final title = sectionModel?.displayName ?? _titleFromL10n(l10n);
    final productsAsync = ref.watch(productsBySectionProvider(section));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        title: Text(title),
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: productsAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              key: const ValueKey('product_list_empty'),
              child: Text(
                l10n.noProducts,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          return GridView.builder(
            key: PageStorageKey<String>('product_list_$section'),
            padding: EdgeInsets.fromLTRB(
              r.horizontalPadding,
              r.verticalPadding * 0.5,
              r.horizontalPadding,
              r.verticalPadding,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: r.gridCrossAxisCount,
              childAspectRatio: r.gridChildAspectRatio,
              crossAxisSpacing: r.gap,
              mainAxisSpacing: r.gap,
            ),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final product = list[i];
              final cardColor =
                  _cardBackgroundColors[i % _cardBackgroundColors.length];
              final colorDots = product.colors
                  .map((c) => _parseHexColor(c.hex))
                  .toList();
              return ProductCard(
                key: ValueKey('${product.id}-$i'),
                productId: product.id,
                heroTagSuffix: '$i',
                name: product.name,
                price: product.price,
                imageUrl: product.firstImageUrl,
                cardBackgroundColor: cardColor,
                colorDots: colorDots,
                isFavorite: ref.watch(favoritesProvider).contains(product.id),
                onTap: () => context.pushProductDetail(
                  product.id,
                  imageUrl: product.firstImageUrl,
                  heroSource: 'card',
                  heroTagSuffix: '$i',
                ),
                onAddCart: () =>
                    ref.read(cartProvider.notifier).addItem(product.id),
                onWishlist: () =>
                    ref.read(favoritesProvider.notifier).toggle(product.id),
              );
            },
          );
        },
        loading: () => const KeyedSubtree(
          key: ValueKey('product_list_loading'),
          child: ProductGridShimmer(itemCount: 6),
        ),
        error: (err, _) => ConnectionElegantPlaceholder(
          error: err,
          onRetry: () => ref.invalidate(productsBySectionProvider(section)),
          compact: true,
          useSliver: false,
        ),
      ),
    );
  }
}
