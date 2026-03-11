import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_loader.dart';
import 'product_image_zoom_sheet.dart';
import '../../constants/product_detail_constants.dart';
import 'product_detail_video_player.dart';

/// Carrousel d'images produit.
/// Si [videoUrl] est fourni, une vidéo illustrative est affichée en dernier
/// (à droite après le défilement de toutes les images).
/// [productId] requis pour Hero animation (première image).
class ProductDetailImageCarousel extends StatelessWidget {
  const ProductDetailImageCarousel({
    super.key,
    required this.productId,
    this.heroSource = 'card',
    this.heroTagSuffix,
    required this.imageUrls,
    required this.pageController,
    required this.onPageChanged,
    this.videoUrl,
  });

  final String productId;
  final String heroSource;
  final String? heroTagSuffix;
  final List<String> imageUrls;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final String? videoUrl;

  int get _itemCount => imageUrls.length + (videoUrl != null && videoUrl!.isNotEmpty ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: ProductDetailConstants.imageCarouselHeight,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: onPageChanged,
        itemCount: _itemCount,
        padEnds: false,
        itemBuilder: (context, index) {
          if (videoUrl != null && videoUrl!.isNotEmpty && index == imageUrls.length) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
              ),
              child: Center(
                child: ProductDetailVideoPlayer(videoUrl: videoUrl!),
              ),
            );
          }
          final imageWidget = CachedNetworkImage(
            imageUrl: imageUrls[index],
            height: ProductDetailConstants.imageHeight,
            fit: BoxFit.contain,
            placeholder: (context, url) => _LoadingPlaceholder(theme: theme),
            errorWidget: (context, url, error) =>
                _ErrorPlaceholder(theme: theme),
          );
          final wrappedImage = index == 0
              ? Hero(
                  tag: 'product-image-$heroSource-$productId${heroTagSuffix != null ? '-$heroTagSuffix' : ''}',
                  child: imageWidget,
                )
              : imageWidget;
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
            ),
            child: Center(
              child: GestureDetector(
                onTap: () => showProductImageZoomSheet(
                  context,
                  imageUrl: imageUrls[index],
                ),
                child: wrappedImage,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ProductDetailConstants.imageHeight,
      child: Center(
        child: AppLoader(size: 28, color: theme.colorScheme.primary),
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ProductDetailConstants.imageHeight,
      child: Icon(
        Icons.image_not_supported,
        size: 80,
        color: theme.colorScheme.outline,
      ),
    );
  }
}
