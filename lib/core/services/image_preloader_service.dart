import 'package:flutter/material.dart';
import '../utils/image_optimizer.dart';
import '../config/image_config.dart';

/// Service pour précharger les images critiques selon le contexte
class ImagePreloaderService {
  ImagePreloaderService._();

  static final List<String> _criticalImages = [
    ImageConfig.bannerImages['best_sale']!['medium']!,
    ImageConfig.bannerImages['new_collection']!['medium']!,
    ImageConfig.bannerImages['free_shipping']!['medium']!,
    ImageConfig.bannerImages['exclusive']!['medium']!,
  ];

  /// Précharge les images du banner carousel
  static Future<void> preloadBannerImages(BuildContext context) async {
    // Pour l'instant, on précharge toutes les images critiques
    // TODO: Ajouter la détection de connexion quand connectivity_plus sera ajouté
    await ImageOptimizer.preloadImages(_criticalImages, context);
  }

  /// Précharge les images des produits populaires
  static Future<void> preloadPopularProducts(
    List<String> productImageUrls,
    BuildContext context,
  ) async {
    if (productImageUrls.isEmpty) return;

    // Limiter à 5 images pour éviter la surcharge
    final limitedUrls = productImageUrls.take(5).toList();
    await ImageOptimizer.preloadImages(limitedUrls, context);
  }

  /// Nettoie le cache si nécessaire (appelé en cas de mémoire faible)
  static Future<void> clearCacheIfNeeded() async {
    final imageCache = PaintingBinding.instance.imageCache;

    // Si le cache contient plus de 100 images, nettoyer
    if (imageCache.currentSize > 100) {
      await ImageOptimizer.clearImageCache();
    }
  }

  /// Obtient la taille d'image optimale selon le contexte
  static Size getOptimalBannerSize(BuildContext context) {
    return ImageOptimizer.getOptimalSize(
      context: context,
      maxWidth: MediaQuery.of(context).size.width * 0.9,
      maxHeight: ImageConfig.bannerHeight,
    );
  }

  static Size getOptimalProductCardSize(BuildContext context) {
    return ImageOptimizer.getOptimalSize(
      context: context,
      maxWidth: ImageConfig.productCardWidth,
      maxHeight: ImageConfig.productCardHeight,
    );
  }
}
