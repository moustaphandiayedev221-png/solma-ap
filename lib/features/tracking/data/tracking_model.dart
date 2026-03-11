/// Modèle d'un événement de suivi de commande.
class TrackingModel {
  const TrackingModel({
    required this.id,
    required this.orderId,
    required this.status,
    this.description,
    this.location,
    required this.createdAt,
  });

  final String id;
  final String orderId;

  /// Statut du tracking (ex. 'paid', 'confirmed', 'preparing', 'shipped', 'delivering', 'delivered')
  final String status;

  /// Description détaillée de l'événement.
  final String? description;

  /// Lieu associé (ex. centre de tri, adresse).
  final String? location;

  final DateTime createdAt;

  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    return TrackingModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Les étapes possibles du suivi de commande, dans l'ordre logique.
enum TrackingStatus {
  paid('paid'),
  confirmed('confirmed'),
  preparing('preparing'),
  shipped('shipped'),
  delivering('delivering'),
  delivered('delivered');

  const TrackingStatus(this.value);
  final String value;

  /// Retourne l'index de cette étape (0 = première).
  int get stepIndex => TrackingStatus.values.indexOf(this);

  /// Parse un statut string en enum. Retourne null si inconnu.
  static TrackingStatus? fromString(String? value) {
    if (value == null) return null;
    return TrackingStatus.values.where((e) => e.value == value).firstOrNull;
  }
}
