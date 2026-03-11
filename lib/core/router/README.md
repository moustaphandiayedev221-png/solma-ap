# Navigation — Architecture Production

Architecture de navigation inspirée d'Amazon, Zara et Airbnb.

## Structure

```
lib/core/router/
├── app_router.dart          # Configuration GoRouter centralisée
├── route_constants.dart     # Chemins et helpers (AppPaths)
├── page_transitions.dart    # Transitions fluides (fade + slide, iOS-style)
├── navigation_extensions.dart # Extensions (pushProductDetail avec preload)
└── README.md
```

## Usage

### Navigation simple

```dart
import 'package:go_router/go_router.dart';
import 'core/router/app_router.dart';
import 'core/router/route_constants.dart';

// Push vers détail produit
context.push(AppPaths.product(productId));

// Push avec objet via extra
context.push(AppPaths.product(productId), extra: {'product': product});

// Go (remplace la stack)
context.go(AppPaths.home);
```

### Navigation avec préchargement (Hero fluide)

```dart
import 'core/router/navigation_extensions.dart';

// Précharge l'image avant la transition pour une Hero animation fluide
context.pushProductDetail(
  product.id,
  imageUrl: product.firstImageUrl,
  heroSource: 'card',
  heroTagSuffix: index.toString(),
);
```

### Deep Linking

Les URLs sont automatiquement parsées par GoRouter :

- `https://app.com/product/abc123` → Page détail produit
- `https://app.com/products/category/men` → Liste par catégorie
- `https://app.com/products/section/popular` → Liste section populaire

### Scroll Restoration

Les listes de produits utilisent `PageStorageKey` pour conserver la position du scroll quand l'utilisateur revient d'une page détail.

### Transitions

- **Fade + Slide** : Onboarding, Login, Settings
- **Slide horizontal (iOS-style)** : Product Detail, Checkout, Cart
- **Hero** : Image produit entre liste et détail

### Swipe to close

La page détail produit supporte le geste swipe depuis le bord gauche pour revenir (style iOS).

### Zoom image

Appuyer sur l'image produit ouvre un viewer plein écran avec zoom/pinch (PhotoView).
