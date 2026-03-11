# SOLMA – Ce qu’il faut faire pour que l’application marche

## 1. Supabase (base de données + auth)

### 1.1 Appliquer les migrations
Dans le **Supabase Dashboard** → **SQL Editor**, exécute dans l’ordre les fichiers SQL du dossier `supabase/migrations/` (s’ils ne sont pas déjà appliqués) :
- `001_initial_schema.sql` jusqu’à `008_notifications.sql`

### 1.2 Créer un admin (pour SOLMA Admin)
1. Connecte-toi une fois dans l’app **SOLMA** ou **SOLMA Admin** avec le compte à promouvoir en admin (ou crée un user dans **Authentication** → **Users**).
2. Dans Supabase : **Authentication** → **Users** → clique sur l’utilisateur → copie l’**UUID**.
3. Ouvre le script `supabase/scripts/insert_admin_user.sql`, remplace `TON_USER_ID_ICI` par cet UUID, puis exécute-le dans **SQL Editor**.

Ou exécute directement dans **SQL Editor** (en remplaçant l’UUID) :
```sql
INSERT INTO public.admin_users (user_id) VALUES ('ton-uuid-ici');
```

### 1.3 Activer Realtime pour les notifications
**Database** → **Replication** → publication **supabase_realtime** → ajouter la table **notifications**.

---

## 2. Application SOLMA (app mobile / client)

### 2.1 Dépendances
```bash
cd /Users/touba/Desktop/colways/colways
flutter pub get
```

### 2.2 Firebase (pour les push en arrière-plan)
- Soit tu as déjà fait **flutterfire configure** → rien à faire de plus.
- Soit tu configures à la main (voir **FIREBASE_SETUP.md**) :
  - Fichier **android/app/google-services.json** (téléchargé depuis la console Firebase).
  - Fichier **ios/Runner/GoogleService-Info.plist** (idem).
  - Fichier **lib/firebase_options.dart** rempli avec les vraies clés (ou régénéré par `flutterfire configure`).

### 2.3 Lancer l’app
```bash
flutter run
```
Choisis Android ou iOS. L’app marche sans Firebase pour tout sauf les **push en arrière-plan** (notifications en premier plan + Realtime fonctionnent sans Firebase).

---

## 3. SOLMA Admin (dashboard)

### 3.1 Dépendances
```bash
cd /Users/touba/Desktop/colways/colways_admin
flutter pub get
```

### 3.2 Lancer l’admin
```bash
flutter run -d chrome
```
ou
```bash
flutter run
```
- Connecte-toi avec un compte qui est dans **admin_users** (voir 1.2).
- Tu peux gérer catégories, produits, commandes et **envoyer des notifications**.

---

## 4. Notifications push (arrière-plan)

### 4.1 Compte de service Firebase
- Google Cloud Console → **Comptes de service** → sélectionne **firebase-adminsdk-...** → onglet **Clés** → **Ajouter une clé** → **JSON** → télécharger le fichier.

### 4.2 Secrets Supabase (Edge Function)
Dans **Supabase** → **Edge Functions** → **send-push-notification** → **Secrets**, ajoute :

| Secret | Valeur (depuis le JSON téléchargé) |
|--------|------------------------------------|
| **FIREBASE_PROJECT_ID** | `project_id` |
| **FIREBASE_CLIENT_EMAIL** | `client_email` |
| **FIREBASE_PRIVATE_KEY** | `private_key` (tout le bloc, avec BEGIN/END) |

### 4.3 Déployer la fonction
```bash
cd /Users/touba/Desktop/colways/colways
supabase functions deploy send-push-notification
```
(Si `supabase` n’est pas installé : `brew install supabase/tap/supabase`.)

### 4.4 Push quand l’app est fermée (iOS)
Sur **iOS**, les notifications en arrière-plan / app tuée **ne s’affichent pas sur le simulateur**. Il faut tester sur un **vrai iPhone**. De plus, dans **Firebase Console** → Paramètres du projet → **Cloud Messaging** → « Configuration des applications Apple », ajoute une **clé APNs** (.p8) pour que FCM puisse envoyer les push aux appareils iOS.

---

## 5. Vérification rapide

| Étape | À faire | OK ? |
|-------|---------|------|
| 1 | Migrations Supabase exécutées | ☐ |
| 2 | Ton user ajouté dans `admin_users` | ☐ |
| 3 | Realtime activé sur la table `notifications` | ☐ |
| 4 | `flutter pub get` dans **colways** et **colways_admin** | ☐ |
| 5 | Firebase configuré (google-services.json + firebase_options ou flutterfire) | ☐ |
| 6 | App SOLMA : `flutter run` → connexion, navigation, notifications en premier plan | ☐ |
| 7 | App Admin : `flutter run` → connexion admin, envoi d’une notification | ☐ |
| 8 | Secrets FCM (project_id, client_email, private_key) dans Supabase | ☐ |
| 9 | Clé APNs (.p8) ajoutée dans Firebase (Paramètres → Cloud Messaging → Configuration Apple) | ☐ |
| 10 | `supabase functions deploy send-push-notification` | ☐ |
| 11 | Test : envoyer une notif depuis l’admin → reçue dans l’app (et en push si Firebase + fonction OK) | ☐ |

---

## 6. Dépannage : la notification n’apparaît pas dans SOLMA

Si tu envoies une notification depuis **colways_admin** et qu’elle n’apparaît pas dans l’app **SOLMA** :

1. **Être connecté dans SOLMA** — La liste est vide si l’utilisateur n’est pas connecté. Connecte-toi avec un compte du même projet Supabase.
2. **Tirer pour actualiser** — Sur l’écran Notifications, tire la liste vers le bas pour recharger ; les notifications « Tous les utilisateurs » s’affichent.
3. **Realtime** — Pour les mises à jour en direct : Dashboard → Database → Replication → supabase_realtime → ajouter la table **notifications**.
4. **Même projet Supabase** — SOLMA et colways_admin doivent utiliser la même URL et clé anon.

---

## En résumé

1. **Supabase** : migrations + admin_users + Realtime.
2. **SOLMA** : `flutter pub get` + config Firebase (optionnel pour push) + `flutter run`.
3. **SOLMA Admin** : `flutter pub get` + `flutter run` + connexion avec un compte admin.
4. **Push** : clé JSON du compte de service → 3 secrets Supabase → `supabase functions deploy send-push-notification`.

Après ça, l’application et les notifications sont opérationnelles.
