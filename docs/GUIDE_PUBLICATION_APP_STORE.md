# Guide de publication SOLMA sur l'App Store

Ce guide vous accompagne étape par étape pour publier l'application **SOLMA** (Colways) sur l'App Store. Il est basé sur l'analyse de votre projet Flutter.

---

## Vue d'ensemble de l'application

| Élément | Valeur |
|---------|--------|
| **Nom affiché** | SOLMA |
| **Nom projet** | colways |
| **Bundle ID** | `com.apps.colways` |
| **Version** | 1.0.0+1 |
| **Type** | E-commerce chaussures (Flutter + Supabase) |
| **Fonctionnalités** | Paiement Stripe, Google/Apple Sign-In, Notifications push (Firebase) |

---

## Phase 1 : App Store Connect — Créer l'app

### Étape 1.1 — Remplir le formulaire "Nouvelle app"

Sur l’écran que vous avez ouvert :

1. **Plateformes** : Garder **iOS** ✓  
2. **Nom** : `Solma` ✓ (ou `SOLMA` si vous préférez tout en majuscules)  
3. **Langue principale** : `Français` ✓  
4. **Identifiant de lot (Bundle ID)** : `com.apps.colways` ✓  
5. **UGS (SKU)** — **À remplir** :  
   - Exemple : `solma-ios-001` ou `com.apps.colways`  
   - C’est un identifiant interne, invisible pour l’utilisateur. Il doit être unique dans votre compte et ne pas être modifiable après.  
6. **Accès utilisateur** :  
   - Pour la mise en production, choisir **Accès complet**  
   - **Accès limité** convient uniquement pour le TestFlight (beta testeurs internes)

Après avoir renseigné l’UGS, cliquer sur **Créer**.

---

### Étape 1.2 — Informations générales (après création)

Dans App Store Connect > votre app SOLMA :

1. **Identifiant Apple (SKU)** — Déjà défini à l’étape précédente  
2. **Numéro de référence** (optionnel) — Pour vos propres numéros de facture ou références  
3. **Informations sur les achats intégrés** — À configurer si vous utilisez des achats in‑app (Stripe gère les paiements, donc souvent pas nécessaire)

---

## Phase 2 : Préparer le code et le projet

### Étape 2.1 — Passer les entitlements en production (Push Notifications)

Votre fichier `ios/Runner/Runner.entitlements` utilise actuellement `aps-environment: development`. Pour l’App Store, il doit être en `production`.

**Action requise** : modifier `ios/Runner/Runner.entitlements` et remplacer :

```xml
<key>aps-environment</key>
<string>development</string>
```

par :

```xml
<key>aps-environment</key>
<string>production</string>
```

> **Astuce** : Pour garder la flexibilité, vous pouvez utiliser un fichier de configuration Xcode (Build Configuration) : `development` pour debug, `production` pour release.

---

### Étape 2.2 — Vérifier la version et le build number

Dans `pubspec.yaml`, vous avez :

```yaml
version: 1.0.0+1
```

- `1.0.0` = version affichée (CFBundleShortVersionString)  
- `+1` = numéro de build (CFBundleVersion)

Pour chaque nouvelle soumission à l’App Store, **augmenter obligatoirement le numéro de build** (par ex. `1.0.0+2`, `1.0.0+3`), même si la version reste `1.0.0`.

---

### Étape 2.3 — URL de politique de confidentialité (obligatoire)

Apple exige une **URL publique** vers la politique de confidentialité.

**Page prête à l'emploi** : Le projet contient une page HTML dans `docs/privacy-policy.html` (design moderne, sans données sensibles).

**Hébergement GitHub Pages :**
1. Activer **GitHub Pages** dans les réglages du dépôt (Source : branche main, dossier `/docs`)
2. Après déploiement, l'URL sera : `https://[VOTRE-USERNAME].github.io/[NOM-REPO]/privacy-policy.html`
3. Coller cette URL dans App Store Connect → Informations de l'app → **URL de politique de confidentialité**

Voir `privacy-policy-page/README.md` pour plus de détails.

---

### Étape 2.4 — Vérifier les droits d’accès (Info.plist)

Votre `Info.plist` inclut déjà :

- `NSFaceIDUsageDescription` pour Face ID  
- `UIBackgroundModes` avec `remote-notification` pour les notifications push  
- URL schemes pour Google Sign-In et Supabase Auth  

Rien à modifier pour ces éléments.  
Si vous ajoutez la caméra ou la galerie photos plus tard, vous devrez ajouter les clés correspondantes.

---

## Phase 3 : Certificats et identifiants Apple

### Étape 3.1 — Compte Apple Developer

