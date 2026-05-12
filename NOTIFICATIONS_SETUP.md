# Guide de Configuration des Notifications

## État du Système

Les notifications sont **maintenant pleinement fonctionnelles** avec les améliorations suivantes :

### ✅ Backend (Node.js/Express)

- **Socket.io** configuré avec websocket et polling
- **Notifications Model** : Stocke userId, companyId, title, message, type, data, isRead
- **Types** : order, support, stock, system
- **API Endpoints** :
  - `GET /api/v1/notifications` - Récupère les notifications
  - `GET /api/v1/notifications/test` - Envoie une notification de test
  - `PUT /api/v1/notifications/mark-all-read` - Marque tout comme lu
  - `PUT /api/v1/notifications/:id/read` - Marque une notification comme lue
  - `DELETE /api/v1/notifications/:id` - Supprime une notification

### ✅ Frontend (Flutter)

- **NotificationProvider** :
  - Récupère les notifications au démarrage
  - Se connecte via Socket.io pour les notifications en temps réel
  - Gère la reconnexion automatique
  - Logs détaillés pour déboguer

- **NotificationPanel** :
  - Affiche les notifications avec icônes par type
  - Format de date intelligent (m, h, dd/MM)
  - Marque comme lue au clic
  - Navigation vers les entités correspondantes

- **GlobalNavbar** :
  - Badge avec compteur d'unread
  - Affiche le panel au clic sur le badge

## Événements qui Créent des Notifications

1. **Commandes (Orders)** :
   - Nouvelle commande reçue → `notifyStaff()`

2. **Ventes (Sales)** :
   - Stock critique → `notifyStaff()` avec type "stock"

3. **Support (Support)** :
   - Nouvelle question → `notifyStaff()`
   - Nouvelle réponse → `sendNotification()` à l'utilisateur

4. **Authentification** :
   - Nouvel utilisateur ajouté → `notifyStaff()`

## Comment Tester

### 1. Via l'API (postman ou curl)

```bash
curl -X GET http://localhost:5000/api/v1/notifications/test \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

### 2. Via l'App Flutter

Créer une action dans les paramètres ou un bouton debug pour :

```dart
await context.read<NotificationProvider>().sendTestNotification();
```

### 3. Vérifier les Logs

Regarder la console de l'app pour les logs Socket.io :
- `✅ Connected to Socket.io` - Connexion établie
- `📍 Joined rooms: company=..., user=...` - Rooms rejointes
- `📬 Received notification: ...` - Notification reçue

## Troubleshooting

### Pas de notifications qui s'affichent

1. **Vérifier la connexion Socket.io** :
   - Ouvrir les dev tools du navigateur
   - Aller dans Network > WS
   - Chercher socket.io

2. **Vérifier les logs** :
   - Regarder la console de l'app Flutter
   - Chercher les messages d'erreur

3. **Vérifier la base de données** :
   ```javascript
   db.notifications.find({ userId: "..." })
   ```

4. **Tester avec une notification de test** :
   - Utiliser l'endpoint `/api/v1/notifications/test`

### Socket.io ne se connecte pas

- Vérifier que le serveur tourne sur le bon port
- Vérifier les CORS (devraient être ok avec "*")
- Vérifier le baseUrl dans l'app (doit être sans /api/v1)

### Les notifications ne sont pas en base de données

- Vérifier que l'authentification fonctionne
- Vérifier que les events (orders, sales, etc.) sont bien créés
- Ajouter des logs dans notificationHelper.js

## Architecture Complète

```
┌─────────────────────────────────────────────────────────────┐
│                   Flutter Mobile App                        │
│                   epharma/                                  │
├─────────────────────────────────────────────────────────────┤
│ NotificationProvider                                        │
│ - Socket.io Connection                                      │
│ - fetchNotifications()                                      │
│ - markAsRead()                                              │
│ - sendTestNotification()                                    │
├─────────────────────────────────────────────────────────────┤
│ GlobalNavbar + NotificationPanel                            │
│ - Displays unread count badge                               │
│ - Shows notification list                                   │
│ - Navigation on click                                       │
└─────────────────────────────────────────────────────────────┘
               ↓↑ Socket.io WebSocket
┌─────────────────────────────────────────────────────────────┐
│                    Node.js API Server                       │
│                    api/                                     │
├─────────────────────────────────────────────────────────────┤
│ server.js - Socket.io Setup                                 │
│ - global.io instance                                        │
│ - room management (company, user)                           │
│ - event broadcasting                                        │
├─────────────────────────────────────────────────────────────┤
│ notificationHelper.js                                       │
│ - sendNotification()                                        │
│ - notifyStaff()                                             │
│ - Database persistence                                      │
│ - Socket.io emission                                        │
├─────────────────────────────────────────────────────────────┤
│ notificationController.js                                   │
│ - getMyNotifications()                                      │
│ - markAsRead()                                              │
│ - deleteNotification()                                      │
│ - sendTestNotification()                                    │
├─────────────────────────────────────────────────────────────┤
│ notification.js (Model)                                     │
│ - userId, companyId, title, message                         │
│ - type, data, isRead, timestamps                            │
└─────────────────────────────────────────────────────────────┘
               ↓↑ Mongoose
┌─────────────────────────────────────────────────────────────┐
│              MongoDB - notifications collection             │
└─────────────────────────────────────────────────────────────┘
```

## Prochaines Étapes (Optionnelles)

1. **Ajouter des sons de notification**
   - Utiliser `audioplayers` package
   - Configurer dans NotificationProvider

2. **Ajouter des notifications push (FCM)**
   - Firebase Cloud Messaging
   - Notifications même quand l'app n'est pas ouverte

3. **Ajouter des notifications email**
   - Nodemailer configuré mais pas utilisé
   - Ajouter `sendEmail()` dans notificationHelper.js

4. **Dashboard des notifications**
   - Page complète de l'historique
   - Filtrer par type, date, lue/non lue

5. **Notifications personnalisées par rôle**
   - Pharmacien : stock, support
   - Manager : ventes, finances
   - Admin : tous les événements

---

**Status** : ✅ Fonctionnel et prêt pour production
**Dernière mise à jour** : 12 Mai 2026
