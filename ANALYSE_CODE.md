# Analyse complète du code — SOLMA

**Projet :** Application e-commerce Flutter de chaussures premium
**Stack :** Flutter 3.10+ · Riverpod · Supabase · Stripe · Firebase (FCM)
**Date d'analyse :** 7 mars 2026
**Taille du code :** ~24 750 lignes Dart · 120 fichiers · 8 tests

---

## 1. Architecture globale

Le projet suit une **Clean Architecture simplifiée** avec séparation en features :

```
lib/
├── core/           → Config, thème, routing, widgets partagés, responsive, utils
├── features/       → Auth, Cart, Checkout, Category, Favorites, Home, Main Navigation,
│                     Notifications, Publicités, Onboarding, Product, Profile, Promo,
│                     Reviews, Search, Splash, Tracking
├── gen_l10n/       → Localisation (EN/FR)
└── main.dart       → Point d'entrée
```

Chaque feature contient `data/` (repositories, models) et `presentation/` (providers, screens, widgets). La feature checkout possède également une couche `domain/` avec un use case.

**Points forts :**

- Séparation nette data/presentation par feature
- Riverpod bien utilisé avec CartState immutable et des Notifiers à rollback
- Système responsive avec breakpoints (compact/medium/expanded)
- Localisation EN/FR intégrée via gen_l10n
- Firebase optionnel — ne bloque pas l'app si indisponible
- GoRouter avec protection de routes par session
- Debouncer sur les actions panier (évite le spam d'appels API)
- SessionManager avec détection d'expiration de token
- AppLogger centralisé (prêt pour Sentry/Crashlytics en production)

---

## 2. Améliorations notables (depuis le 3 mars)

Plusieurs problèmes critiques identifiés précédemment ont été corrigés :

| Problème | Statut |
|----------|--------|
| Notification dot inversé (`unreadCount == 0`) | ✅ Corrigé → `unreadCount > 0` |
| `urlSafe`/`anonKeySafe` étaient des no-ops (condition kDebugMode inutile) | ✅ Corrigé → alias simples |
| CartState ignorait les variantes size/color | ✅ Corrigé → `CartItemKey` avec productId + size + color |
| Optimistic updates sans rollback (cart, favorites) | ✅ Corrigé → rollback en cas d'erreur backend |
| Pas de debounce sur les actions panier | ✅ Corrigé → Debouncer 500ms par clé |
| wishlistProductsProvider en N+1 séquentiel | ✅ Corrigé → `Future.wait()` |
| Injection SQL dans la recherche (`%`, `_` non échappés) | ✅ Corrigé → `sanitizeLikeQuery()` |
| Erreurs silencieuses `catch (_) {}` | ✅ Amélioré → `debugPrint` + `AppLogger` |
| Pas de couche domain / use cases | ✅ Partiellement → `PlaceOrderUseCase` créé |
| Notifications codées en dur en français | ✅ Corrigé → `lookupAppLocalizations(Locale(languageCode))` |
| Repositories non injectables | ✅ Corrigé → constructeur optionnel `([SupabaseClient? client])` |

---

## 3. Problèmes restants

### 3.1 [P1] Clé Supabase anon en dur dans le code source

**Fichier :** `lib/core/config/supabase_config.dart` (lignes 16-18)

La clé anon est toujours commitée en fallback dev. Bien que la clé anon soit publique par design (Supabase RLS protège les données), c'est une mauvaise pratique — un attaquant peut utiliser cette clé pour tester les RLS policies ou abuser de quotas. Recommandation : utiliser exclusivement `--dart-define` ou un fichier `.env` local non commité.

### 3.2 [P1] OrderRepository — N+1 sur le chargement des commandes

**Fichier :** `lib/features/checkout/data/order_repository.dart` (lignes 62-96)

`getOrders()` charge les commandes puis fait un SELECT séquentiel par commande pour récupérer les items. Avec 20 commandes = 21 requêtes (1 + 20). Devrait utiliser un join Supabase (`select('*, order_items(*)')`) ou un `Future.wait()`.

### 3.3 [P1] OrderRepository — insertion séquentielle des items

**Fichier :** `lib/features/checkout/data/order_repository.dart` (lignes 125-134)

`createOrder()` insère les items un par un dans une boucle `for`. Un batch insert unique serait plus performant et atomique :

```dart
await _client.from(_itemsTable).insert(
  items.map((item) => { ... }).toList(),
);
```

### 3.4 [P2] PlaceOrderUseCase créé mais non utilisé

Le use case `PlaceOrderUseCase` existe dans `checkout/domain/` mais `CheckoutScreen._placeOrder()` contient toujours sa propre logique dupliquée. De plus, le use case ne gère pas les codes promo (contrairement au screen). L'intention est bonne mais la migration est incomplète.

### 3.5 [P2] WishlistRepository.toggle() — race condition persistante

**Fichier :** `lib/features/favorites/data/wishlist_repository.dart` (lignes 36-48)

Le toggle fait toujours SELECT → DELETE/INSERT sans transaction. Le `FavoritesNotifier` debounce côté UI mais deux toggles rapides peuvent quand même s'entrelacer au niveau réseau. Solution : utiliser un RPC Supabase côté serveur ou un upsert avec `ON CONFLICT`.

### 3.6 [P2] Frais de livraison en dur

**Fichier :** `lib/features/checkout/presentation/screens/checkout_screen.dart` (ligne 24)

Toujours codés en dur à 10.0. Le même montant est dupliqué dans `PlaceOrderUseCase` (paramètre par défaut). Devrait venir d'une config serveur ou au minimum d'une constante partagée unique.

### 3.7 [P2] StripePaymentService — singleton global non injectable

**Fichier :** `lib/features/checkout/data/stripe_payment_service.dart` (ligne 9)

Accède directement au `supabaseClient` global. Non injectable, non testable. De plus, une nouvelle instance est créée à chaque appel dans `CheckoutScreen` et `PlaceOrderUseCase` (`StripePaymentService()`) — devrait être un Provider singleton.

### 3.8 [P3] HomeScreen — rebuilds excessifs

`HomeScreen` watch simultanément 7+ providers. Chaque changement (ajout favori, notification, cart) reconstruit tout l'écran. Les sections devraient être des widgets `Consumer` isolés ou des `ConsumerWidget` séparés.

### 3.9 [P3] Pas de pagination effective dans le catalogue

`ProductRepository.getProductsPaginated()` existe mais aucun screen ne l'utilise. Les pages chargent des listes fixes (limit 12, 50, 80). Avec un catalogue croissant, les temps de chargement augmenteront. De plus, `getProductsPaginated` utilise `.range()` au lieu de `limit+1` pour détecter `hasMore`, ce qui peut renvoyer des résultats incorrects si la plage dépasse le nombre total.

### 3.10 [P3] GoRouter en singleton global

Le routeur est créé au top-level (`_appRouterInstance`) au lieu d'être directement dans le Provider. Fonctionne mais complique le testing et l'A/B testing de routes.

---

## 4. Sécurité

### 4.1 Validation des formulaires ✅ Présente

Le login et le signup valident l'email (contient `@`) et le mot de passe (min 6 caractères). C'est basique mais fonctionnel — Supabase applique ses propres validations côté serveur.

### 4.2 Session management ✅ Bien implémenté

`SessionManager` surveille l'expiration du JWT et programme un timer 30s avant expiration. Le `SessionExpirationListener` redirige vers le login si la session expire.

### 4.3 Protection des routes ✅ En place

Les routes sensibles (checkout, profil, adresses, etc.) sont protégées via le redirect GoRouter — un accès sans session redirige vers `/login`.

### 4.4 [Attention] OAuth redirect URL en dur

```dart
redirectTo: 'io.supabase.colways://login-callback/'
```

Ce deep link doit correspondre exactement à la configuration Supabase et aux URL schemes déclarés dans iOS/Android. Si ce n'est pas le cas, l'OAuth échouera silencieusement.

---

## 5. Performance

### 5.1 Points positifs

- Debounce 500ms sur les modifications de panier — réduit drastiquement les appels API
- `Future.wait()` pour charger les produits du panier et des favoris en parallèle
- Images en cache avec `CachedNetworkImage`
- Shimmer placeholders pendant le chargement (bon UX perçu)

### 5.2 Points d'amélioration

- **OrderRepository.getOrders** : requêtes N+1 (voir §3.2)
- **HomeScreen** : rebuilds excessifs (voir §3.8)
- **Images** : pas de `memCacheWidth`/`memCacheHeight` sur les `CachedNetworkImage`, consommation mémoire potentielle sur images haute résolution
- **cartItemsWithProductsProvider** : dépend de `cartProvider`, donc recharge tous les produits à chaque modification de quantité (même ceux inchangés). Un cache local par productId éviterait les requêtes redondantes.

---

## 6. Tests

Le projet contient **8 fichiers de test** :

| Fichier | Couverture |
|---------|-----------|
| `app_failure_test.dart` | AppFailure (toString, toAppFailure) |
| `app_logger_test.dart` | Logger centralisé |
| `debouncer_test.dart` | Debouncer (timing, dispose) |
| `cart_state_test.dart` | CartState immutable (add, remove, clear, variants) |
| `product_model_test.dart` | ProductModel (fromJson, firstImageUrl, colors) |
| `product_repository_test.dart` | sanitizeLikeQuery (caractères spéciaux SQL) |
| `address_model_test.dart` | AddressModel (parsing, singleLine, copyWith) |
| `widget_test.dart` | Smoke test basique |

**Ce qui manque :**

- Tests des Notifiers Riverpod (CartNotifier, FavoritesNotifier)
- Tests d'intégration (flux checkout, auth, recherche)
- Tests du PlaceOrderUseCase (le seul use case, et il n'est pas testé)
- Tests des edge cases réseau (timeout, erreurs serveur, rollback)
- Couverture estimée : **< 20%** (8 fichiers de test pour 120 fichiers source)

---

## 7. Qualité du code et patterns

### 7.1 Points forts

- Code bien commenté (en français, cohérent avec l'équipe)
- Naming conventions respectées (snake_case fichiers, PascalCase classes)
- Les providers suivent un pattern uniforme : état immutable → optimistic update → sync backend → rollback si échec
- Transitions d'animation soignées (fade + slide) avec des durées cohérentes
- Bonne gestion du dark mode avec une palette complète

### 7.2 Inconsistances mineures

- `AuthRepository` accepte un client injectable, `StripePaymentService` non
- `PlaceOrderUseCase` existe mais n'est pas branché dans le screen
- Le promoCode est géré dans `CheckoutScreen` mais absent du `PlaceOrderUseCase`
- Certaines listes utilisent `(res as List)` pour caster les réponses Supabase — un helper centralisé serait plus propre

---

## 8. Recommandations prioritaires

| Priorité | Action | Impact | Effort |
|----------|--------|--------|--------|
| **P1** | Corriger le N+1 dans `OrderRepository.getOrders()` (utiliser un join) | Performance | Faible |
| **P1** | Batch insert dans `OrderRepository.createOrder()` | Performance + atomicité | Faible |
| **P1** | Retirer les clés Supabase du code (forcer `--dart-define`) | Sécurité | Faible |
| **P2** | Brancher `PlaceOrderUseCase` dans `CheckoutScreen` et y ajouter les promos | Architecture | Moyen |
| **P2** | Rendre `StripePaymentService` injectable via un Provider | Testabilité | Faible |
| **P2** | Résoudre la race condition `WishlistRepository.toggle()` (RPC ou upsert) | Fiabilité | Moyen |
| **P2** | Isoler les sections HomeScreen en Consumer widgets séparés | Performance UI | Moyen |
| **P3** | Implémenter la pagination effective dans le catalogue | Scalabilité | Moyen |
| **P3** | Ajouter `memCacheWidth`/`memCacheHeight` aux images | Performance mémoire | Faible |
| **P3** | Augmenter la couverture de tests (objectif : > 40%) | Fiabilité | Élevé |
| **P3** | Mettre en place un monitoring production (Sentry/Crashlytics) dans AppLogger | Observabilité | Moyen |

---

## 9. Verdict global

**Le projet a significativement progressé** depuis la dernière analyse. La plupart des problèmes critiques (notification dot, cart sans variantes, pas de rollback, N+1 favoris, erreurs silencieuses) ont été corrigés. L'ajout du `Debouncer`, du `SessionManager`, de `AppLogger` et du `PlaceOrderUseCase` montre une maturation architecturale réelle.

Les points restants sont principalement des optimisations de performance (N+1 dans les commandes, rebuilds HomeScreen) et des finitions d'architecture (brancher le use case, rendre Stripe injectable). Avec les corrections P1/P2, le projet est prêt pour une mise en production sérieuse.

**Score de maturité : 7/10** (était ~5/10 début mars)
