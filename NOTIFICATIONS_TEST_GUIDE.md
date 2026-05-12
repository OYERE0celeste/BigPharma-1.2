# Guide de Test des Notifications

## 🚀 Quick Start - Tester les Notifications en 2 Minutes

### Étape 1: Lancer l'API
```bash
cd api
npm start
# Vérifier que le serveur tourne sur http://localhost:5000
```

### Étape 2: Lancer l'App Flutter
```bash
cd epharma
flutter run -d chrome
# Ou sur votre appareil/émulateur
```

### Étape 3: Se Connecter
1. Accéder à l'app sur http://localhost:56402 (ou le port affiché)
2. Se connecter avec les identifiants administrateur

### Étape 4: Tester les Notifications

#### Méthode 1 : Via le Menu Profil (Recommandé)
1. Cliquer sur le menu profil (icône utilisateur en haut à droite)
2. Cliquer sur "Tester notification"
3. Cliquer sur "Envoyer"
4. ✅ Vous devriez voir une notification apparaître

#### Méthode 2 : Via le Badge de Notification
1. Cliquer sur l'icône de cloche (bell icon) en haut à droite
2. Vérifier que le panel s'ouvre
3. Si "Aucune notification", cliquer le bouton refresh (icône roue)
4. Si rien n'apparaît, vérifier les logs console (F12)

#### Méthode 3 : Via API Direct (Postman)
```bash
GET http://localhost:5000/api/v1/notifications/test
Headers:
  Authorization: Bearer YOUR_JWT_TOKEN
  Content-Type: application/json
```

### Étape 5: Vérifier les Logs

#### Console Flutter
Chercher les messages:
```
✅ Connected to Socket.io
📍 Joined rooms: company=..., user=...
📬 Received notification: ...
✅ Loaded X notifications (Y unread)
```

#### Autres Logs Utiles
```
📥 Fetching notifications from: http://...
📨 Response status: 200
🧪 Sending test notification...
```

## ✅ Checklist de Validation

- [ ] L'app se connecte à Socket.io (voir "Connected to Socket.io")
- [ ] Le badge de notification affiche un nombre
- [ ] Cliquer le badge ouvre le panel
- [ ] Le test de notification fonctionne
- [ ] Les notifications s'affichent dans le panel
- [ ] Cliquer sur une notification la marque comme lue
- [ ] Le bouton "Lire tout" fonctionne
- [ ] Le bouton refresh charge les notifications

## 🐛 Troubleshooting

### Pas de connexion Socket.io
**Symptôme**: Console Flutter affiche "Disconnected from Socket.io" continuellement

**Solutions**:
1. Vérifier que l'API tourne: `curl http://localhost:5000/api/health`
2. Vérifier le baseUrl dans `lib/services/api_constants.dart`
3. Essayer avec `polling` en ajoutant au Socket.io:
   ```dart
   'transports': ['polling', 'websocket']
   ```

### Pas de notifications en base de données
**Symptôme**: MongoDB n'a aucun document dans la collection `notifications`

**Solutions**:
1. Vérifier l'authentification fonctionne
2. Vérifier que le test /notifications/test retourne 200
3. Regarder les logs du serveur pour les erreurs
4. Vérifier la base de données:
   ```javascript
   db.notifications.countDocuments()
   db.notifications.find().limit(5)
   ```

### Socket.io reconnecte continuellement
**Symptôme**: "Disconnected" et "Connected" alternent

**Solutions**:
1. Vérifier les CORS du serveur
2. Vérifier que les events 'join-company' et 'join-user' sont reçus
3. Vérifier la firewall/proxy ne bloque pas WebSocket

## 📊 Événements qui Créent des Notifications

### Lors d'une Nouvelle Commande
1. User crée une commande dans "Commandes"
2. Backend appelle `notifyStaff()` 
3. Staff reçoit une notification avec l'icône shopping bag (bleu)

### Lors d'une Vente avec Stock Faible
1. User crée une vente dans "Ventes"
2. Si stock < minStockLevel, backend appelle `notifyStaff()`
3. Staff reçoit une notification avec l'icône inventory (rouge)

### Lors d'une Question Support
1. Client pose une question dans Support
2. Backend appelle `notifyStaff()`
3. Staff reçoit une notification avec l'icône agent (orange)

## 🔍 Vérification Manuelle

### Vérifier MongoDB
```javascript
// Connexion à MongoDB
mongo
use BigPharma

// Vérifier les notifications
db.notifications.find().pretty()

// Compter les notifications par utilisateur
db.notifications.aggregate([
  { $group: { _id: "$userId", count: { $sum: 1 } } }
])

// Vérifier les non-lues
db.notifications.countDocuments({ isRead: false })
```

### Vérifier le Backend
```bash
# Regarder les logs
npm run dev

# Vérifier l'API
curl http://localhost:5000/api/health
curl http://localhost:5000/api/v1/notifications

# Envoyer une notification de test
curl -X GET http://localhost:5000/api/v1/notifications/test \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

## 📝 Notes

- **Socket.io reconnecte automatiquement** après 1-5 secondes
- **Les notifications sont persistées** en base de données
- **Historique complet** disponible via l'API
- **Notifications en temps réel** via WebSocket
- **Fallback polling** si WebSocket n'est pas disponible

---

**Status**: ✅ Prêt pour la Production
**Date de Test**: 12 Mai 2026
