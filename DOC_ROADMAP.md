# BigPharma 1.2 - Roadmap & Implementation Plan

This document outlines the strategic roadmap for the finalization, securing, and commercialization of the BigPharma Pharmaceutical Management System.

## 📅 Roadmap: Phase 1 - Consolidation (Week 1)
Focus: Technical debt, architectural alignment, and core security.

- [x] **Architectural Split**: Separate Internal Web (React), Client App (Flutter), and Staff Platform (Flutter).
- [x] **Role Harmonization**: Update all roles to `administrateur`, `agent de vente`, `gestionnaire de stock`, `pharmacien`, `personnel autorisé`.
- [ ] **Fine-Grained Permissions**: Implement a matrix of permissions (ACL) for each role in the database.
- [ ] **Real-time Sync**: Integrate Socket.io for instant inventory updates and order notifications.

## 📅 Roadmap: Phase 2 - Premium UI & Design (Week 2)
Focus: Visual excellence and user experience.

- [ ] **Unified Design System**: Document colors, typography, and component behavior.
- [ ] **Staff Dashboard Polish**: Finalize the React dashboard with advanced charts and data tables.
- [ ] **Client App UX**: Implement skeleton loaders, smooth transitions, and a premium "Health-Tech" feel.
- [ ] **Responsive Optimization**: Ensure seamless transition between mobile and desktop for all modules.

## 📅 Roadmap: Phase 3 - Business Workflows (Week 3)
Focus: Functional completeness.

- [ ] **POS Workflow**: Optimized sales interface for `agent de vente`.
- [ ] **Inventory Lifecycle**: Procurement -> Lot Tracking -> Expiration Alerts for `gestionnaire de stock`.
- [ ] **Advanced Analytics**: Detailed business intelligence charts and forecasting.
- [ ] **Financial Reporting**: Daily/Monthly P&L reports for `administrateur`.

## 📅 Roadmap: Phase 4 - Security & Deployment (Week 4)
Focus: Production readiness.

- [ ] **HTTPS/SSL Enforcement**: Policy documentation and Nginx configuration.
- [ ] **API Auditing**: Comprehensive log of every sensitive action (who, when, what).
- [ ] **Vulnerability Scan**: Integrate automated security testing.
- [ ] **CI/CD Pipeline**: Automated deployment to Kubernetes/Docker environments.

---

## 🔄 Business Workflows

### 1. The Sales Loop (Vente)
1. **Selection**: `agent de vente` scans items or selects from stock.
2. **Verification**: System checks for expiration and availability.
3. **Payment**: Process payment (Cash/Mobile Money).
4. **Update**: Real-time decrement of stock; log generated in `activityLogs`.
5. **Notification**: `pharmacien` receives a summary if a controlled substance is sold.

### 2. The Order Loop (Commande Client)
1. **Creation**: Client places order via `client_app`.
2. **Validation**: `agent de vente` or `pharmacien` validates the order.
3. **Preparation**: `gestionnaire de stock` prepares the package.
4. **Status Update**: Client is notified via Push/Socket.
5. **Finalization**: Order marked as "Délivré" upon pickup/delivery.

---

## 🔒 Security Architecture

| Feature | Implementation Status |
|---------|-----------------------|
| **Authentication** | JWT with Refresh Tokens (Done) |
| **Password Hashing** | Bcrypt with Salt (Done) |
| **Input Sanitization** | Express-mongo-sanitize / Joi (Done) |
| **Role-Based Access** | Standard RBAC (Done) |
| **Fine Permissions** | Per-action ACL (Planned) |
| **Audit Logs** | Global Activity Logger (In Progress) |
| **Rate Limiting** | DDOS protection (Done) |
