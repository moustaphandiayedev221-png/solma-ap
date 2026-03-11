# Edge Function : send-push-notification (FCM v1)

Envoie les notifications push via **Firebase Cloud Messaging API v1** (l’ancienne API avec clé serveur est désactivée par Firebase).

## 1. Créer une clé de compte de service

1. Ouvre **Google Cloud Console** : https://console.cloud.google.com  
2. Sélectionne le projet **colways-532e4** (ou ton projet Firebase).  
3. Menu **IAM et administration** → **Comptes de service**.  
4. Clique sur le compte du type **Firebase Admin** (ou « Compte de service par défaut »), ou crée-en un.  
5. Onglet **Clés** → **Ajouter une clé** → **Créer une clé** → **JSON** → **Créer**.  
6. Un fichier JSON est téléchargé. Ouvre-le : tu y trouveras notamment :
   - `project_id`
   - `client_email`
   - `private_key` (chaîne avec des `\n`)

## 2. Configurer les secrets Supabase

Dans **Supabase Dashboard** → **Edge Functions** → **send-push-notification** → **Secrets**, ajoute :

| Secret | Valeur |
|--------|--------|
| **FIREBASE_PROJECT_ID** | `colways-532e4` (ou le `project_id` du JSON) |
| **FIREBASE_CLIENT_EMAIL** | La valeur de `client_email` du JSON (ex. `firebase-adminsdk-xxx@colways-532e4.iam.gserviceaccount.com`) |
| **FIREBASE_PRIVATE_KEY** | La valeur de `private_key` du JSON **en entier**, y compris `-----BEGIN PRIVATE KEY-----` et `-----END PRIVATE KEY-----`. Copie-colle telle quelle (les retours à la ligne sont gérés par la fonction). |

Pour **FIREBASE_PRIVATE_KEY** : ouvre le fichier JSON, copie la chaîne entre guillemets pour `"private_key"` (avec les `\n`), et colle-la dans le secret. La fonction remplace elle-même `\n` par de vrais retours à la ligne.

## 3. Activer l’API FCM

- Dans la console Firebase : **Paramètres du projet** → **Cloud Messaging** → la section **API Firebase Cloud Messaging (V1)** doit être active (c’est le cas sur ta capture).  
- Dans Google Cloud : **APIs et services** → **Bibliothèque** → cherche **Firebase Cloud Messaging API** → active-la si ce n’est pas déjà fait.

## 4. Déployer la fonction

```bash
supabase functions deploy send-push-notification
```

## Corps de la requête

Comme avant :

```json
{
  "title": "Titre",
  "body": "Message",
  "target_type": "all",
  "target_user_id": "uuid-optionnel-si-target_type-user"
}
```

L’app **Colways Admin** appelle cette fonction après avoir inséré une notification en base.

## En résumé

Tu n’as **rien à faire** sur la page « Certificats Web push » ni sur « Générer une paire de clés » pour les push **Android/iOS** : c’est pour le web.  
Pour les push mobiles, il suffit d’avoir créé la clé **compte de service** (JSON), renseigné les 3 secrets (project_id, client_email, private_key), et déployé la fonction.
