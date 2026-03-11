# Edge Function : create-payment-intent

Crée un **Stripe PaymentIntent** et retourne le `client_secret` pour la Payment Sheet côté Flutter.

## Déploiement

1. **Secret Stripe**  
   Dans le dashboard Supabase : **Project Settings → Edge Functions → Secrets**  
   Ajouter : `STRIPE_SECRET_KEY` = clé secrète Stripe (sk_test_... ou sk_live_...).

2. **Déployer la fonction**  
   ```bash
   supabase functions deploy create-payment-intent
   ```

3. **Côté Flutter**  
   Passer la clé publishable Stripe en `--dart-define` :
   ```bash
   flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...
   ```

## Corps de la requête

- `amount` (number) : montant en **centimes** (ex. 2999 = 29,99 €).
- `currency` (string, optionnel) : `eur` par défaut.

## Réponse

- `paymentIntent` (string) : `client_secret` du PaymentIntent pour `Stripe.instance.initPaymentSheet(...)`.
