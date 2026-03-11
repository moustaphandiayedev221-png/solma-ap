import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/responsive_module.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/navigation_extensions.dart';
import '../../../publicites/data/publicite_model.dart';
import '../../../publicites/presentation/providers/publicites_provider.dart';
import '../../../publicites/presentation/widgets/publicite_led_carousel.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../category/data/category_model.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../main_navigation/providers/main_nav_index_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../product/data/product_model.dart';
import '../../../product/presentation/providers/product_provider.dart';
import '../../../../core/services/product_cache_service.dart';
import '../../../sections/data/section_model.dart';
import '../../../sections/presentation/providers/sections_provider.dart';
import '../providers/banner_provider.dart';
import '../../../../core/widgets/connection_elegant_placeholder.dart';
import '../widgets/category_chips.dart';
import '../widgets/home_banner.dart';
import '../widgets/home_page_shimmer.dart';
import '../widgets/product_card.dart';
import '../widgets/why_choose_colways_band.dart';

/// Home style image : avatar, bannière split, catégories, cartes avec fond coloré, bottom nav gris
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// "All" ou slug de la catégorie (ex. men, women) pour le filtre
  String _selectedCategory = 'All';

  static const List<Color> _cardBackgroundColors = [
    Color(0xFFCCF0F8),
    Color(0xFFF5EDD8),
    Color(0xFFD8EED0),
    Color(0xFFE8D5C8),
    Color(0xFFB3E5FC),
    Color(0xFFFFF8E1),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final r = context.responsive;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 20.0;
    final bannersAsync = ref.watch(bannersProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? [];
    // Tout = mélange toutes catégories ; Hommes/Femmes/Enfants = filtre par catégorie
    final categoryFilterParam = _resolveCategoryFilter(_selectedCategory, categories);
    final sectionsAsync = ref.watch(sectionsProvider);
    final sections = sectionsAsync.valueOrNull ?? _defaultSections(l10n);
    final cartCount = ref.watch(cartItemCountProvider);
    final unreadCountAsync = ref.watch(unreadNotificationsCountProvider);
    final unreadCount = unreadCountAsync.valueOrNull ?? 0;

    // Shimmer full page au chargement INITIAL ou en absence de connexion.
    // Inclut "Tout", bande noire, bannière — même expérience que les sections produits.
    final hasConnectionErrorOnBanners = bannersAsync.hasError &&
        ConnectionElegantPlaceholder.isConnectionError(bannersAsync.error!);
    final hasConnectionErrorOnCategories = categoriesAsync.hasError &&
        ConnectionElegantPlaceholder.isConnectionError(categoriesAsync.error!);
    final isInitialLoading = bannersAsync.isLoading ||
        categoriesAsync.isLoading ||
        hasConnectionErrorOnBanners ||
        hasConnectionErrorOnCategories;

    if (isInitialLoading) {
      return Scaffold(body: const HomePageShimmer());
    }

    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Column(
        children: [
          // App bar fixe
          Padding(
            padding: EdgeInsets.fromLTRB(
              r.horizontalPadding,
              topPadding + (r.isCompactSmall ? 8 : 12),
              r.horizontalPadding,
              12,
            ),
            child: Row(
              children: [
                const _AppName(),
                const SizedBox(width: 8),
                const Spacer(),
                _HeaderIcon(
                  icon: Icons.notifications_outlined,
                  isBlackBackground: true,
                  showDot: unreadCount > 0,
                  onPressed: () => context.push(AppRoutes.notifications),
                  badgeCount: unreadCount > 0 ? unreadCount : null,
                ),
                const SizedBox(width: 8),
                _HeaderIcon(
                  icon: Icons.shopping_bag_outlined,
                  isBlackBackground: false,
                  onPressed: () =>
                      ref.read(mainNavIndexProvider.notifier).state = 3,
                  badgeCount: cartCount > 0 ? cartCount : null,
                ),
              ],
            ),
          ),
          // Contenu scrollable avec pull-to-refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(bannersProvider);
                ref.invalidate(sectionsProvider);
                ref.invalidate(categoriesProvider);
                ref.invalidate(productCacheProvider);
                ref.invalidate(sectionProductsByCategoryProvider);
                ref.invalidate(publicitesProvider);
                ref.invalidate(publicitesBySectionProvider);
                await Future.wait([
                  ref.read(bannersProvider.future),
                  ref.read(sectionsProvider.future),
                  ref.read(categoriesProvider.future),
                ]);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                SliverToBoxAdapter(
                  child: HomeBanner(banners: bannersAsync.valueOrNull ?? []),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: const WhyChooseColwaysBand(),
                  ),
                ),
                SliverToBoxAdapter(
                  key: const ValueKey('home_categories'),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      r.horizontalPadding,
                      8,
                      r.horizontalPadding,
                      12,
                    ),
                    child: categoriesAsync.when(
                      data: (list) {
                        final allList = list
                            .where((c) => c.slug.trim().toLowerCase() == 'all')
                            .toList();
                        final allCategory = allList.isNotEmpty
                            ? allList.first
                            : null;
                        return CategoryChips(
                          categories: list,
                          selectedValue: _selectedCategory,
                          onSelected: (v) =>
                              setState(() => _selectedCategory = v),
                          categoryAllLabel: allCategory?.name,
                        );
                      },
                      loading: () => CategoryChips(
                        categories: const [],
                        selectedValue: _selectedCategory,
                        onSelected: (v) =>
                            setState(() => _selectedCategory = v),
                      ),
                      error: (_, _) => CategoryChips(
                        categories: const [],
                        selectedValue: _selectedCategory,
                        onSelected: (v) =>
                            setState(() => _selectedCategory = v),
                      ),
                    ),
                  ),
                ),
                // Sections produit + bandes (ordre et noms depuis product_sections en BDD)
                ..._buildSectionsSlivers(
                  context,
                  ref,
                  sections,
                  categoryFilterParam,
                ),
                SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
              ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sections par défaut si l'API ne répond pas.
  static List<SectionModel> _defaultSections(AppLocalizations l10n) => [
    SectionModel(id: '', key: 'popular', displayName: l10n.sectionPopular, displayOrder: 0),
    SectionModel(id: '', key: 'tenues-africaines', displayName: l10n.sectionTenuesAfricaines, displayOrder: 1),
    SectionModel(id: '', key: 'sacs-a-main', displayName: l10n.sectionSacsAMain, displayOrder: 2),
    SectionModel(id: '', key: 'sports', displayName: l10n.sectionSports, displayOrder: 3),
  ];

  /// Construit les slivers des sections selon l'ordre configuré en BDD.
  /// Supporte les sections dynamiques ajoutées via l'admin.
  List<Widget> _buildSectionsSlivers(
    BuildContext context,
    WidgetRef ref,
    List<SectionModel> sections,
    String categoryFilterParam,
  ) {
    final slivers = <Widget>[];
    var colorOffset = 0;
    for (final s in sections) {
      final productsAsync = ref.watch(
        sectionProductsByCategoryProvider((s.key, categoryFilterParam)),
      );
      final publicitesAsync =
          s.key == 'popular' ? null : ref.watch(publicitesBySectionProvider(s.key));
      final onRetry = () =>
          ref.invalidate(sectionProductsByCategoryProvider((s.key, categoryFilterParam)));
      slivers.addAll(
        _buildProductSectionWithBand(
          context,
          productsAsync,
          publicitesAsync,
          s.displayName,
          s.key,
          colorOffset,
          onRetry,
        ),
      );
      colorOffset = (colorOffset + 1) % 3;
    }
    return slivers;
  }

  /// Résout le filtre catégorie : 'all' pour Tout (mélange), sinon UUID de la catégorie.
  static const Map<String, String> _slugAliases = {
    'enfants': 'kids',
    'enfant': 'kids',
    'hommes': 'men',
    'homme': 'men',
    'femmes': 'women',
    'femme': 'women',
  };

  String _resolveCategoryFilter(String selected, List<CategoryModel> categories) {
    if (selected.isEmpty ||
        selected == 'All' ||
        selected.toLowerCase() == 'all') {
      return 'all';
    }
    final slugNorm = selected.trim().toLowerCase();
    final slugToTry = _slugAliases[slugNorm] ?? slugNorm;
    for (final c in categories) {
      final cSlug = c.slug.trim().toLowerCase();
      if (cSlug == slugToTry || cSlug == slugNorm) {
        return c.id;
      }
    }
    return 'all';
  }

  /// Réordonne la liste pour que deux produits de même catégorie ne se suivent pas.
  /// Utilise section (type produit) puis categoryId (men/women/kids) comme critère.
  static List<ProductModel> _interleaveByCategory(List<ProductModel> products) {
    if (products.length <= 2) return products;
    final groups = <String, List<ProductModel>>{};
    for (final p in products) {
      final section = p.section ?? '';
      final category = p.categoryId ?? '';
      final key = section.isNotEmpty || category.isNotEmpty
          ? '$section|$category'
          : 'default';
      groups.putIfAbsent(key, () => []).add(p);
    }
    if (groups.length == 1) return products;
    final result = <ProductModel>[];
    var indices = <String, int>{};
    for (final k in groups.keys) indices[k] = 0;
    var lastKey = '';
    var added = 0;
    while (added < products.length) {
      String? chosen;
      for (final k in groups.keys) {
        if (k != lastKey && (indices[k] ?? 0) < groups[k]!.length) {
          chosen = k;
          break;
        }
      }
      if (chosen == null) {
        for (final k in groups.keys) {
          if ((indices[k] ?? 0) < groups[k]!.length) {
            chosen = k;
            break;
          }
        }
      }
      if (chosen == null) break;
      final group = groups[chosen]!;
      final idx = indices[chosen]!;
      result.add(group[idx]);
      indices[chosen] = idx + 1;
      lastKey = chosen;
      added++;
    }
    return result;
  }

  /// Section produit + bande publicitaire. La bande apparaît AU-DESSUS de la section
  /// qu'elle promeut. Si [publicitesAsync] est null (ex: Populaire), pas de bande.
  List<Widget> _buildProductSectionWithBand(
    BuildContext context,
    AsyncValue<List<ProductModel>> asyncProducts,
    AsyncValue<List<PubliciteModel>>? publicitesAsync,
    String sectionTitle,
    String sectionKey,
    int colorOffset,
    VoidCallback onRetry,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final r = context.responsive;

    return asyncProducts.when(
      data: (list) {
        if (list.isEmpty) return []; // Section vide : ni bande ni section
        // Section Populaire : évite que deux produits de même catégorie se suivent
        final ordered = sectionKey == 'popular'
            ? _interleaveByCategory(list)
            : list;
        final slivers = <Widget>[];

        // Bande en préfixe : au-dessus de la section qu'elle promeut
        final pubList = publicitesAsync?.valueOrNull ?? [];
        if (pubList.isNotEmpty) {
          slivers.add(
            SliverToBoxAdapter(child: PubliciteLedCarousel(publicites: pubList)),
          );
          slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 8)));
        }

        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                r.horizontalPadding,
                8,
                r.horizontalPadding,
                8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sectionTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: r.sectionTitleFontSize,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(
                      '${AppRoutes.productsSection}/$sectionKey',
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.seeAll,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const _AnimatedSeeAllArrow(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        slivers.add(_productList(context, ordered, colorOffset, sectionKey));
        slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 8)));
        return slivers;
      },
      loading: () => [],
      error: (err, _) => [
        SliverToBoxAdapter(
          child: ConnectionElegantPlaceholder(
            error: err,
            onRetry: onRetry,
            compact: true,
            useSliver: false,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
      ],
    );
  }

  Widget _productList(
    BuildContext context,
    List<ProductModel> list,
    int colorOffset,
    String sectionKey,
  ) {
    final r = context.responsive;
    final cardW = r.productCardWidthHorizontal;
    final imageH = r.productCardImageHeight(cardW);
    // Hauteur totale carte : image + padding + contenu (zone texte/prix/bouton)
    final rowHeight = imageH + (r.isCompactSmall ? 100 : 115);

    if (list.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: rowHeight,
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.noProducts,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }
    final gapBetweenCards = r.gap;
    final gapBetweenRows = r.gap;
    final rowCount = (list.length / 2).ceil();
    return SliverToBoxAdapter(
      key: ValueKey('home_products_$sectionKey'),
      child: SizedBox(
        height: rowHeight,
        child: ListView.builder(
          key: const ValueKey('home_horizontal_list'),
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.fromLTRB(
            r.horizontalPadding,
            0,
            r.horizontalPadding,
            12,
          ),
          itemCount: rowCount,
          itemBuilder: (context, rowIndex) {
            final i1 = rowIndex * 2;
            final i2 = rowIndex * 2 + 1;
            final product1 = list[i1];
            final product2 = i2 < list.length ? list[i2] : null;
            final color1 =
                _cardBackgroundColors[(i1 + colorOffset) %
                    _cardBackgroundColors.length];
            final dots1 = product1.colors
                .map((c) => _parseHexColor(c.hex))
                .toList();
            return Padding(
              key: ValueKey('row_${product1.id}_${product2?.id ?? ""}'),
              padding: EdgeInsets.only(right: gapBetweenRows),
              child: SizedBox(
                width: 2 * cardW + gapBetweenCards,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ProductCard(
                      key: ValueKey('${product1.id}-$i1'),
                      productId: product1.id,
                      heroTagSuffix: '$sectionKey-$i1',
                      width: cardW,
                      name: product1.name,
                      price: product1.price,
                      imageUrl: product1.firstImageUrl,
                      cardBackgroundColor: color1,
                      colorDots: dots1,
                      isFavorite: ref
                          .watch(favoritesProvider)
                          .contains(product1.id),
                      onTap: () => context.pushProductDetail(
                        product1.id,
                        imageUrl: product1.firstImageUrl,
                        heroSource: 'card',
                        heroTagSuffix: '$sectionKey-$i1',
                      ),
                      onAddCart: () =>
                          ref.read(cartProvider.notifier).addItem(product1.id),
                      onWishlist: () => ref
                          .read(favoritesProvider.notifier)
                          .toggle(product1.id),
                    ),
                    SizedBox(width: gapBetweenCards),
                    if (product2 != null)
                      ProductCard(
                        key: ValueKey('${product2.id}-$i2'),
                        productId: product2.id,
                        heroTagSuffix: '$sectionKey-$i2',
                        width: cardW,
                        name: product2.name,
                        price: product2.price,
                        imageUrl: product2.firstImageUrl,
                        cardBackgroundColor:
                            _cardBackgroundColors[(i2 + colorOffset) %
                                _cardBackgroundColors.length],
                        colorDots: product2.colors
                            .map((c) => _parseHexColor(c.hex))
                            .toList(),
                        isFavorite: ref
                            .watch(favoritesProvider)
                            .contains(product2.id),
                        onTap: () => context.pushProductDetail(
                          product2.id,
                          imageUrl: product2.firstImageUrl,
                          heroSource: 'card',
                          heroTagSuffix: '$sectionKey-$i2',
                        ),
                        onAddCart: () => ref
                            .read(cartProvider.notifier)
                            .addItem(product2.id),
                        onWishlist: () => ref
                            .read(favoritesProvider.notifier)
                            .toggle(product2.id),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Color _parseHexColor(String hex) {
    final h = hex.startsWith('#') ? hex.substring(1) : hex;
    if (h.length == 6) {
      return Color(int.parse('FF$h', radix: 16));
    }
    return const Color(0xFF9E9E9E);
  }
}

/// Nom de l'application en en-tête : style logo, élégant — responsive.
class _AppName extends StatelessWidget {
  const _AppName();

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final color = Theme.of(context).colorScheme.onSurface;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        'SOLMA',
        style: TextStyle(
          fontSize: r.isCompactSmall ? 18 : 24,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
          color: color,
          height: 1.2,
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.onPressed,
    this.showDot = false,
    this.isBlackBackground = false,
    this.badgeCount,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool showDot;
  final bool isBlackBackground;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showBadge = badgeCount != null && badgeCount! > 0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: AppShadows.chip(context),
          ),
          child: Material(
            color: isBlackBackground
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            shape: const CircleBorder(),
            elevation: 0,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: EdgeInsets.all(
                  context.responsive.isCompactSmall ? 9 : 11,
                ),
                child: Icon(
                  icon,
                  size: context.responsive.isCompactSmall ? 20 : 22,
                  color: isBlackBackground
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        if (showDot && !showBadge)
          Positioned(
            top: 6,
            right: 6,
            child: IgnorePointer(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        if (showBadge)
          Positioned(
            top: 2,
            right: 2,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    badgeCount! > 99 ? '99+' : '$badgeCount',
                    style: TextStyle(
                      color: theme.colorScheme.onError,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Flèche animée pour attirer l'attention vers "Tout voir"
class _AnimatedSeeAllArrow extends StatefulWidget {
  const _AnimatedSeeAllArrow();

  @override
  State<_AnimatedSeeAllArrow> createState() => _AnimatedSeeAllArrowState();
}

class _AnimatedSeeAllArrowState extends State<_AnimatedSeeAllArrow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _slideAnimation = Tween<double>(
      begin: 0,
      end: 6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Icon(
          Icons.arrow_right_alt,
          size: 24,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
