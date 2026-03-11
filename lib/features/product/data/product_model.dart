/// Modèle produit (aligné sur la table Supabase products)
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.compareAtPrice,
    this.imageUrls = const [],
    this.videoUrl,
    this.sizes = const [],
    this.colors = const [],
    this.stock = 0,
    this.isFeatured = false,
    this.isNew = false,
    this.section,
    this.categoryId,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final double? compareAtPrice;
  final List<String> imageUrls;
  final String? videoUrl;
  final List<String> sizes;
  final List<ProductColor> colors;
  final int stock;
  final bool isFeatured;
  final bool isNew;
  final String? section;
  final String? categoryId;

  String? get firstImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  // Supprimé formattedPrice, utilisation directe du prix (double)
  // String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawUrls = json['image_urls'];
    final rawSizes = json['sizes'];
    final rawColors = json['colors'];

    final id = json['id'] as String?;
    final name = json['name'] as String?;
    final slug = json['slug'] as String?;
    final priceRaw = json['price'];
    if (id == null || name == null || slug == null || priceRaw == null) {
      throw FormatException(
        'ProductModel.fromJson: champs requis manquants (id, name, slug, price)',
        json,
      );
    }

    return ProductModel(
      id: id,
      name: name,
      slug: slug,
      description: json['description'] as String?,
      price: (priceRaw as num).toDouble(),
      compareAtPrice: json['compare_at_price'] != null
          ? (json['compare_at_price'] as num).toDouble()
          : null,
      imageUrls: rawUrls is List
          ? (rawUrls).map((e) => e.toString()).toList()
          : [],
      videoUrl: json['video_url'] as String?,
      sizes: rawSizes is List
          ? (rawSizes).map((e) => e.toString()).toList()
          : [],
      colors: _parseColors(rawColors),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      isNew: json['is_new'] as bool? ?? false,
      section: json['section'] as String?,
      categoryId: json['category_id'] as String?,
    );
  }

  /// Parse JSON en renvoyant null si les champs requis sont absents.
  static ProductModel? tryFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      return ProductModel.fromJson(json);
    } on FormatException catch (_) {
      return null;
    } on TypeError catch (_) {
      return null;
    }
  }

  static List<ProductColor> _parseColors(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map((e) {
          if (e is Map<String, dynamic>) {
            final name = e['name'] as String?;
            final hex = e['hex'] as String?;
            if (name != null && hex != null) {
              final rawUrls = e['image_urls'];
              final urls = rawUrls is List
                  ? (rawUrls).map((u) => u.toString()).where((u) => u.isNotEmpty).toList()
                  : <String>[];
              return ProductColor(name: name, hex: hex, imageUrls: urls);
            }
          }
          return null;
        })
        .whereType<ProductColor>()
        .toList();
  }
}

/// Couleur produit avec images associées (une couleur = une variante visuelle).
class ProductColor {
  const ProductColor({
    required this.name,
    required this.hex,
    this.imageUrls = const [],
  });

  final String name;
  final String hex;
  /// Images spécifiques à cette couleur (affichées quand l'utilisateur sélectionne cette couleur).
  final List<String> imageUrls;
}
