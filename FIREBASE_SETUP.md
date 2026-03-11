# Configuration Firebase (Colways)

Le projet Firebase **colways-532e4** est créé. Pour finaliser la config (push notifications) :

## Option 1 : FlutterFire CLI (recommandé)

Dans un **terminal** (pas dans Cursor) :

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
cd /Users/touba/Desktop/colways/colways
flutterfire configure --project=colways-532e4
```

Choisis **Android** et **iOS** quand demandé. Cela va :
- Mettre à jour `lib/firebase_options.dart` avec les vraies clés
- Ajouter `android/app/google-services.json`
- Ajouter `ios/Runner/GoogleService-Info.plist`

## Option 2 : Configuration manuelle

Si la CLI échoue encore :

1. **Firebase Console** : https://console.firebase.google.com → projet **colways-532e4**

2. **Android**  
   - Paramètres du projet → « Ajouter une application » → Android  
   - Package name : `com.apps.colways`  
   - Télécharge `google-services.json` et place-le dans :  
     `android/app/google-services.json`

3. **iOS**  
   - « Ajouter une application » → iOS  
   - Bundle ID : `com.apps.colways`  
   - Télécharge `GoogleService-Info.plist` et place-le dans :  
     `ios/Runner/GoogleService-Info.plist`

4. **Activer Cloud Messaging**  
   - Dans la console Firebase : Build → Cloud Messaging  
   - Pour l’Edge Function push : Paramètres du projet → Cloud Messaging → Clé serveur (Legacy) → copier dans le secret **FCM_SERVER_KEY** de Supabase.

5. **Clés dans `lib/firebase_options.dart`**  
   - Si tu n’as pas pu lancer `flutterfire configure`, ouvre `lib/firebase_options.dart` et remplace les `apiKey`, `appId`, `messagingSenderId` (et optionnellement `storageBucket`) par les valeurs affichées dans Firebase (Paramètres du projet → Tes applications).

## Vérification

Après configuration, lance l’app :

```bash
flutter run
```

Les notifications en premier plan (Realtime) fonctionnent sans Firebase. Les **push en arrière-plan** nécessitent la config Firebase + l’Edge Function `send-push-notification` avec les secrets FCM (voir MISE_EN_ROUTE.md).

## Push quand l’app est fermée (arrière-plan / tuée)

- **iOS** : les push quand l’app est fermée **ne fonctionnent pas sur le simulateur**. Il faut tester sur un **vrai iPhone**. De plus, il faut ajouter une **clé APNs** dans Firebase (voir ci‑dessous).
- **Android** : en général les notifications s’affichent dans la barre même si l’app est fermée, si l’app a au moins une fois demandé la permission et enregistré le token (à l’ouverture).
- Après toute modification de l’Edge Function : `supabase functions deploy send-push-notification`.

---

## Où trouver et configurer la clé APNs (iOS)

La clé APNs permet à Firebase d’envoyer les push aux iPhones. Sans elle, les notifications ne s’affichent pas quand l’app est fermée ou en arrière-plan.

### 1. Créer (ou récupérer) la clé sur Apple Developer

1. Va sur **https://developer.apple.com/account** et connecte-toi avec ton compte Apple Developer (compte payant requis, 99 €/an).
2. Menu **Certificates, Identifiers & Profiles** → dans la barre latérale, clique sur **Keys** (Clés).
3. Clique sur le **+** pour créer une nouvelle clé.
4. Donne un nom (ex. « Colways Push »), coche **Apple Push Notifications service (APNs)** → **Continue** → **Register**.
5. Sur l’écran de confirmation : **Download** pour télécharger le fichier **.p8** (tu ne pourras le télécharger qu’une seule fois). Note aussi :
   - **Key ID** (ex. `ABC123XYZ`)
   - **Team ID** (en haut à droite de la page ou dans Membership)
   - **Bundle ID** de l’app (ex. `com.apps.colways`)

### 2. Récupérer l’identifiant de l’app (pour Firebase)

- Dans **Certificates, Identifiers & Profiles** → **Identifiers** → sélectionne ton App ID (ex. `com.apps.colways`).  
- Si tu n’as pas encore d’App ID, crée-en un avec le même **Bundle ID** que dans Xcode (`com.apps.colways`) et active **Push Notifications** dans les capacités.

### 3. Ajouter la clé .p8 dans Firebase

1. Ouvre **https://console.firebase.google.com** et sélectionne ton projet (ex. **colways-532e4**).
2. Clique sur l’**engrenage** à côté de « Aperçu du projet » → **Paramètres du projet**.
3. Va dans l’onglet **Cloud Messaging** (en haut).
4. Descends jusqu’à la section **« Configuration des applications Apple »** (Apple app configuration).
5. Si tu n’as pas encore ajouté d’app iOS, assure-toi que l’app avec le Bundle ID `com.apps.colways` est bien ajoutée dans **Paramètres du projet** → **Général** → « Tes applications ». Sinon, ajoute une application iOS avec ce Bundle ID.
6. Dans « Configuration des applications Apple », clique sur **Télécharger** (ou **Upload** / **Importer**) la clé APNs. Une fenêtre ou un formulaire s’ouvre.
7. Renseigne les champs :
   - **Fichier .p8** : clique sur « Parcourir » (ou glisse-dépose) et sélectionne ton fichier **.p8** téléchargé depuis Apple (il s’appelle souvent `AuthKey_XXXXXXXXXX.p8`). Ne modifie pas le contenu du fichier.
   - **Key ID** : copie l’identifiant de la clé (ex. `ABC123XYZ`) depuis la page **Keys** d’Apple Developer (liste des clés → clique sur la clé → Key ID en haut).
   - **Team ID** : ton identifiant d’équipe Apple (developer.apple.com → **Membership** ou en haut à droite du portail).
   - **Bundle ID** : `com.apps.colways` (identique au Bundle ID de ton app dans Xcode).
8. Valide avec **Upload** / **Enregistrer** (ou équivalent).

Une fois enregistrée, FCM pourra envoyer les notifications push aux appareils iOS même quand l’app est fermée.

### Après avoir ajouté la clé APNs

- **Rien à modifier dans le code** : la config est côté Firebase.
- Pour vérifier : lance l’app sur un **vrai iPhone**, ferme l’app (ou mets-la en arrière-plan), envoie une notification depuis Colways Admin → elle doit s’afficher dans le centre de notifications.
- Si l’Edge Function n’a pas été déployée depuis un moment : `supabase functions deploy send-push-notification`.

### 4. Erreur « Maximum allowed number of team scoped Keys » (sandbox)

Si Apple affiche : *« You have already reached the maximum allowed number of team scoped Keys for this service in sandbox environment »*, tu as atteint la limite de clés APNs pour ton équipe.

**Option A – Réutiliser une clé existante**  
1. Dans **Keys**, regarde la liste des clés déjà créées.  
2. Repère une clé qui a **Apple Push Notifications service (APNs)** activé.  
3. Si tu as encore le fichier **.p8** de cette clé (téléchargé au moment de sa création), tu peux l’utiliser dans Firebase avec le **Key ID** affiché sur la fiche de cette clé.  
4. Tu n’as pas besoin de créer une nouvelle clé : une même clé APNs peut servir pour plusieurs apps (même Team ID + Bundle ID dans Firebase).

**Option B – Libérer une place**  
1. Dans **Keys**, ouvre une ancienne clé APNs que tu n’utilises plus (par ex. un ancien projet).  
2. Clique sur **Revoke** (Révoquer) pour la supprimer.  
3. Tu pourras ensuite créer une **nouvelle** clé APNs, la télécharger en .p8 (une seule fois) et l’ajouter dans Firebase.
