import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_module.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/utils/image_optimizer.dart';
import '../../../../core/widgets/currency_selector.dart';

/// Source Hero pour différencier les tags (évite doublons quand le même produit
/// apparaît en FeaturedProductCard et ProductCard sur la même page).
enum HeroProductSource { card, featured }

/// ProductCard : responsive, zone couleur pour l'image, prix + Add to cart.
/// [productId] et [heroSource] requis pour les Hero animations vers la page détail.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.productId,
    this.heroSource = HeroProductSource.card,
    this.heroTagSuffix,
    required this.name,
    required this.price,
    this.imageUrl,
    this.cardBackgroundColor,
    this.colorDots = const [],
    this.selectedColorIndex = 0,
    this.isFavorite = false,
    this.width,
    required this.onTap,
    required this.onAddCart,
    required this.onWishlist,
  });

  final String productId;
  final HeroProductSource heroSource;
  final String? heroTagSuffix;
  final String name;
  final double price;
  final String? imageUrl;
  final Color? cardBackgroundColor;
  final List<Color> colorDots;
  final int selectedColorIndex;
  final bool isFavorite;
  final double? width;
  final VoidCallback onTap;
  final VoidCallback onAddCart;
  final VoidCallback onWishlist;

  static const List<Color> _defaultCardColors = [
    Color(0xFFCCF0F8),
    Color(0xFFF5EDD8),
    Color(0xFFD8EED0),
    Color(0xFFE8D5C8),
    Color(0xFFB3E5FC),
    Color(0xFFFFF8E1),
  ];

  /// Largeur par défaut (utilisée si width non fourni) — déprécié, préférer width responsive.
  static const double cardWidth = 200;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final r = context.responsive;
    final cardW = width ?? r.productCardWidthHorizontal;
    final bgColor = cardBackgroundColor ?? _defaultCardColors[0];
    final dots = colorDots.isNotEmpty
        ? colorDots
        : [
            const Color(0xFFFFEB3B),
            const Color(0xFFFF9800),
            const Color(0xFF212121),
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : (width ?? cardW);
        final maxH = constraints.maxHeight;
        final hasHeightConstraint = maxH.isFinite && maxH > 0;
        final h = r.productCardImageHeight(w);

        final cardColor = isDark ? colorScheme.surfaceContainerHighest : Colors.white;
        final radius = BorderRadius.circular(r.isCompactSmall ? 16 : 20);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: AppShadows.card(context),
            ),
            child: Material(
              color: cardColor,
              elevation: 0,
              borderRadius: radius,
              clipBehavior: Clip.antiAlias,
            child: Container(
              width: constraints.maxWidth.isFinite && constraints.maxWidth > 0 ? null : w,
              padding: EdgeInsets.all(r.isCompactSmall ? 3 : 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(r.isCompactSmall ? 16 : 20),
              ),
              child: hasHeightConstraint
                ? SizedBox(
                    height: maxH,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(minHeight: 60),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(r.isCompactSmall ? 16 : 20),
                                topRight: Radius.circular(r.isCompactSmall ? 16 : 20),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(r.isCompactSmall ? 16 : 20),
                                topRight: Radius.circular(r.isCompactSmall ? 16 : 20),
                              ),
                              child: imageUrl != null && imageUrl!.isNotEmpty
                                  ? Hero(
                                      tag: 'product-image-${heroSource.name}-$productId${heroTagSuffix != null ? '-$heroTagSuffix' : ''}',
                                      child: ImageOptimizer.optimizedNetworkImage(
                                        imageUrl: imageUrl!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.shopping_bag_outlined,
                                        size: r.isCompactSmall ? 36 : 48,
                                        color: theme.colorScheme.onSurfaceVariant.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        // Contenu
                        _CardContent(
                          r: r,
                          productId: productId,
                          heroSource: heroSource,
                          heroTagSuffix: heroTagSuffix,
                          name: name,
                          price: price,
                          dots: dots,
                          selectedColorIndex: selectedColorIndex,
                          isFavorite: isFavorite,
                          colorScheme: colorScheme,
                          theme: theme,
                          onWishlist: onWishlist,
                          onAddCart: onAddCart,
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(r.isCompactSmall ? 16 : 20),
                            topRight: Radius.circular(r.isCompactSmall ? 16 : 20),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(r.isCompactSmall ? 16 : 20),
                            topRight: Radius.circular(r.isCompactSmall ? 16 : 20),
                          ),
                          child: imageUrl != null && imageUrl!.isNotEmpty
                              ? Hero(
                                  tag: 'product-image-${heroSource.name}-$productId${heroTagSuffix != null ? '-$heroTagSuffix' : ''}',
                                  child: ImageOptimizer.optimizedNetworkImage(
                                    imageUrl: imageUrl!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    size: r.isCompactSmall ? 36 : 48,
                                    color: theme.colorScheme.onSurfaceVariant.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      _CardContent(
                        r: r,
                        productId: productId,
                        heroSource: heroSource,
                        heroTagSuffix: heroTagSuffix,
                        name: name,
                        price: price,
                        dots: dots,
                        selectedColorIndex: selectedColorIndex,
                        isFavorite: isFavorite,
                        colorScheme: colorScheme,
                        theme: theme,
                        onWishlist: onWishlist,
                        onAddCart: onAddCart,
                      ),
                    ],
                  ),
            ),
          ),
        ),
        );
      },
    );
  }
}

/// Contenu commun : pastilles, nom, prix, boutons.
class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.r,
    required this.productId,
    required this.heroSource,
    this.heroTagSuffix,
    required this.name,
    required this.price,
    required this.dots,
    required this.selectedColorIndex,
    required this.isFavorite,
    required this.colorScheme,
    required this.theme,
    required this.onWishlist,
    required this.onAddCart,
  });

  final ResponsiveValues r;
  final String productId;
  final HeroProductSource heroSource;
  final String? heroTagSuffix;
  final String name;
  final double price;
  final List<Color> dots;
  final int selectedColorIndex;
  final bool isFavorite;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final VoidCallback onWishlist;
  final VoidCallback onAddCart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(r.isCompactSmall ? 8 : 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(
                dots.length > 4 ? 4 : dots.length,
                (i) => Padding(
                  padding: EdgeInsets.only(
                    right: i < (dots.length > 4 ? 4 : dots.length) - 1 ? 8 : 0,
                  ),
                  child: _ColorCircle(
                    color: dots[i],
                    isSelected: i == selectedColorIndex,
                    size: r.isCompactSmall ? 10 : 12,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onWishlist,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: r.isCompactSmall ? 16 : 18,
                    color: isFavorite
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Hero(
            tag: 'product-name-${heroSource.name}-$productId${heroTagSuffix != null ? '-$heroTagSuffix' : ''}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                name,
                style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: r.titleFontSize,
              color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Hero(
                  tag: 'product-price-${heroSource.name}-$productId${heroTagSuffix != null ? '-$heroTagSuffix' : ''}',
                  child: Material(
                    color: Colors.transparent,
                    child: ProductPrice(
                      price: price,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: r.isCompactSmall ? 12 : 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              Material(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: onAddCart,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Icon(
                      Icons.add_shopping_cart,
                      color: colorScheme.onPrimary,
                      size: r.isCompactSmall ? 18 : 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorCircle extends StatelessWidget {
  const _ColorCircle({required this.color, this.isSelected = false, this.size = 12});

  final Color color;
  final bool isSelected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.outline;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: borderColor, width: 2) : null,
      ),
    );
  }
}
