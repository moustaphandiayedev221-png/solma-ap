import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/swipe_back_detector.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/error_retry_widget.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../main_navigation/providers/main_nav_index_provider.dart';
import '../../../reviews/presentation/widgets/reviews_section.dart';
import '../../data/product_model.dart';
import '../constants/product_detail_constants.dart';
import '../providers/product_provider.dart';
import '../widgets/product_detail/product_detail_bottom_actions.dart';
import '../widgets/product_detail/product_detail_carousel_indicators.dart';
import '../widgets/product_detail/product_detail_color_section.dart';
import '../widgets/product_detail/product_detail_description.dart';
import '../widgets/product_detail/product_detail_image_carousel.dart';
import '../widgets/product_detail/product_detail_product_info.dart';
import '../widgets/product_detail/product_detail_size_section.dart';
import '../widgets/product_detail/product_detail_specifications.dart';
import '../widgets/product_detail/product_detail_tabs.dart';
import '../widgets/product_detail/product_detail_thumbnails.dart';

/// Provider pour la quantité, la taille et la couleur sélectionnées.
final _quantityProvider = StateProvider<int>((ref) => 1);
final _selectedSizeIndexProvider = StateProvider<int>((ref) => 0);
final _selectedColorIndexProvider = StateProvider<int>((ref) => 0);
final _selectedTabIndexProvider = StateProvider<int>((ref) => 0);

