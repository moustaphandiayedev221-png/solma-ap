# Analyse professionnelle du codebase Colways

> Document généré pour améliorer la robustesse et le niveau professionnel de l'application.

---

## Vue d'ensemble

**Points positifs :**
- Architecture feature-based cohérente (`lib/features/`)
- Riverpod pour l'état, Go Router pour la navigation
- Séparation data/presentation/domain (partielle)
- `AppFailure` centralisé pour la gestion des erreurs
- Localisation (l10n) en place
- Thème Material 3 bien structuré
- Tests unitaires pour les parties critiques (cart, product, address)

---

## 1. Sécurité (priorité haute)

### 1.1 Clés et secrets hardcodés

| Fichier | Problème | Recommandation |
|---------|----------|----------------|
| `lib/core/config/supabase_config.dart` | Clé anon Supabase en dur | Utiliser uniquement `--dart-define` ; pas de fallback dev en prod |
| `lib/core/config/support_config.dart` | Numéro WhatsApp/téléphone en dur | OK pour config métier ; préférer variable d'environnement si sensible |

**Action :** En production, exiger `SUPABASE_URL` et `SUPABASE_ANON_KEY` via `--dart-define`. Ne jamais committer de clés réelles.

### 1.2 Gestion des credentials

- ✅ `.env` dans `.gitignore`
- ⚠️ `SupabaseConfig._devUrl` et `_devAnonKey` exposés dans le dépôt
- **Recommandation :** Utiliser des placeholders vides ou des valeurs dummy en dev ; documenter la procédure de build prod.

---

## 2. Architecture

### 2.1 Use case non utilisé

`PlaceOrderUseCase` existe dans `lib/features/checkout/domain/` mais **n'est pas utilisé** par `CheckoutScreen`. La logique de placement de commande est dupliquée dans l'écran (~100 lignes).

**Recommandation :** Injecter `PlaceOrderUseCase` via un provider et l'appeler depuis le checkout. Supprimer la duplication.

### 2.2 Écrans monolithiques

| Écran | Lignes | Problème |
|-------|--------|----------|
| `CheckoutScreen` | ~851 | Logique métier + UI mélangées ; widgets privés nombreux |

**Recommandation :** Extraire dans des fichiers séparés :
- `checkout_bottom_bar.dart`
- `checkout_receipt.dart`
- `checkout_place_order_handler.dart` (ou utiliser le use case)

### 2.3 Injection de dépendances

- Les repositories sont injectés via des `Provider` Riverpod ✅
- `PlaceOrderUseCase` n'a pas de provider dédié
- `StripePaymentService` est instancié directement dans le use case
- **Recommandation :** Créer des providers pour les use cases et services.

---

## 3. Gestion des erreurs

### 3.1 Patterns inconsistants

- `catch (e)` → `AppToast.show(..., isError: true)` sans message utilisateur précis
- `catch (_) {}` — erreurs ignorées silencieusement (ex. `promo_repository.incrementUses`)
- `toAppFailure()` utilisé dans certains providers, pas partout

**Recommandation :**
- Toujours convertir les exceptions en `AppFailure` avant affichage
- Logger les erreurs ignorées (au moins en debug)
- Éviter les `catch` vides

### 3.2 Messages utilisateur

- Certains écrans utilisent `l10n.errorGeneric` systématiquement
- **Recommandation :** Utiliser `ErrorRetryWidget.localizedMessage()` ou équivalent pour des messages adaptés au type d'erreur.

---

## 4. Constantes et configuration

### 4.1 Strings hardcodés

| Localisation | Valeur | Action |
|--------------|--------|--------|
| `checkout_screen.dart` | `'Commander via WhatsApp'` | Ajouter dans l10n (`orderViaWhatsApp`) |
| `checkout_screen.dart` | `'221779239305'` | Utiliser `SupportConfig.whatsAppNumber` |
| Divers | `'COLWAYS'` | Utiliser `l10n.appTitle` ou constante de marque |

### 4.2 Magic numbers

- `defaultShippingAmount`, `_bottomBarButtonHeight`, etc. — OK en constantes locales
- **Recommandation :** Centraliser les valeurs métier (ex. frais de livraison) dans un `AppConstants` ou config.

---

## 5. Logging et monitoring

- `AppLogger` : debugPrint en dev, silencieux en prod
- TODO présent : "Envoyer à Sentry/Crashlytics en prod"
- **Recommandation :** Intégrer `sentry_flutter` ou `firebase_crashlytics` ; garder les logs d'erreur en production pour le diagnostic.

---

## 6. Tests

- 8 fichiers de tests (cart_state, product_model, address_model, app_failure, etc.)
- Couverture limitée aux modèles et logique pure
- **Recommandation :**
  - Tests de régression pour les repositories (avec mocks)
  - Tests widget pour les écrans critiques (checkout, login)
  - Intégration du use case `PlaceOrderUseCase`

---

## 7. Linter et qualité

- `analysis_options.yaml` : règles de base (`flutter_lints`)
- **Recommandation :** Activer des règles supplémentaires, ex. :
  - `require_trailing_commas`
  - `avoid_redundant_argument_values`
  - `sort_constructors_first`
  - `use_super_parameters`

---

## 8. Checklist implémentations recommandées

- [ ] Supprimer ou masquer les clés Supabase hardcodées
- [ ] Centraliser le numéro WhatsApp (SupportConfig déjà présent)
- [ ] Localiser "Commander via WhatsApp"
- [ ] Utiliser PlaceOrderUseCase dans CheckoutScreen
- [ ] Extraire les widgets privés de CheckoutScreen
- [ ] Remplacer les `catch` vides par des logs
- [ ] Créer provider pour PlaceOrderUseCase
- [ ] Renforcer analysis_options
- [ ] Documenter la procédure de build production
