# Guide de configuration SMTP pour BigPharma

## Vue d'ensemble
La fonctionnalité d'envoi d'emails (réinitialisation de mot de passe, notifications, etc.) dépend d'une configuration SMTP valide.

## Variables d'environnement SMTP
Les variables suivantes ont été ajoutées à `docker-compose.yml` et doivent être configurées:

```env
SMTP_HOST=smtp.example.com          # Serveur SMTP (ex: smtp.gmail.com, smtp.mailtrap.io)
SMTP_PORT=587                       # Port SMTP (587 pour TLS, 465 pour SSL)
SMTP_USER=you@example.com           # Nom d'utilisateur/email SMTP
SMTP_PASS=changeme                  # Mot de passe ou App Password
SMTP_SECURE=false                   # true si utilisant SSL (port 465), false si TLS (port 587)
EMAIL_FROM="noreply@example.com"    # Adresse email d'envoi
```

## Options de configuration

### Option 1: Gmail avec App Password (recommandé)
1. Activer l'authentification à deux facteurs sur votre compte Google
2. Générer une App Password: https://myaccount.google.com/apppasswords
3. Utiliser les valeurs suivantes:
   ```env
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USER=your-email@gmail.com
   SMTP_PASS=your-app-password
   SMTP_SECURE=false
   EMAIL_FROM="BigPharma <noreply@example.com>"
   ```

### Option 2: Mailtrap (service test)
1. Créer un compte gratuit: https://mailtrap.io
2. Obtenir les credentials depuis votre Inbox
3. Utiliser les valeurs:
   ```env
   SMTP_HOST=smtp.mailtrap.io
   SMTP_PORT=2525 ou 465
   SMTP_USER=your-mailtrap-user
   SMTP_PASS=your-mailtrap-password
   SMTP_SECURE=false (si port 2525) ou true (si port 465)
   EMAIL_FROM="noreply@example.com"
   ```

### Option 3: SendGrid
1. Créer un compte: https://sendgrid.com
2. Générer une clé API
3. Utiliser les valeurs:
   ```env
   SMTP_HOST=smtp.sendgrid.net
   SMTP_PORT=587
   SMTP_USER=apikey
   SMTP_PASS=SG.your-sendgrid-api-key
   SMTP_SECURE=false
   EMAIL_FROM="noreply@example.com"
   ```

## Mise à jour de la configuration

### Méthode 1: Fichier `.env` (local)
Créer/modifier `api/.env`:
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
SMTP_SECURE=false
EMAIL_FROM="noreply@example.com"
```

### Méthode 2: `docker-compose.yml` (production)
Mettre à jour les variables d'environnement du service `api`:
```yaml
services:
  api:
    environment:
      - SMTP_HOST=smtp.gmail.com
      - SMTP_PORT=587
      - SMTP_USER=your-email@gmail.com
      - SMTP_PASS=your-app-password
      - SMTP_SECURE=false
      - EMAIL_FROM="noreply@example.com"
```

### Méthode 3: Secrets Kubernetes (production sécurisée)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: smtp-credentials
type: Opaque
stringData:
  smtp-host: smtp.gmail.com
  smtp-port: "587"
  smtp-user: your-email@gmail.com
  smtp-pass: your-app-password
  smtp-secure: "false"
  email-from: noreply@example.com
```

## Démarrage des services

### Avec Docker Compose
```bash
cd "d:\Projets\BigPharma 1.2"
docker compose down
docker compose up -d --build
```

### Avec Docker Compose (avec env file)
```bash
docker compose --env-file api/.env up -d --build
```

## Vérification

### 1. Vérifier les logs du service API
```bash
docker compose logs api | grep -i smtp
docker compose logs api | grep -i mail
```

### 2. Tester l'endpoint forgot-password
```bash
curl -X POST http://localhost:5000/api/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'
```

### 3. Vérifier la réception de l'email
- Vérifier votre inbox
- Vérifier le dossier Spam
- Pour Mailtrap: vérifier le tableau de bord Mailtrap

## Dépannage

### Erreur: "Invalid login: 535-5.7.8 Username and Password not accepted"
- Vérifier les credentials SMTP
- Pour Gmail: s'assurer d'utiliser une App Password (pas le mot de passe du compte)
- Vérifier que l'authentification 2FA est activée sur le compte Gmail

### Erreur: "ECONNREFUSED" ou "ETIMEDOUT"
- Vérifier que SMTP_HOST et SMTP_PORT sont corrects
- Vérifier la connectivité réseau depuis le container

### Emails non reçus mais pas d'erreur
- Vérifier les logs avec: `docker compose logs api | grep -i "email\|mail"`
- Vérifier le dossier Spam
- Pour Gmail: autoriser les "Less secure apps" si applicable

## Logs pertinents
Les logs d'email sont disponibles dans:
- `api/logs/error-*.log` - Erreurs SMTP
- `docker compose logs api` - Logs en temps réel du service

Rechercher les patterns:
```
MailService: failed to send email
EMAIL_SENDING_FAILED
Invalid login
SMTP
```

## État actuel (2026-06-12)
✅ Variables SMTP ajoutées à `docker-compose.yml` (placeholders)
✅ Backend configuré pour retourner erreurs d'envoi explicites
✅ Dépendances nodemailer disponibles
⏳ À faire: Ajouter credentials SMTP réels et redémarrer les services
