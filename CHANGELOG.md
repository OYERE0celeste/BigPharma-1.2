# Changelog

All notable changes to the BigPharma 1.2 project will be documented in this file.

## [1.2.0] - 2026-04-30

### Added
- **Infrastructure**: Docker & Docker Compose setup for API, MongoDB, and Nginx.
- **CI/CD**: GitHub Actions pipeline for automated linting, testing, and deployment.
- **Security**: 
    - Refresh Token system with rotation.
    - Data-at-rest encryption for sensitive fields (phone, address).
    - Multi-tenancy enforcement middleware.
    - Global rate limiting.
    - Security headers via Helmet (CSP, etc.).
    - NoSQL & XSS sanitization.
- **Monitoring**: 
    - Sentry integration for error tracking.
    - Winston structured logging with rotation.
    - Prometheus metrics endpoint (`/metrics`).
    - Request ID tracing.
- **Performance**:
    - Redis caching for dashboard.
    - Gzip response compression.
    - Optimized DB indexes.
    - API Versioning (`/v1`).
- **Features**:
    - Swagger API documentation (`/api-docs`).
    - PDF Report generation.
    - Email notification service.
    - CSV Mass import/export.
- **Quality**:
    - Centralized constants for roles and error codes.
    - Standardized API response format.
    - TypeScript configuration.

### Changed
- Refactored `authController` to support refresh tokens and rotation.
- Updated `app.js` with modern security and monitoring middleware.
- Standardized error handling and response utilities.

### Fixed
- Fixed email regex vulnerabilities in Mongoose models.
- Resolved race conditions in integration tests.
- Improved database indexing for critical modules.
