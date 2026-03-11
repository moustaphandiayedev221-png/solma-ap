# Colways – E-commerce Chaussures Premium

Application mobile Flutter + Supabase, style Nike : minimaliste, premium, sécurisée.

## Prérequis

- Flutter SDK ^3.10.8
- Compte [Supabase](https://supabase.com)
- (Optionnel) Stripe pour les paiements
- (Optionnel) Firebase pour les notifications push

## Configuration Supabase

1. **Créer un projet** sur [Supabase](https://app.supabase.com).
2. **Récupérer les clés** : Project Settings → API  
   - **Project URL** : déjà configuré dans `lib/core/config/supabase_config.dart`  
   - **anon public** : remplacer `SupabaseConfig.anonKey` par votre clé **anon** (longue chaîne JWT), et non la clé "publishable" si vous avez une autre source.
3. **Exécuter les migrations SQL** (dans l’ordre) dans le **SQL Editor** Supabase :  
   - `supabase/migrations/001_initial_schema.sql` (tables + RLS)  
   - `supabase/migrations/002_seed_data.sql` (catégories + produits avec images Unsplash)

## Lancer l’app

```bash
flutter pub get
flutter run
```

## Structure du projet (Clean Architecture)

```
lib/
├── core/                 # Constantes, config, thème, router, widgets partagés
├── features/             # Par feature
│   ├── auth/             # Login, Signup, AuthRepository
│   ├── splash/
│   ├── onboarding/
│   ├── main_navigation/  # Bottom nav (Home, Search, Cart, Profile)
│   ├── home/             # Bannière, catégories, Popular, Sports
│   ├── product/          # Détail produit (taille, couleur, Add to Cart)
│   ├── cart/
│   ├── checkout/         # Paiement (Stripe)
│   └── profile/          # Profil, commandes, wishlist
└── main.dart
```

## Design

- Fond clair (blanc / gris très clair), boutons noirs arrondis
- Ombres douces, cartes arrondies
- Typographie Google Fonts (Outfit)
- Dark mode disponible (thème dans `core/theme/app_theme.dart`)

## Sécurité

- Supabase Auth (JWT)
- Row Level Security (RLS) sur toutes les tables
- Policies dans `supabase/migrations/001_initial_schema.sql`

## Base de données (Supabase)

Tables : `profiles`, `categories`, `products`, `cart`, `wishlist`, `orders`, `order_items`, `payments`, `promotions`.  
Détail et RLS dans `supabase/migrations/001_initial_schema.sql`.

## Clé API Supabase

La clé actuelle dans `supabase_config.dart` est au format indiqué (publishable).  
Pour Supabase, utilisez la clé **anon (public)** du dashboard (Project Settings → API).  
Ne commitez pas la clé **service_role** (secrète).
