import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_constants.dart';
import '../utils/image_optimizer.dart';

/// Extensions pour une navigation fluide avec préchargement et Hero.
extension NavigationExtensions on BuildContext {
  /// Navigue vers le détail produit avec préchargement de l'image.
  ///
  /// [imageUrl] optionnel — si fourni, précharge l'image avant la transition
  /// pour une Hero animation plus fluide.
  Future<void> pushProductDetail(
    String productId, {
    String? imageUrl,
    String heroSource = 'card',
    String? heroTagSuffix,
  }) async {
    if (imageUrl?.isNotEmpty ?? false) {
      ImageOptimizer.preloadImages([imageUrl!], this);
    }
    push(
      AppPaths.product(productId),
      extra: {
        'heroSource': heroSource,
        ...? (heroTagSuffix != null ? {'heroTagSuffix': heroTagSuffix} : null),
      },
    );
  }
}
