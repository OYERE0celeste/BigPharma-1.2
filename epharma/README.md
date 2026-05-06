# ePharma

Application full-stack de gestion pharmaceutique unifiée.

Cette application Flutter combine les fonctionnalités pour les clients et les pharmacies en une seule app, avec un routage basé sur les rôles utilisateur.

- **Pour les clients** : Recherche de médicaments, commandes, historique des achats.
- **Pour les pharmacies** : Gestion des stocks, validation des prescriptions, dashboard financier.

- Frontend: Flutter (`lib/`)
- Backend: Node.js/Express + MongoDB (`api/`)
- Base API: `/api`

## Prérequis

- Flutter SDK (stable)
- Dart SDK (via Flutter)
- Node.js 18+
- npm 9+
- MongoDB (local ou distant)

## Installation

### 1) Backend

```bash
cd api
npm install
```

Copier les variables d'environnement:

```bash
cp .env.example .env
```

### 2) Frontend

```bash
flutter pub get
```

## Variables d'environnement backend

Fichier: `api/.env`

Variables requises:

- `MONGODB_URI` (obligatoire, e.g. `mongodb://localhost:27017/BigPharmaDB`)
- `JWT_SECRET` (obligatoire)

Variables optionnelles:

- `PORT` (défaut: `5000`)
- `CORS_ORIGIN` (défaut: `*`)

## Structure de l'application (Hybride)

L'application `epharma` est conçue comme un portail unifié. L'organisation des dossiers reflète cette dualité :

- `lib/` : Code Flutter principal
  - `models/` : Modèles pour l'interface Staff (Dashboard)
  - `client_models/` : Modèles pour l'interface Client
  - `services/` : Services API pour Staff
  - `client_services/` : Services API pour Clients (Cart, Profile, Orders)
  - `providers/` : Gestion d'état pour Staff
  - `pages/client/` : Pages du portail client (Home, Support, etc.)
  - `screens/` : Pages du dashboard staff et écrans communs

## Authentification et Rôles

L'application utilise l'API backend pour l'authentification. Les rôles supportés :
- `client` : Redirige vers `HomePage()` (Client)
- `pharmacien`, `admin`, etc. : Redirige vers `MainLayout()` (Staff Dashboard)

Après connexion, l'app redirige automatiquement vers l'interface appropriée selon le rôle défini dans l'objet User.

Exemple de configuration `.env` locale:

```env
MONGODB_URI=mongodb://127.0.0.1:27017/BigPharmaDB
JWT_SECRET=change-me-strong-secret
PORT=5000
CORS_ORIGIN=http://localhost:3000,http://localhost:5000,http://127.0.0.1:5000
FEATURE_2FA_ENABLED=false
NODE_ENV=development
```

En developpement, l'API autorise aussi automatiquement les origines locales `localhost`, `127.0.0.1` et `::1` sur n'importe quel port pour faciliter `flutter run -d chrome`.

## Lancement local

### Backend

```bash
cd api
npm run dev
```

### Frontend

```bash
flutter run
```

Pour forcer l'URL API côté Flutter:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:5000/api
```

## Jeux de données

Vous pouvez créer un tenant + admin via:

- `POST /api/auth/register`

Puis créer des utilisateurs internes via:

- `POST /api/users` (admin uniquement)

## Tests

### Commande stable unique (projet)

```bash
powershell -ExecutionPolicy Bypass -File scripts/test-all.ps1
```

### Détail

- Backend: `cd api && npm run test:api`
- Frontend: `flutter test`

## Déploiement

1. Définir les variables de production (`MONGODB_URI`, `JWT_SECRET`, `CORS_ORIGIN`).
2. Activer HTTPS et reverse-proxy (Nginx/Traefik).
3. Déployer API (`npm run start`) avec process manager (PM2/systemd).
4. Build Flutter web/mobile selon la cible.

## Troubleshooting

- `Missing required environment variables`:
  - Vérifier `api/.env` et les clés obligatoires.
- `Unauthorized: invalid or expired token`:
  - Vérifier expiration JWT et secret partagé.
- Erreurs CORS:
  - Ajuster `CORS_ORIGIN` et verifier que l'API est bien demarree sur `http://localhost:5000`.
- `MongoDB connection error`:
  - Vérifier `MONGODB_URI` et l'accessibilité réseau.

## Sécurité et rotation des secrets

- Ne jamais versionner les fichiers `.env`.
- Utiliser un gestionnaire de secrets (Vault, AWS Secrets Manager, etc.).
- Rotation recommandée:
  1. Générer un nouveau `JWT_SECRET`.
  2. Déployer en fenêtre contrôlée.
  3. Forcer la reconnexion des sessions actives.
  4. Révoquer l'ancien secret.

## Changelog

Consulter `CHANGELOG.md` pour le détail des correctifs implémentés.
