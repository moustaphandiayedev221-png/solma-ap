/// Configuration centralisée pour les images et assets
class ImageConfig {
  ImageConfig._();

  // URLs des images du banner carousel avec différentes tailles
  static const Map<String, Map<String, String>> bannerImages = {
    'best_sale': {
      'small': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200',
      'medium': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
      'large': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
    },
    'new_collection': {
      'small': 'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=200',
      'medium': 'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=400',
      'large': 'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=800',
    },
    'free_shipping': {
      'small': 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=200',
      'medium': 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=400',
      'large': 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=800',
    },
    'exclusive': {
      'small': 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=200',
      'medium': 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=400',
      'large': 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=800',
    },
  };

  // Assets locaux
  static const String logo = 'assets/images/logo.png';
  static const String placeholderShoe = 'assets/images/placeholder_shoe.png';
  static const String appIcon = 'assets/icons/app_icon.png';

  // Dimensions optimisées selon le contexte
  static const double bannerHeight = 196;
  static const double productCardHeight = 158;
  static const double productCardWidth = 200;
  static const double thumbnailSize = 60;

  // Qualité d'image selon le type de réseau
  static ImageQuality getImageQuality(bool isWifi) {
    return isWifi ? ImageQuality.high : ImageQuality.medium;
  }
}

enum ImageQuality {
  low(0.6),
  medium(0.8),
  high(1.0);

  const ImageQuality(this.value);
  final double value;
}
