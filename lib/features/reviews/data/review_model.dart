/// Modèle d'un avis produit.
class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    this.comment,
    this.title,
    this.pros,
    this.cons,
    this.verifiedPurchase = false,
    this.helpfulCount = 0,
    this.notHelpfulCount = 0,
    this.userVote,
    required this.createdAt,
    this.updatedAt,
    this.userFullName,
  });

  final String id;
  final String productId;
  final String userId;

  /// Note de 1 à 5 étoiles.
  final int rating;

  /// Commentaire optionnel.
  final String? comment;

  /// Titre de l'avis.
  final String? title;

  /// Points positifs (optionnel).
  final String? pros;

  /// Points négatifs (optionnel).
  final String? cons;

  /// Achat vérifié (l'utilisateur a acheté le produit).
  final bool verifiedPurchase;

  /// Nombre de "utile".
  final int helpfulCount;

  /// Nombre de "pas utile".
  final int notHelpfulCount;

  /// Vote de l'utilisateur courant (true = utile, false = pas utile, null = pas voté).
  final bool? userVote;

  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Nom de l'utilisateur (jointure avec profiles).
  final String? userFullName;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'];
    String? fullName;
    if (profiles is Map<String, dynamic>) {
      fullName = profiles['full_name'] as String?;
    }

    return ReviewModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      userId: json['user_id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      title: json['title'] as String?,
      pros: json['pros'] as String?,
      cons: json['cons'] as String?,
      verifiedPurchase: json['verified_purchase'] as bool? ?? false,
      helpfulCount: (json['helpful_count'] as num?)?.toInt() ?? 0,
      notHelpfulCount: (json['not_helpful_count'] as num?)?.toInt() ?? 0,
      userVote: null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      userFullName: fullName,
    );
  }

  ReviewModel copyWith({
    int? helpfulCount,
    int? notHelpfulCount,
    bool? userVote,
  }) {
    return ReviewModel(
      id: id,
      productId: productId,
      userId: userId,
      rating: rating,
      comment: comment,
      title: title,
      pros: pros,
      cons: cons,
      verifiedPurchase: verifiedPurchase,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      notHelpfulCount: notHelpfulCount ?? this.notHelpfulCount,
      userVote: userVote,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userFullName: userFullName,
    );
  }
}
