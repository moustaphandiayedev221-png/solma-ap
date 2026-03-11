/// Modèle pour une publicité — image, liens, et section associée.
class PubliciteModel {
  const PubliciteModel({
    required this.id,
    required this.imageUrl,
    this.productId,
    this.linkUrl,
    this.section = 'popular',
  });

  final String id;
  final String imageUrl;
  final String? productId;
  final String? linkUrl;
  /// Section produit : popular, tenues-africaines, sacs-a-main, sports
  final String section;

  factory PubliciteModel.fromJson(Map<String, dynamic> json) {
    return PubliciteModel(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String? ?? '',
      productId: json['product_id'] as String?,
      linkUrl: json['link_url'] as String?,
      section: json['section'] as String? ?? 'popular',
    );
  }
}
