# 🎯 PLAN D'IMPLÉMENTATION - SCANNER QR/CODE-BARRES

## PHASE 1: PRÉPARATION DATABASE (1-2 heures)

### 1.1 Ajouter Index & Champ QR Code
```javascript
// File: api/migrations/2024_add_barcode_qrcode_indexes.js
// - Ajouter index unique compound: {companyId, barcode}
// - Ajouter champ qrCode à ProductSchema
// - Indexer qrCode aussi
```

### 1.2 Vérifier Intégrité
- Vérifier pas de doublons barcode
- Vérifier barcode values non-null
- Ajouter contrainte unique (replaceIndex si besoin)

---

## PHASE 2: BACKEND API (2-3 heures)

### 2.1 Endpoints Recherche
```
GET /products/search/barcode/:code
GET /products/search/qrcode/:code
GET /products/search/code/:code (auto-detect)
```

### 2.2 Contrôleur
- Sanitize input
- Validate format
- Recherche DB indexée
- Gestion erreurs (not found, multiple, etc.)

### 2.3 Validation
- Tester avec EAN-13, EAN-8, QR Code
- Tester code invalide
- Tester performance: 100ms max

---

## PHASE 3: SERVICES FLUTTER (3-4 heures)

### 3.1 ScannerService
- ✅ Initialiser webcam
- ✅ Stream frames continus
- ✅ Gestion pause/resume
- ✅ Gestion erreurs (pas de cam, permission)
- ✅ Format supportés: QR, EAN-13, EAN-8, Code128, Code39, UPC

### 3.2 BarcodeParserService
- Parse QR code content (URL, produit, etc.)
- Parse barcode (EAN, UPC format)
- Détecte type automatiquement
- Nettoie/valide

### 3.3 ScanCacheService
- Store recent 50 scans
- Cooldown 500ms par code
- LRU eviction
- Clear quand app ferme

### 3.4 ScannerProvider (ChangeNotifier)
- State: idle, scanning, found, notFound, error
- `Future<Product?> scanProduct(String code)`
- Notifie listeners UI
- Gère dernier résultat

---

## PHASE 4: UI WIDGETS (2-3 heures)

### 4.1 ScannerDialog
- Modal complet avec scanner
- Overlay avec coins lumineux
- Ligne scan animée
- Indicateur "scanning"
- Bouton fermer/torch toggle

### 4.2 ScanResultCard
- Affiche produit trouvé
- Prix, stock, expiration
- Bouton "Ajouter Panier"
- Bouton "Ouvrir Fiche"

### 4.3 ScannerOverlay
- Coins animés
- Zone focus
- Indicateur détection
- Message état (scanning, error, etc.)

### 4.4 QuickCreateDialog
- Form création rapide produit
- Prérempli: barcode, qrCode
- Fields: nom, catégorie, prix
- Bouton créer

---

## PHASE 5: INTÉGRATION PAGES (2-3 heures)

### 5.1 PharmacyProductsPage
- Bouton "Scanner" en header
- Click → Ouvre ScannerDialog
- Résultat → Affiche fiche produit
- Pas de cache (toujours recherche DB)

### 5.2 PharmacySalesPage
- Bouton "Scanner" sous recherche
- Click → Mode scan continu
- Chaque scan → Ajoute auto au panier
- Toast: "Produit ajouté"
- Mode ultra-rapide pour caisse 💨

### 5.3 Navigation
- Intégrer boutons
- Passer ScannerProvider en context
- Gestion fermeture/erreurs

---

## PHASE 6: OPTIMISATIONS (2-3 heures)

### 6.1 Performance
- ✅ Index barcode search < 50ms
- ✅ Camera frame rate: 30fps
- ✅ Scan detect: < 200ms
- ✅ Debounce API calls (100ms)

### 6.2 Feedback UX
- ✅ Son scan (success.wav)
- ✅ Vibration haptic (si device support)
- ✅ Animation réussite
- ✅ Toast notifications

### 6.3 Cache & Offline
- ✅ Cache 50 derniers scans
- ✅ Offline mode: affiche cached
- ✅ Sync quand reconnect

### 6.4 Gestion Mémoire
- ✅ Dispose scanner resources
- ✅ Clear cache au logout
- ✅ Stream cleanup

---

## PHASE 7: TESTS (2-3 heures)

### 7.1 Tests Unitaires
```
- ScanCacheService: dedup, LRU, cooldown
- BarcodeParserService: parse QR, EAN, format
- ScannerProvider: state transitions
```

### 7.2 Tests Widget
```
- ScannerDialog: render, close
- ScanResultCard: affichage produit
- Intégration pages
```

### 7.3 Tests Intégration
```
- End-to-end: scan → API → panier
- Erreurs: pas de cam, API down
- Performance: 100 scans rapides
- Double scan: déduplication
```

### 7.4 Tests Manuels
```
- Scanner EAN-13, EAN-8, QR
- Multiple webcams
- Mauvaise luminosité
- Scan rapides (< 500ms interval)
```

---

## DURÉE TOTALE ESTIMÉE: **15-18 heures**

| Phase | Durée | Status |
|-------|-------|--------|
| 1. Database | 1-2h | ⏳ À faire |
| 2. Backend | 2-3h | ⏳ À faire |
| 3. Services Flutter | 3-4h | ⏳ À faire |
| 4. UI Widgets | 2-3h | ⏳ À faire |
| 5. Intégration Pages | 2-3h | ⏳ À faire |
| 6. Optimisations | 2-3h | ⏳ À faire |
| 7. Tests | 2-3h | ⏳ À faire |

---

## PRIORITÉ ORDRE IMPLÉMENTATION

```
1️⃣ Phase 1: Database (fondation)
2️⃣ Phase 2: Backend API (data layer)
3️⃣ Phase 3: Services Flutter (business logic)
4️⃣ Phase 4: UI Widgets (presentation)
5️⃣ Phase 5: Integration (wiring)
6️⃣ Phase 6: Optimizations (polish)
7️⃣ Phase 7: Tests (quality)
```

---

## DÉPENDANCES À VÉRIFIER

```yaml
dependencies:
  mobile_scanner: ^7.2.0         # ✅ Déjà présent
  provider: ^6.1.1               # ✅ Déjà présent
  http: ^1.6.0                   # ✅ Déjà présent
  
  # À considérer:
  # - vibration: ^1.8.1         # Pour feedback haptic
  # - audioplayers: ^5.0.0      # Pour son scan
  # - cached_network_image: ... # Si affichage image produit
```

---

## CONTRAINTES IMPORTANTES

✅ **SOLID Principles**: Séparation concerns (service/controller/widget)
✅ **Réutilisabilité**: Services génériques, widgets composables
✅ **Performance**: Index DB, cache local, throttling
✅ **Maintenabilité**: Code structuré, tests complets
✅ **UX**: Feedback immédiat, animations fluides
✅ **Sécurité**: Input validation, rate limiting

---

## NOTES SPÉCIALES

- **Desktop Focus**: Webcam USB + intégrée
- **Latence**: Target < 500ms scan→panier
- **Offline**: Cache permettra offline basics
- **Future**: Intégration stockage, historique scan, analytics
