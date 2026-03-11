/// Section produit (popular, tenues-africaines, sacs-a-main, sports).
/// Le nom affiché et l'ordre sont configurables via l'admin.
class SectionModel {
  const SectionModel({
    required this.id,
    required this.key,
    required this.displayName,
    required this.displayOrder,
  });

  final String id;
  final String key;
  final String displayName;
  final int displayOrder;

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] as String,
      key: json['key'] as String,
      displayName: json['display_name'] as String,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
    );
  }
}
