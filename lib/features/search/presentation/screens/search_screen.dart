import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/responsive/responsive_module.dart';
import '../../../../core/router/navigation_extensions.dart';
import '../../../../core/widgets/error_retry_widget.dart';
import '../../../../core/widgets/product_list_shimmer.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../home/presentation/widgets/product_card.dart';
import '../../../product/data/product_model.dart';
import '../../../product/presentation/providers/product_provider.dart';

/// Page recherche : champ de recherche + résultats (grille de ProductCard).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

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
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
    return const Color(0xFF9E9E9E);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final r = context.responsive;
    // Champ vide = tous les produits ; sinon filtre en temps réel
    final productsAsync = _query.isEmpty
        ? ref.watch(allProductsProvider)
        : ref.watch(searchProductsProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navSearch),
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              r.horizontalPadding,
              0,
              r.horizontalPadding,
              12,
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.6,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.6,
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ),
      body: productsAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              key: const ValueKey('search_empty'),
              child: Text(
                l10n.noProducts,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          return GridView.builder(
            key: PageStorageKey<String>('search_$_query'),
            padding: EdgeInsets.fromLTRB(
              r.horizontalPadding,
              8,
              r.horizontalPadding,
              100,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: r.gridCrossAxisCount,
              childAspectRatio: r.gridChildAspectRatio,
              crossAxisSpacing: r.gap,
              mainAxisSpacing: r.gap,
            ),
            itemCount: list.length,
            itemBuilder: (context, i) => KeyedSubtree(
              key: ValueKey(list[i].id),
              child: _buildProductCard(context, ref, list[i], i),
            ),
          );
        },
        loading: () => const KeyedSubtree(
          key: ValueKey('search_loading'),
          child: ProductGridShimmer(itemCount: 6),
        ),
        error: (err, _) => ErrorRetryWidget(
          error: err,
          onRetry: () {
            if (_query.isEmpty) {
              ref.invalidate(allProductsProvider);
            } else {
              ref.invalidate(searchProductsProvider(_query));
            }
          },
          compact: true,
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    WidgetRef ref,
    ProductModel product,
    int index,
  ) {
    final heroTagSuffix = 'search-$index';
    final cardColor =
        _cardBackgroundColors[index % _cardBackgroundColors.length];
    final colorDots = product.colors.map((c) => _parseHexColor(c.hex)).toList();
    return ProductCard(
      productId: product.id,
      heroTagSuffix: heroTagSuffix,
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
        heroTagSuffix: heroTagSuffix,
      ),
      onAddCart: () => ref.read(cartProvider.notifier).addItem(product.id),
      onWishlist: () => ref.read(favoritesProvider.notifier).toggle(product.id),
    );
  }
}
