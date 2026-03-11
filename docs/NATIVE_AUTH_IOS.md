# Connexion native Google & Apple sur iOS

Ce guide explique comment configurer la connexion native (sans redirection navigateur) pour Google et Apple sur iOS.

## Vue d’ensemble

Aligné sur l’approche shoes :

- **iOS Google** : Tentative connexion native (`google_sign_in` + `signInWithIdToken`) ; en cas d’échec (ex. iPad), fallback OAuth WebView in-app.
- **iOS Apple** : Tentative connexion native (`sign_in_with_apple` + nonce SHA256) ; en cas d’échec, fallback OAuth WebView.
- **Android Google** : OAuth WebView uniquement (évite l’erreur DEVELOPER_ERROR API 10).
- **Android Apple** : OAuth WebView uniquement.

OAuth utilise `LaunchMode.inAppWebView` et attend la complétion via `authStateChanges`.

---

## 1. Apple Sign-In (obligatoire si vous proposez le bouton Apple)

### 1.1 Apple Developer

1. Aller sur [Apple Developer Console](https://developer.apple.com/account/resources/identifiers/list) → **Identifiers**
2. Sélectionner l’App ID `com.apps.colways` (ou votre Bundle ID)
3. Activer **Sign in with Apple**
4. Enregistrer

### 1.2 Xcode

1. Ouvrir `ios/Runner.xcworkspace` dans Xcode
2. Target **Runner** → **Signing & Capabilities**
3. Cliquer **+ Capability**
4. Ajouter **Sign in with Apple**

> L’entitlement `com.apple.developer.applesignin` est déjà ajouté dans `Runner.entitlements`.

### 1.3 Supabase Dashboard

1. [Supabase Dashboard](https://supabase.com/dashboard) → votre projet → **Authentication** → **Providers**
2. Activer **Apple**
3. Renseigner les champs demandés (Services ID, clé `.p8`, etc.) — uniquement si vous utilisez aussi l’OAuth web ; pour le flux natif iOS, la config minimale peut suffire.

> Pour le flux **natif**, Supabase vérifie le JWT Apple. Pas besoin de config OAuth complète si vous n’utilisez pas Apple sur web/Android.

---

## 2. Google Sign-In (natif)

### 2.1 Google Cloud Console

1. Aller sur [Google Cloud Console](https://console.cloud.google.com/) → **APIs & Services** → **Credentials**
2. Créer **Create Credentials** → **OAuth client ID** :
   - Type : **Web application** (Client ID Web)
   - Authorized redirect URIs : `https://<votre-projet>.supabase.co/auth/v1/callback`
   - Copier le **Client ID** (ex. `xxx.apps.googleusercontent.com`)
3. Créer un second OAuth client :
   - Type : **iOS**
   - Bundle ID : `com.apps.colways`
   - Copier le **Client ID** et le **REVERSED_CLIENT_ID** (ou équivalent)

### 2.2 Firebase (pour REVERSED_CLIENT_ID)

1. [Firebase Console](https://console.firebase.google.com/) → projet Colways
2. **Authentication** → **Sign-in method** → activer **Google**
3. Télécharger à nouveau `GoogleService-Info.plist`
4. Copier la valeur **REVERSED_CLIENT_ID** du plist

### 2.3 Info.plist

Dans `ios/Runner/Info.plist`, remplacer `YOUR_REVERSED_CLIENT_ID` par la valeur de **REVERSED_CLIENT_ID** (ex. `com.googleuser.apps.123456789-xxxxxxxxxxxx`) dans le bloc `CFBundleURLSchemes` :

```xml
<key>CFBundleURLSchemes</key>
<array>
  <string>com.googleuser.apps.VOTRE_CLIENT_ID</string>
</array>
```

### 2.4 Supabase Dashboard

1. **Authentication** → **Providers** → **Google**
2. Activer
3. **Client ID** : coller le Client ID **Web** (en premier) puis le Client ID **iOS**, séparés par une virgule
4. **Client Secret** : secret du client Web
5. **OBLIGATOIRE** : Cocher **Skip nonce check** pour iOS (sinon erreur « Nonces mismatch » — Google natif ne fournit pas de nonce)

### 2.5 Configuration dans le code

**Option A** — Développement : ajouter ton Client ID Web dans `lib/core/config/auth_config.dart` :

```dart
static const String _devGoogleWebClientId = 'ton-client-id-web.apps.googleusercontent.com';
```

**Option B** — Production / CI : passer les variables au build :

```bash
flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=xxx.apps.googleusercontent.com \
  --dart-define=GOOGLE_IOS_CLIENT_ID=yyy.apps.googleusercontent.com
```

> Si le Client ID n'est pas configuré, une erreur claire s'affiche. Sur iOS, le flux natif est tenté en premier ; en cas d'échec, un fallback OAuth WebView in-app est utilisé.

---

## 3. Redirect URLs Supabase (OAuth fallback)

Pour le fallback OAuth (Android et iOS quand le natif échoue), ajouter dans Supabase → **Authentication** → **URL Configuration** → **Redirect URLs** :

- `io.supabase.colways://login-callback/`
- `io.supabase.colways://login-callback/**`

---

## 4. Résumé des fichiers modifiés

| Fichier | Rôle |
|---------|------|
| `pubspec.yaml` | `google_sign_in`, `sign_in_with_apple`, `crypto` |
| `lib/features/auth/data/native_auth_service.dart` | Logique native Google/Apple (iOS) |
| `lib/features/auth/data/auth_repository.dart` | Orchestration natif + OAuth fallback |
| `lib/core/config/auth_config.dart` | `GOOGLE_WEB_CLIENT_ID`, `GOOGLE_IOS_CLIENT_ID` |
| `lib/core/router/app_router.dart` | Route `/login-callback` pour OAuth |
| `ios/Runner/Info.plist` | GIDClientID, URL schemes, NSFaceIDUsageDescription |
| `android/app/.../AndroidManifest.xml` | Intent-filter OAuth `io.supabase.colways` |

---

## 5. Tests

1. **Apple** : tester sur un appareil iOS (le simulateur fonctionne uniquement si connecté avec un compte Apple).
2. **Google** : tester sur appareil ou simulateur avec un compte Google.

En cas d’erreur, vérifier les logs et que toutes les étapes (Apple Developer, Google Cloud, Supabase, Info.plist, entitlements) sont bien configurées.

---

## 6. Dépannage

### Erreur « Nonces mismatch »

- **Google** : Activer **Skip nonce check** dans Supabase → Authentication → Providers → Google. Le SDK Google natif iOS ne fournit pas de nonce.
- **Apple** : Le nonce est géré correctement dans le code (hash SHA-256 avant envoi à Apple). Si l'erreur persiste, vérifier la configuration Apple dans Supabase.
