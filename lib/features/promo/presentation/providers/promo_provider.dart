import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/promo_model.dart';
import '../../data/promo_repository.dart';

/// Repository provider pour les promotions.
final promoRepositoryProvider = Provider<PromoRepository>((ref) {
  return PromoRepository();
});

/// État du code promo appliqué dans le checkout.
@immutable
sealed class PromoState {
  const PromoState();
}

class PromoNone extends PromoState {
  const PromoNone();
}

class PromoLoading extends PromoState {
  const PromoLoading();
}

class PromoApplied extends PromoState {
  const PromoApplied({
    required this.promo,
    required this.discountAmount,
  });

  final PromoModel promo;
  final double discountAmount;
}

class PromoError extends PromoState {
  const PromoError(this.errorCode);

  final PromoErrorCode errorCode;
}

/// Notifier pour gérer l'application d'un code promo au checkout.
class PromoNotifier extends Notifier<PromoState> {
  @override
  PromoState build() => const PromoNone();

  /// Applique un code promo — valide côté backend.
  /// [userId] optionnel : utilisé pour max_uses_per_user.
  Future<void> applyCode(
    String code,
    double subtotal, {
    String? userId,
  }) async {
    if (code.trim().isEmpty) return;

    state = const PromoLoading();

    try {
      final repo = ref.read(promoRepositoryProvider);
      final promo = await repo.validateCode(code, subtotal, userId: userId);
      final discount = promo.calculateDiscount(subtotal);

      state = PromoApplied(promo: promo, discountAmount: discount);
    } on PromoValidationException catch (e) {
      state = PromoError(e.code);
    } catch (e) {
      debugPrint('[PromoNotifier] Unexpected error: $e');
      state = const PromoError(PromoErrorCode.notFound);
    }
  }

  /// Recalcule la réduction si le sous-total change (ex. modification panier).
  void recalculate(double subtotal) {
    final current = state;
    if (current is PromoApplied) {
      final discount = current.promo.calculateDiscount(subtotal);
      state = PromoApplied(promo: current.promo, discountAmount: discount);
    }
  }

  /// Retire le code promo appliqué.
  void clear() {
    state = const PromoNone();
  }
}

/// Provider du code promo (NotifierProvider).
final promoProvider = NotifierProvider<PromoNotifier, PromoState>(() {
  return PromoNotifier();
});

/// Montant de la réduction actuelle (0 si pas de promo).
final promoDiscountProvider = Provider<double>((ref) {
  final promo = ref.watch(promoProvider);
  if (promo is PromoApplied) return promo.discountAmount;
  return 0;
});
