# Changelog

## 2026-04-15

### Security
- Removed local tracked secrets from `api/.env` and switched to `.env.example` placeholders only.
- Added strict startup validation for required env vars (`JWT_SECRET`, `MONGODB_URI`) outside test mode.
- Removed insecure JWT fallback secret from authentication middleware and token generation.
- Added `.env` ignore rules at repo level and API level.
- Added secret rotation note in README.

### Backend
- Split runtime into `api/app.js` (Express app) and `api/server.js` (listener).
- Mounted and aligned routes for:
  - `/api/sales`
  - `/api/finance`
  - `/api/activityLogs`
  - `/api/QuestionsClients` (alias to consultations)
  - `/api/dashboard`
  - `/api/consultations`
- Added `/api/settings` module with endpoints:
  - `GET /profile`
  - `PUT /permissions` (admin)
  - `PUT /2fa`
  - `POST /backup`
  - `POST /restore`
  - `POST /export`
  - `POST /import`
- Implemented auth missing features:
  - `POST /api/auth/forgot-password`
  - `POST /api/auth/reset-password`
  - `PUT /api/auth/me`
  - `POST /api/auth/change-password`
- Added Joi validation middleware and auth schemas.
- Standardized JSON response shape with helper (`success`, `message`, `data`, `code`) and improved error middleware.

### Frontend
- Reworked `ApiConstants` with environment-based URL and new settings/auth endpoints.
- Updated `AuthService` with:
  - session persistence
  - profile update
  - forgot/reset password
  - change password
- Updated `AuthProvider` to expose forgot/reset/update profile actions.
- Replaced mock SettingsProvider flow with real API calls via new `SettingsService`.
- Wired login “forgot password” flow to backend.
- Wired settings password change dialog to real API call.

### Tests
- Added Jest + Supertest integration setup in `api`.
- Added integration tests for:
  - register/login
  - forgot/reset password (including invalidated token)
  - `PUT /api/auth/me`
  - users role permission checks
  - mounted protected routes for sales/finance/activity/questions/settings/dashboard/consultations
- Replaced trivial Flutter widget test with focused tests for auth UI/provider/wrapper behavior.
- Added unified test runner script: `scripts/test-all.ps1`.

### Documentation
- Replaced template README with operational project documentation.
