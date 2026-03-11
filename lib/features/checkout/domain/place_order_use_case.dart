import '../../../core/utils/app_logger.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../../checkout/data/order_repository.dart';
import '../../checkout/data/stripe_payment_service.dart';
import '../../notifications/data/notifications_repository.dart';
import '../../../core/config/env_config.dart';
import '../../profile/data/address_model.dart';

/// Résultat du placement de commande.
enum PlaceOrderResult { success, cancelled, noItems, noAddress, error }

/// Use case encapsulant toute la logique de placement de commande.
///
/// Centralise :
/// - Validation (panier non vide, adresse définie)
/// - Calcul du total (sous-total + livraison)
/// - Paiement Stripe si carte sélectionnée
/// - Création de la commande en base
/// - Notification de confirmation
class PlaceOrderUseCase {
  const PlaceOrderUseCase({
    required this.orderRepository,
    required this.notificationsRepository,
    this.shippingCost = 10.0,
  });

  final OrderRepository orderRepository;
  final NotificationsRepository notificationsRepository;
  final double shippingCost;

  static const String _tag = 'PlaceOrderUseCase';

  /// Exécute le placement de commande.
  ///
  /// [items] : lignes du panier avec produit et quantité.
  /// [userId] : ID de l'utilisateur authentifié.
  /// [defaultAddress] : adresse de livraison par défaut (null = pas d'adresse).
  /// [paymentMethod] : 'delivery', 'mobileMoney', ou 'card'.
  /// [languageCode] : code langue pour la notification ('fr', 'en'). Par défaut 'fr'.
  Future<PlaceOrderResult> execute({
    required List<CartItemWithProduct> items,
    required String userId,
    AddressModel? defaultAddress,
    required String paymentMethod,
    String languageCode = 'fr',
  }) async {
    // 1. Validation
    if (items.isEmpty) return PlaceOrderResult.noItems;
    if (defaultAddress == null) return PlaceOrderResult.noAddress;

    try {
      // 2. Calcul du total
      final subtotal =
          items.fold<double>(0, (sum, line) => sum + line.lineTotal);
      final total = subtotal + shippingCost;

      // 3. Paiement Stripe si carte
      if (paymentMethod == 'card' &&
          EnvConfig.stripePublishableKey.isNotEmpty) {
        final paid = await StripePaymentService().presentPaymentSheet(
          amountCents: (total * 100).round(),
          currency: 'eur',
          merchantDisplayName: 'SOLMA',
        );
        if (!paid) return PlaceOrderResult.cancelled;
      }

      // 4. Construction des lignes de commande
      final orderItems = items
          .map((e) => OrderItemModel(
                productId: e.product.id,
                name: e.product.name,
                price: e.product.price,
                quantity: e.quantity,
                size: e.size.isNotEmpty ? e.size : null,
                color: e.color.isNotEmpty ? e.color : null,
              ))
          .toList();

      final address = {
        'full_name': defaultAddress.fullName,
        'line1': defaultAddress.line1,
        'line2': defaultAddress.line2,
        'city': defaultAddress.city,
        'postal_code': defaultAddress.postalCode,
        'country': defaultAddress.country,
        'phone': defaultAddress.phone,
      };

      // 5. Création de la commande
      final orderId = await orderRepository.createOrder(
        userId: userId,
        total: total,
        shippingAddress: address,
        items: orderItems,
      );

      // 6. Notification (non bloquante)
      try {
        await notificationsRepository.notifyOrderPlaced(
          userId: userId,
          orderId: orderId,
          total: total,
          itemsCount: orderItems.length,
          languageCode: languageCode,
        );
      } catch (e) {
        AppLogger.warn(_tag, 'Order notification failed: $e');
      }

      return PlaceOrderResult.success;
    } catch (e, st) {
      AppLogger.error(_tag, 'Order placement failed', e, st);
      return PlaceOrderResult.error;
    }
  }
}
