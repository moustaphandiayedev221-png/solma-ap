import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_provider.dart';
import 'promo_model.dart';

/// Erreur de validation d'un code promo.
class PromoValidationException implements Exception {
  const PromoValidationException(this.code);
  final PromoErrorCode code;

  @override
  String toString() => 'PromoValidationException: $code';
}

enum PromoErrorCode {
  notFound,
  inactive,
  expired,
  notStarted,
  maxUsesReached,
  maxUsesPerUserReached,
  minOrderNotMet,
}

/// Repository pour les promotions — validation et utilisation des codes promo.
class PromoRepository {
  PromoRepository([SupabaseClient? client])
      : _client = client ?? supabaseClient;

  final SupabaseClient _client;
  static const String _table = 'promotions';

  /// Valide un code promo et retourne le modèle si valide.
  /// [userId] optionnel : requis pour vérifier max_uses_per_user.
  Future<PromoModel> validateCode(
    String code,
    double subtotal, {
    String? userId,
  }) async {
    final normalizedCode = code.trim().toUpperCase();

    final res = await _client
        .from(_table)
        .select()
        .eq('code', normalizedCode)
        .maybeSingle();

    if (res == null) {
      throw const PromoValidationException(PromoErrorCode.notFound);
    }

    final promo = PromoModel.fromJson(res);

    if (!promo.isActive) {
      throw const PromoValidationException(PromoErrorCode.inactive);
    }

    final now = DateTime.now();

    if (promo.startsAt != null && now.isBefore(promo.startsAt!)) {
      throw const PromoValidationException(PromoErrorCode.notStarted);
    }

    if (promo.expiresAt != null && now.isAfter(promo.expiresAt!)) {
      throw const PromoValidationException(PromoErrorCode.expired);
    }

    if (promo.maxUses != null && promo.currentUses >= promo.maxUses!) {
      throw const PromoValidationException(PromoErrorCode.maxUsesReached);
    }

    if (subtotal < promo.minOrderAmount) {
      throw const PromoValidationException(PromoErrorCode.minOrderNotMet);
    }

    if (userId != null &&
        promo.maxUsesPerUser != null &&
        promo.maxUsesPerUser! > 0) {
      final countRes = await _client
          .from('promotion_usages')
          .select('id')
          .eq('promotion_id', promo.id)
          .eq('user_id', userId);
      final count = (countRes as List).length;
      if (count >= promo.maxUsesPerUser!) {
        throw const PromoValidationException(
          PromoErrorCode.maxUsesPerUserReached,
        );
      }
    }

    return promo;
  }

  /// Incrémente le compteur d'utilisations du code promo.
  /// [userId] et [orderId] requis pour la RPC atomique et le suivi.
  Future<void> incrementUses(
    String promoId, {
    required String userId,
    String? orderId,
  }) async {
    try {
      await _client.rpc('increment_promo_uses', params: {
        'p_promo_id': promoId,
        'p_user_id': userId,
        'p_order_id': orderId,
      });
    } catch (_) {
      final current = await _client
          .from(_table)
          .select('current_uses, used_count')
          .eq('id', promoId)
          .single();
      final uses = (current['current_uses'] as num?)?.toInt() ??
          (current['used_count'] as num?)?.toInt() ??
          0;
      await _client
          .from(_table)
          .update({'current_uses': uses + 1})
          .eq('id', promoId);
    }
  }
}
