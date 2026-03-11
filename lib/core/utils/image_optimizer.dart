import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../gen_l10n/app_localizations.dart';

/// Utilitaire pour optimiser les images et gérer les assets
class ImageOptimizer {
  ImageOptimizer._();

  /// Convertit une valeur double en int de manière sécurisée
  static int? _safeToInt(double? value) {
    if (value == null) return null;
    if (value.isInfinite || value.isNaN) return null;
    if (value <= 0) return null;
    return value.clamp(0, double.maxFinite.toInt()).toInt();
  }

  /// Configuration par défaut pour CachedNetworkImage
  static ImageProvider defaultNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CachedNetworkImageProvider(
      imageUrl,
      maxWidth: _safeToInt(width),
      maxHeight: _safeToInt(height),
    );
  }

  /// Widget optimisé pour les images réseau
  static Widget optimizedNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    PlaceholderWidgetBuilder? placeholder,
    LoadingErrorWidgetBuilder? errorWidget,
    Duration fadeInDuration = const Duration(milliseconds: 300),
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      placeholder: placeholder ?? (context, url) => _defaultPlaceholder(context),
      errorWidget: errorWidget ?? (context, url, error) => _defaultErrorWidget(context),
      memCacheWidth: _safeToInt(width),
      memCacheHeight: _safeToInt(height),
      cacheKey: _generateCacheKey(imageUrl, width, height),
    );
  }

  /// Widget pour les images locales avec différentes densités
  static Widget optimizedAssetImage({
    required String assetPath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: _safeToInt(width),
      cacheHeight: _safeToInt(height),
      filterQuality: FilterQuality.medium,
    );
  }

  /// Placeholder par défaut — adapté au thème (light/dark)
  static Widget _defaultPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  /// Widget d'erreur par défaut — adapté au thème (light/dark)
  static Widget _defaultErrorWidget(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final message = AppLocalizations.of(context)?.imageUnavailable ?? 'Image unavailable';
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Génère une clé de cache unique
  static String _generateCacheKey(String url, double? width, double? height) {
    final key = '${url}_${width ?? 'auto'}_${height ?? 'auto'}';
    return key.hashCode.toString();
  }

  /// Dimensions optimisées selon le contexte
  static Size getOptimalSize({
    required BuildContext context,
    double? maxWidth,
    double? maxHeight,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Size(
      (maxWidth ?? screenSize.width) * pixelRatio,
      (maxHeight ?? screenSize.height) * pixelRatio,
    );
  }

  /// Nettoie le cache des images
  static Future<void> clearImageCache() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Précharge les images critiques
  static Future<void> preloadImages(
    List<String> imageUrls,
    BuildContext context,
  ) async {
    for (final url in imageUrls) {
      try {
        await precacheImage(CachedNetworkImageProvider(url), context);
      } catch (e) {
        // Ignorer les erreurs de préchargement
      }
    }
  }
}