- Souscrire au [Apple Developer Program](https://developer.apple.com/programs/) (99 $/an) si ce n’est pas déjà fait  
- Vérifier que le Bundle ID `com.apps.colways` est créé dans [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list)  
- Configurer les **Capabilities** pour ce Bundle ID :  
  - Push Notifications  
  - Sign in with Apple  
  - (et tout autre service que vous utilisez)

### Étape 3.2 — Provisioning Profile pour distribution

1. Aller dans **Profiles** > **Distribution**  
2. Créer un profil **App Store** pour `com.apps.colways`  
3. Télécharger et installer le profil (Xcode le fera souvent automatiquement si votre compte est configuré)

---

## Phase 4 : Construire et archiver l’app

### Étape 4.1 — Build release Flutter

Depuis la racine du projet :

```bash
flutter clean
flutter pub get
flutter build ios --release
```

### Étape 4.2 — Ouvrir et archiver dans Xcode

1. Ouvrir le projet :  
   ```bash
   open ios/Runner.xcworkspace
   ```
2. Sélectionner **Any iOS Device (arm64)** comme destination  
3. Menu **Product** > **Archive**  
4. Une fois l’archive créée, la fenêtre **Organizer** s’ouvre

### Étape 4.3 — Uploader vers App Store Connect

1. Dans **Organizer**, sélectionner l’archive  
2. Cliquer sur **Distribute App**  
3. Choisir **App Store Connect** > **Upload**  
4. Suivre les étapes (signature automatique recommandée)  
5. Attendre la fin du traitement (généralement 5–30 minutes)

---

## Phase 5 : Fiche App Store dans App Store Connect

### Étape 5.1 — Informations de l’app

1. **Nom de l’app** : SOLMA (30 caractères max)  
2. **Sous-titre** : court descriptif (30 caractères max), ex. « Chaussures premium à votre porte »  
3. **Catégorie primaire** : Shopping  
4. **Catégorie secondaire** : Mode (optionnel)

### Étape 5.2 — Captures d’écran (obligatoire)

- **iPhone 6.7"** (obligatoire pour iPhone) : au moins 3 captures  
- **iPhone 6.5"** : recommandé  
- **iPad 12.9"** : uniquement si l’app est prévue pour iPad  

Astuce : utiliser le simulateur iPhone 15 Pro Max pour des captures nettes.

### Étape 5.3 — Description et textes

- **Description** : présentation détaillée de SOLMA (jusqu’à 4000 caractères)  
- **Mots-clés** : mots séparés par des virgules, sans espaces (100 caractères max)  
- **URL de support** : page d’aide ou formulaire de contact  
- **URL de politique de confidentialité** : URL publique obtenue à l’étape 2.3

### Étape 5.4 — Informations générales

- **Âge recommandé** : choisir selon votre contenu (en général 4+)  
- **Copyright** : ex. `© 2026 Votre Société`  
- **Informations de contact** : email pour les demandes App Review

---

## Phase 6 : Configuration des builds et soumission

### Étape 6.1 — Lier un build à la fiche

1. Dans App Store Connect > **Mon app** > **Version iOS**  
2. Section **Build** > cliquer sur **+**  
3. Sélectionner le build uploadé (une fois le traitement terminé)

### Étape 6.2 — Déclarations de confidentialité (App Privacy)

1. **App Store Connect** > **Mon app** > **App Privacy**  
2. Remplir le questionnaire selon l’utilisation des données :  
   - Identifiants (email, nom) — Supabase Auth  
   - Données financières — Stripe (si vous les traitez)  
   - Données de diagnostic — Firebase (si utilisé)  
   - Identifiant publicitaire — si vous ne faites pas de ciblage publicitaire, indiquer « Non »

### Étape 6.3 — Soumettre pour révision

1. Remplir toutes les sections marquées obligatoires  
2. Cliquer sur **Soumettre pour révision**  
3. Répondre aux questions de révision (exportation, chiffrement, etc.)  
4. En général, la révision prend 24 à 48 heures

---

## Checklist finale avant soumission

- [ ] UGS (SKU) renseigné dans App Store Connect  
- [ ] `aps-environment` en `production` dans Runner.entitlements  
- [ ] URL de politique de confidentialité publique  
- [ ] Version et build number à jour dans `pubspec.yaml`  
- [ ] Build archivé et uploadé depuis Xcode  
- [ ] Captures d’écran et textes renseignés  
- [ ] App Privacy complétée  
- [ ] Certificats et profils de distribution à jour  
- [ ] Test de l’app sur device physique avant archivage

---

## Fichiers clés à vérifier

| Fichier | Rôle |
|---------|------|
| `pubspec.yaml` | Version et build number |
| `ios/Runner/Info.plist` | Nom, permissions, URL schemes |
| `ios/Runner/Runner.entitlements` | Push, Sign in with Apple |
| `ios/Runner.xcodeproj/project.pbxproj` | Bundle ID, configurations de build |

---

## En cas de rejet

Apple envoie un email avec les motifs de rejet (ex. **Guideline 2.1** : crash, **Guideline 5.1.1** : confidentialité, etc.). Corriger les points indiqués et renvoyer une nouvelle version en augmentant le build number.

---

## Commandes utiles

```bash
# Build release iOS
flutter build ios --release

# Vérifier la configuration
flutter doctor -v

# Nettoyer le projet
flutter clean && flutter pub get
```

---

*Document généré à partir de l’analyse du projet Colways/SOLMA.*