/// Page détail produit — version originale avec onglets et avis.
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.heroSource = 'card',
    this.heroTagSuffix,
  });

  final String productId;
  final String heroSource;
  final String? heroTagSuffix;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _selectedImageIndex = 0;
  String? _lastProductId;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final productAsync = ref.watch(productByIdProvider(widget.productId));

    return SwipeBackDetector(
      onSwipeBack: () => context.pop(),
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        title: productAsync.valueOrNull != null
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  productAsync.valueOrNull!.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : const Text(''),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        actions: [
          if (productAsync.valueOrNull != null)
            IconButton(
              icon: Icon(
                ref.watch(favoritesProvider).contains(productAsync.valueOrNull!.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: ref.watch(favoritesProvider).contains(productAsync.valueOrNull!.id)
                    ? Colors.red.shade400
                    : null,
              ),
              onPressed: () {
                if (productAsync.valueOrNull != null) {
                  ref.read(favoritesProvider.notifier).toggle(productAsync.valueOrNull!.id);
                }
              },
            ),
        ],
      ),
      body: productAsync.when(
        data: (product) => product == null
            ? _buildError()
            : _buildBody(context, l10n, product),
        loading: () => const AppPageLoader(),
        error: (err, _) => ErrorRetryWidget(
          error: err,
          onRetry: () =>
              ref.invalidate(productByIdProvider(widget.productId)),
          compact: true,
        ),
      ),
      ),
    );
  }

  void _addToCartAndNavigate(
    BuildContext context,
    AppLocalizations l10n,
    ProductModel product,
    List<String> sizes,
    List<ProductColor> colors,
    bool hasProductSizes,
    bool hasProductColors, {
    required bool goToCheckout,
  }) {
    final selectedSizeIndex = ref.read(_selectedSizeIndexProvider);
    final selectedColorIndex = ref.read(_selectedColorIndexProvider);

    if (hasProductSizes && (selectedSizeIndex < 0 || selectedSizeIndex >= sizes.length)) {
      AppToast.show(context, message: l10n.pleaseSelectSize);
      return;
    }
    if (hasProductColors && (selectedColorIndex < 0 || selectedColorIndex >= colors.length)) {
      AppToast.show(context, message: l10n.pleaseSelectColour);
      return;
    }

    final size = selectedSizeIndex >= 0 ? sizes[selectedSizeIndex] : '';
    final color = selectedColorIndex >= 0 && selectedColorIndex < colors.length
        ? colors[selectedColorIndex].name
        : '';
    final q = ref.read(_quantityProvider);

    for (var i = 0; i < q; i++) {
      ref.read(cartProvider.notifier).addItem(
            product.id,
            size: size,
            color: color,
          );
    }
    if (goToCheckout) {
      context.push(AppRoutes.checkout);
    } else {
      ref.read(mainNavIndexProvider.notifier).state = 3;
      context.go(AppRoutes.main);
    }
  }

  Widget _buildError() {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.productNotFound,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    ProductModel product,
  ) {
    final selectedColorIndex = ref.watch(_selectedColorIndexProvider);
    final hasColorImages = product.colors.isNotEmpty &&
        selectedColorIndex >= 0 &&
        selectedColorIndex < product.colors.length &&
        product.colors[selectedColorIndex].imageUrls.isNotEmpty;
    final imageUrls = hasColorImages
        ? product.colors[selectedColorIndex].imageUrls
        : (product.imageUrls.isNotEmpty
            ? product.imageUrls
            : ProductDetailConstants.defaultImageUrls);
    final hasVideo =
        product.videoUrl != null && product.videoUrl!.trim().isNotEmpty;
    final itemCount = imageUrls.length + (hasVideo ? 1 : 0);
    final quantity = ref.watch(_quantityProvider);
    final selectedSizeIndex = ref.watch(_selectedSizeIndexProvider);
    final selectedTabIndex = ref.watch(_selectedTabIndexProvider);
    final colors = product.colors.isNotEmpty
        ? product.colors
        : <ProductColor>[];
    final sizes = product.sizes.isNotEmpty
        ? product.sizes
        : ProductDetailConstants.defaultSizes;
    final hasProductSizes = product.sizes.isNotEmpty;
    final hasProductColors = product.colors.isNotEmpty;

    // Réinitialiser taille/couleur quand on change de produit
    if (_lastProductId != widget.productId) {
      _lastProductId = widget.productId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(_selectedSizeIndexProvider.notifier).state =
            hasProductSizes ? -1 : 0;
        ref.read(_selectedColorIndexProvider.notifier).state =
            hasProductColors ? -1 : 0;
      });
    }

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      children: [
                        ProductDetailImageCarousel(
                          productId: product.id,
                          heroSource: widget.heroSource,
                          heroTagSuffix: widget.heroTagSuffix,
                          imageUrls: imageUrls,
                          videoUrl: product.videoUrl,
                          pageController: _pageController,
                          onPageChanged: (i) =>
                              setState(() => _selectedImageIndex = i),
                        ),
                        const SizedBox(height: 12),
                        _FadeInContent(
                          child: ProductDetailThumbnails(
                          imageUrls: imageUrls,
                          videoUrl: product.videoUrl,
                          selectedIndex: _selectedImageIndex,
                          onTap: (i) {
                            setState(() => _selectedImageIndex = i);
                            _pageController.animateToPage(
                              i,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                      ],
                    ),
                    if (colors.isNotEmpty)
                      Positioned(
                        left: 16,
                        top: 80,
                        child: ProductDetailColorSection(
                          colors: colors,
                          selectedIndex: selectedColorIndex,
                          onColorSelected: (i) {
                            ref.read(_selectedColorIndexProvider.notifier).state = i;
                            _pageController.jumpToPage(0);
                            setState(() => _selectedImageIndex = 0);
                          },
                        ),
                      ),
                    Positioned(
                      right: 12,
                      top: 80,
                      child: ProductDetailCarouselIndicators(
                          itemCount: itemCount,
                          currentIndex: _selectedImageIndex,
                          onTap: (i) {
                            setState(() => _selectedImageIndex = i);
                            _pageController.animateToPage(
                              i,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _FadeInContent(
                  child:                 ProductDetailProductInfo(
                  product: product,
                  heroSource: widget.heroSource,
                  heroTagSuffix: widget.heroTagSuffix,
                  quantity: quantity,
                  onQuantityChanged: (q) =>
                      ref.read(_quantityProvider.notifier).state = q,
                ),
                ),
                const SizedBox(height: 20),
                _FadeInContent(
                  child: ProductDetailSizeSection(
                  product: product,
                  selectedIndex: selectedSizeIndex,
                  onSizeSelected: (i) =>
                      ref.read(_selectedSizeIndexProvider.notifier).state = i,
                ),
                ),
                const SizedBox(height: 24),
                _FadeInContent(
                  child: ProductDetailTabs(
                  selectedIndex: selectedTabIndex,
                  onTap: (i) =>
                      ref.read(_selectedTabIndexProvider.notifier).state = i,
                ),
                ),
                const SizedBox(height: 16),
                _FadeInContent(
                  child: _buildTabContent(
                  context,
                  product,
                  selectedTabIndex,
                  sizes,
                  selectedSizeIndex,
                ),
                ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ProductDetailBottomActions(
          onBuyNow: () => _addToCartAndNavigate(
            context,
            l10n,
            product,
            sizes,
            colors,
            hasProductSizes,
            hasProductColors,
            goToCheckout: true,
          ),
          onCartTap: () => _addToCartAndNavigate(
            context,
            l10n,
            product,
            sizes,
            colors,
            hasProductSizes,
            hasProductColors,
            goToCheckout: false,
          ),
        ),
        ),
      ],
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    ProductModel product,
    int selectedTabIndex,
    List<String> sizes,
    int selectedSizeIndex,
  ) {
    switch (selectedTabIndex) {
      case 0:
        return ProductDetailDescription(product: product);
      case 1:
        return ProductDetailSpecifications(product: product);
      case 2:
        return ProfessionalReviewsSection(
          productId: product.id,
          showTitle: false,
        );
      default:
        return ProductDetailDescription(product: product);
    }
  }
}

/// Fade-in léger pour le contenu sous le carousel Hero.
class _FadeInContent extends StatelessWidget {
  const _FadeInContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(opacity: value, child: child!),
      child: child,
    );
  }
}
