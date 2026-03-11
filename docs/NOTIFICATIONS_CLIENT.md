# Notifications client - Analyse complète

Documentation du flux des notifications push dans l'application **client** Colways.

---

## 1. Architecture globale

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ÉMETTEURS DE NOTIFICATIONS                           │
├─────────────────────────────────────────────────────────────────────────────┤
│ • Confirmation commande   → CheckoutScreen (après createOrder)               │
│ • Promo / annonces        → App Admin (NotificationsScreen)                  │
│ • Expédition commande     → App Admin (OrderDetailScreen)                    │
└───────────────────────────────────┬─────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. INSERT dans table notifications                                           │
│ 2. Appel client functions.invoke → send-push-notification                    │
└───────────────────────────────────┬─────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ send-push-notification (Edge Function)                                       │
│ • Lit user_fcm_tokens (filtré par target_user_id si ciblé)                   │
│ • Envoie via FCM HTTP v1                                                     │
│ • Canal Android : colways_notifications                                      │
└───────────────────────────────────┬─────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ APP CLIENT - Réception                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│ Premier plan : FirebaseMessaging.onMessage → LocalNotificationService        │
│ Arrière-plan : FCM affiche automatiquement (payload notification + data)     │
│ Realtime     : Abonnement Supabase → notification locale + refresh UI        │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Fichiers clés

### Enregistrement du token FCM

| Fichier | Rôle |
|---------|------|
| `lib/features/notifications/data/fcm_token_repository.dart` | saveToken, removeToken, getToken |
| `lib/features/notifications/presentation/widgets/notification_realtime_listener.dart` | Appelle saveTokenIfPossible à la connexion |

### Réception et affichage

| Fichier | Rôle |
|---------|------|
| `lib/features/notifications/data/local_notification_service.dart` | Canal `colways_notifications`, affichage 1er plan |
| `lib/main.dart` | Background handler FCM, init LocalNotificationService |

### Envoi (côté client)

| Fichier | Rôle |
|---------|------|
| `lib/features/notifications/data/notifications_repository.dart` | notifyOrderPlaced, subscribeToNewNotifications |
| `lib/features/checkout/presentation/screens/checkout_screen.dart` | Appelle notifyOrderPlaced après createOrder |

### Backend

| Fichier | Rôle |
|---------|------|
| `supabase/functions/send-push-notification/index.ts` | Edge Function FCM |
| `supabase/migrations/008_notifications.sql` | Tables notifications, user_fcm_tokens |

---

## 3. Flux détaillé

### 3.1 Enregistrement du token (connexion)

1. Utilisateur se connecte → `currentUserProvider` fournit le userId
2. `NotificationRealtimeListener._subscribe(userId)` est appelé
3. `FcmTokenRepository().saveTokenIfPossible(userId)` enregistre le token dans `user_fcm_tokens`
4. `NotificationsRepository.subscribeToNewNotifications()` s'abonne au Realtime sur `notifications`

### 3.2 Confirmation de commande

1. `CheckoutScreen` → `createOrder()` → orderId
2. `notificationsRepository.notifyOrderPlaced(...)` :
   - INSERT dans `notifications`
   - `functions.invoke('send-push-notification', {title, body, target_type, target_user_id})`
3. Edge Function lit `user_fcm_tokens` pour ce user_id → envoie via FCM

### 3.3 Promo / annonces (admin)

1. Admin dans NotificationsScreen envoie une notification
2. INSERT dans `notifications` + `functions.invoke('send-push-notification')` → FCM

### 3.4 Réception côté client

| Contexte | Comportement |
|----------|--------------|
| **App au 1er plan** | `FirebaseMessaging.onMessage` → `LocalNotificationService.showNotification()` |
| **App en arrière-plan** | FCM affiche (payload contient `notification` + `data`) |
| **App fermée** | Idem arrière-plan |
| **Realtime** | INSERT sur `notifications` → callback → showNotification + invalidate provider |

---

## 4. Prérequis techniques

### Secrets Supabase (partagés avec admin)

- `FIREBASE_PROJECT_ID`
- `FIREBASE_CLIENT_EMAIL`
- `FIREBASE_PRIVATE_KEY`

### Déploiement

```bash
cd /chemin/vers/colways
supabase functions deploy send-push-notification
supabase functions deploy notify-admin-new-order
```

Le fichier `supabase/config.toml` définit `verify_jwt = false` pour éviter l'erreur 401 Invalid JWT.

### Webhook optionnel (alternative)

Si tu préfères utiliser un webhook au lieu de l'appel client :
1. **Supabase Dashboard** → **Integrations** → **Database Webhooks**
2. Name : `on_notification_insert_send_push`, Table : `notifications`, Events : **Insert**
3. Type : **Supabase Edge Functions**, Function : `send-push-notification`
4. Retirer l'appel `functions.invoke` dans le code (optionnel)

### Realtime sur `notifications`

La table `notifications` doit être dans la publication `supabase_realtime` pour les mises à jour en temps réel. Si ce n'est pas le cas :

```sql
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
```

Ou via Dashboard : Database → Replication → supabase_realtime → ajouter `notifications`.

---

## 5. Points d'attention

### Logout et token FCM

- À la déconnexion, `removeToken(userId)` doit être appelé pour supprimer le token de `user_fcm_tokens`
- Sinon, des push pourraient être envoyés à un utilisateur déconnecté

### Web vs Mobile

- `getToken()` retourne `null` sur Web → pas de push côté client web
- La table `user_fcm_tokens` enregistre `platform: 'web'` ou `'mobile'`

---

## 6. Vérifications

- Script : `supabase/scripts/check_user_fcm_tokens.sql`
- Vérifier qu'un token existe après connexion
- Tester : passer une commande → notification reçue sur l'appareil
