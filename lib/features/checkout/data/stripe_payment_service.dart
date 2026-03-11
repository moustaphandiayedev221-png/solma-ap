import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../core/providers/supabase_provider.dart';

/// Crée un PaymentIntent via la Edge Function Supabase et présente la Payment Sheet Stripe.
/// La fonction doit être déployée et STRIPE_SECRET_KEY configuré dans les secrets Supabase.
class StripePaymentService {
  StripePaymentService();

  final _client = supabaseClient;
  static const String _functionName = 'create-payment-intent';

  /// amountCents: montant total en centimes (ex. 2999 = 29.99€).
  /// currency: 'eur' ou 'usd'.
  /// Retourne true si le paiement a été confirmé, false si annulé, lance en cas d'erreur.
  Future<bool> presentPaymentSheet({
    required int amountCents,
    String currency = 'eur',
    String? merchantDisplayName,
  }) async {
    final res = await _client.functions.invoke(
      _functionName,
      body: {'amount': amountCents, 'currency': currency},
    );
    if (res.status != 200) {
      throw Exception(res.data?['error'] ?? 'Payment intent failed');
    }
    final data = res.data as Map<String, dynamic>?;
    final clientSecret = data?['paymentIntent'] as String?;
    if (clientSecret == null || clientSecret.isEmpty) {
      throw Exception('Missing payment intent');
    }
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: merchantDisplayName ?? 'SOLMA',
      ),
    );
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return false;
      rethrow;
    }
  }
}
