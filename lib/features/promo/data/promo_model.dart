/// Modèle de promotion / code promo.
class PromoModel {
  const PromoModel({
    required this.id,
    required this.code,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount = 0,
    this.maxUses,
    this.maxUsesPerUser,
    this.currentUses = 0,
    this.startsAt,
    this.expiresAt,
    this.isActive = true,
  });

  final String id;
  final String code;
  final String? description;

  /// 'percentage' ou 'fixed'
  final String discountType;

  /// Valeur de la réduction (pourcentage ou montant fixe)
  final double discountValue;

  /// Montant minimum de commande pour appliquer le code
  final double minOrderAmount;

  /// Nombre max d'utilisations (null = illimité)
  final int? maxUses;

  /// Max d'utilisations par utilisateur (null = illimité, 1 = un par client type Amazon)
  final int? maxUsesPerUser;

  /// Nombre actuel d'utilisations
  final int currentUses;

  /// Date de début de validité
  final DateTime? startsAt;

  /// Date d'expiration
  final DateTime? expiresAt;

  /// Le code est-il actif ?
  final bool isActive;

  /// Calcule le montant de la réduction pour un sous-total donné.
  double calculateDiscount(double subtotal) {
    if (discountType == 'percentage' || discountType == 'percent') {
      return (subtotal * discountValue / 100).clamp(0, subtotal);
    }
    return discountValue.clamp(0, subtotal);
  }

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    return PromoModel(
      id: json['id'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      discountType: json['discount_type'] as String,
      discountValue: (json['discount_value'] as num).toDouble(),
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ??
          (json['min_order'] as num?)?.toDouble() ?? 0,
      maxUses: json['max_uses'] as int?,
      maxUsesPerUser: json['max_uses_per_user'] as int?,
      currentUses: (json['current_uses'] as num?)?.toInt() ??
          (json['used_count'] as num?)?.toInt() ?? 0,
      startsAt: json['starts_at'] != null
          ? DateTime.parse(json['starts_at'] as String)
          : json['valid_from'] != null
              ? DateTime.parse(json['valid_from'] as String)
              : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : json['valid_until'] != null
              ? DateTime.parse(json['valid_until'] as String)
              : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
