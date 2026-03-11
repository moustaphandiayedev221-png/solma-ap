import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../constants/product_detail_constants.dart';

/// Miniatures horizontales pour sélectionner l'image ou la vidéo du carrousel.
/// Si [videoUrl] est fourni, une miniature vidéo (icône play) est affichée en dernier.
class ProductDetailThumbnails extends StatelessWidget {
  const ProductDetailThumbnails({
    super.key,
    required this.imageUrls,
    required this.selectedIndex,
    required this.onTap,
    this.videoUrl,
  });

  final List<String> imageUrls;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final String? videoUrl;

  int get _itemCount =>
      imageUrls.length + (videoUrl != null && videoUrl!.isNotEmpty ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const thumbW = ProductDetailConstants.thumbnailWidth;
    const thumbH = ProductDetailConstants.thumbnailHeight;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ProductDetailConstants.horizontalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_itemCount, (i) {
          final isActive = i == selectedIndex;
          final isVideo = videoUrl != null &&
              videoUrl!.isNotEmpty &&
              i == imageUrls.length;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: ProductDetailConstants.animationShort,
              margin: EdgeInsets.only(right: i < _itemCount - 1 ? 10 : 0),
              width: thumbW,
              height: thumbH,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.4),
                  width: isActive ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: isVideo
                    ? Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 28,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrls[i],
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => Icon(
                          Icons.image_not_supported,
                          size: 20,
                          color: theme.colorScheme.outline,
                        ),
                      ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
