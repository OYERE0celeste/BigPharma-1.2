# BigPharma POS - Quick Start Guide

## 🚀 Quick Start (5 minutes)

### Step 1: Install Dependencies
```bash
cd d:\Projets\BigPharma 1.1\epharma
flutter pub get
```

### Step 2: Run the Application
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

### Step 3: Navigate to POS
1. Application opens to Dashboard
2. Click **"Sales"** in the sidebar
3. You're now in the POS system! 🎉

---

## 📖 Manual Testing Guide

### Test Case 1: Product Search
**Goal**: Verify product search filtering works

1. Go to Sales page
2. In the search box, type: **"Amox"**
3. **Expected**: Only "Amoxicillin 500mg" appears
4. Clear search box
5. Type: **"antibiotics"**
6. **Expected**: Shows "Amoxicillin 500mg" and "Azithromycin 500mg"

✅ **Pass/Fail**: _____

### Test Case 2: Add Product to Cart
**Goal**: Verify products can be added to cart

1. Click on **"Paracetamol 500mg"** product card
2. **Expected**: 
   - Product appears in right panel "SHOPPING CART"
   - Cart shows "1 item(s)"
   - Notification appears: "Paracetamol 500mg added to cart"
3. Click on same product again
4. **Expected**: Quantity increases to 2

✅ **Pass/Fail**: _____

### Test Case 3: Stock Status Badges
**Goal**: Verify stock status badges display correctly

1. Look at product cards
2. **Vitamin C 1000mg** should show: **"Out of Stock"** (RED)
3. **Omeprazole 20mg** should show: **"Low Stock"** (ORANGE) - only 3 items
4. **Paracetamol 500mg** should show: **"Available"** (GREEN)

✅ **Pass/Fail**: _____

### Test Case 4: Prescription Required Indicator
**Goal**: Verify Rx badge on prescription-required drugs

1. Look at product cards
2. **Amoxicillin 500mg** should have **"Rx"** badge (RED)
3. **Metformin 1000mg** should have **"Rx"** badge (RED)
4. **Paracetamol 500mg** should NOT have "Rx" badge

✅ **Pass/Fail**: _____

### Test Case 5: Cart Item Quantity Control
**Goal**: Verify quantity can be increased/decreased

1. Add "Ibuprofen 400mg" to cart
2. In cart item, click **"+"** button
3. **Expected**: Quantity increases to 2
4. Click **"-"** button
5. **Expected**: Quantity decreases back to 1
6. Click **"-"** when quantity is 1
7. **Expected**: Button is disabled (greyed out)

✅ **Pass/Fail**: _____

### Test Case 6: Remove from Cart
**Goal**: Verify items can be removed

1. Add two different products to cart
2. Click **trash icon** on one item
3. **Expected**: Item removed, cart count decreases
4. Verify item total updates

✅ **Pass/Fail**: _____

### Test Case 7: Out of Stock Prevention
**Goal**: Verify out-of-stock items can't be added

1. Click on **"Vitamin C 1000mg"** (0 stock)
2. **Expected**: 
   - Either button disabled
   - Or notification shows "Product is out of stock"
3. Item should NOT be added to cart

✅ **Pass/Fail**: _____

### Test Case 8: Prescription Warning
**Goal**: Verify Rx warning appears for prescription items

1. Add **"Amoxicillin 500mg"** to cart
2. **Expected**: 
   - Red warning banner appears: "This cart contains prescription-required items"
   - "Attach Prescription" button visible
   - "Verified" checkbox visible
3. Try to confirm sale
4. **Expected**: Sale blocked with message about prescription

✅ **Pass/Fail**: _____

### Test Case 9: Prescription Verification
**Goal**: Verify prescription verification works

1. With Rx item in cart, check the "Verified" checkbox
2. **Expected**: Checkbox becomes checked
3. Now try to confirm sale
4. **Expected**: Sale should proceed (if no other errors)

✅ **Pass/Fail**: _____

### Test Case 10: Discount Application
**Goal**: Verify discount is calculated correctly

1. Add item with price $5.50 (Amoxicillin) to cart
2. In "Discount (\$)" field, enter: **1.00**
3. **Expected**: TOTAL amount decreases by $1.00
4. Change discount to: **2.50**
5. **Expected**: TOTAL amount decreases by $2.50

✅ **Pass/Fail**: _____

### Test Case 11: Payment Methods
**Goal**: Verify all payment methods are selectable

1. Add item to cart
2. Look at "Payment Method" section
3. Click **"Cash"** - should be selected
4. Click **"Card"** - should toggle
5. Click **"Mobile Money"** - should toggle
6. **Expected**: Selection updates properly

✅ **Pass/Fail**: _____

### Test Case 12: Change Calculation
**Goal**: Verify change is calculated correctly

1. Add item(s) totaling $5.50
2. In "Amount Received (\$)" field, enter: **10.00**
3. **Expected**: Change shows **$4.50**
4. Change amount to: **20.00**
5. **Expected**: Change shows **$14.50**

✅ **Pass/Fail**: _____

### Test Case 13: Confirm Sale
**Goal**: Verify sale confirmation works

1. Add items totaling at least $5.00 to cart (no Rx items)
2. Enter payment amount more than total
3. Click **"CONFIRM SALE"** button
4. **Expected**:
   - Success dialog appears
   - Shows invoice number (INV-2026-XXXX)
   - Shows items count
   - Shows total
   - Shows payment method
   - Shows change
5. Click "Close" or "Print Invoice"
6. **Expected**: Cart clears, ready for new sale

✅ **Pass/Fail**: _____

### Test Case 14: Empty Cart Validation
**Goal**: Verify can't confirm with empty cart

1. Ensure cart is empty (click "Clear" if needed)
2. Click **"CONFIRM SALE"**
3. **Expected**: 
   - Notification appears: "Cart is empty"
   - Sale is NOT confirmed

✅ **Pass/Fail**: _____

### Test Case 15: Sales History View
**Goal**: Verify sales history tab works

1. Confirm at least one sale (from Test 13)
2. Click **"History"** button at top
3. **Expected**: 
   - View switches to sales history
   - Table shows invoice numbers
   - Shows dates/times
   - Shows amounts
   - Shows payment methods
4. Click **"New Sale"** button
5. **Expected**: View switches back to POS

✅ **Pass/Fail**: _____

### Test Case 16: Sales History Date Filter
**Goal**: Verify date filtering works

1. In sales history view
2. Click **"Filter by Date"** button
3. **Expected**: Date picker opens
4. Select today's date
5. **Expected**: Table filters to show only today's sales
6. Click **"Clear Date"**
7. **Expected**: All sales show again

✅ **Pass/Fail**: _____

### Test Case 17: Multiple Lots (Advanced)
**Goal**: Verify lot selection for products with multiple lots

1. Search for **"Ibuprofen 400mg"**
2. **Expected**: Has 2 lots (LOT-2024-003 and LOT-2024-004)
3. Add to cart
4. **Expected**: System selects nearest expiration (2024-003)
5. In cart, should see: "Lot: LOT-2024-003"

✅ **Pass/Fail**: _____

### Test Case 18: Stock Limit (Advanced)
**Goal**: Verify can't exceed lot quantity

1. Add **"Omeprazole 20mg"** (only 3 in stock)
2. In cart, click **"+"** button 3 times
3. **Expected**: Quantity is 3
4. Click **"+"** again
5. **Expected**: Button disabled, can't go above 3

✅ **Pass/Fail**: _____

---

## 🐛 Troubleshooting

### Application won't start
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run -d windows
```

### Compile errors
```bash
# Check for errors
flutter analyze

# Format code
flutter format lib/
```

### Hot reload issues
- Use **R** key twice to restart
- Or use **Q** to quit and restart

---

## 📊 Test Summary

| Test # | Category | Test Case | Status |
|--------|----------|-----------|---------|
| 1 | Search | Product search filtering | ☐ Pass ☐ Fail |
| 2 | Cart | Add to cart | ☐ Pass ☐ Fail |
| 3 | Status | Stock badges | ☐ Pass ☐ Fail |
| 4 | Status | Rx badge | ☐ Pass ☐ Fail |
| 5 | Cart | Quantity control | ☐ Pass ☐ Fail |
| 6 | Cart | Remove item | ☐ Pass ☐ Fail |
| 7 | Validation | Out of stock | ☐ Pass ☐ Fail |
| 8 | Rx | Warning banner | ☐ Pass ☐ Fail |
| 9 | Rx | Verification | ☐ Pass ☐ Fail |
| 10 | Payment | Discount | ☐ Pass ☐ Fail |
| 11 | Payment | Payment methods | ☐ Pass ☐ Fail |
| 12 | Payment | Change calculation | ☐ Pass ☐ Fail |
| 13 | Sale | Confirm sale | ☐ Pass ☐ Fail |
| 14 | Validation | Empty cart | ☐ Pass ☐ Fail |
| 15 | History | History view | ☐ Pass ☐ Fail |
| 16 | History | Date filter | ☐ Pass ☐ Fail |
| 17 | Advanced | Multiple lots | ☐ Pass ☐ Fail |
| 18 | Advanced | Stock limit | ☐ Pass ☐ Fail |

**Total Passed**: ____ / 18  
**Pass Rate**: ____ %

---

## 🎨 Visual Verification

### Layout Check
- [ ] Left panel (products) is about 60% width
- [ ] Right panel (cart) is about 40% width
- [ ] Both panels visible without scrolling on 1400px+ screen
- [ ] Colors match design system (green/blue/red)

### Responsiveness Check
- [ ] Product grid adjusts for screen size
- [ ] Cart text is readable
- [ ] Buttons are clickable (min 40px height)
- [ ] No overlapping content

### UX Check
- [ ] Search results update instantly
- [ ] Cart updates immediately on changes
- [ ] Calculations update in real-time
- [ ] Success dialogs appear appropriately
- [ ] Notifications show briefly

---

## 📈 Performance Check

### Startup Time
- Expected: < 3 seconds from launch to Sales page

### Search Performance
- Expected: < 100ms for product filter

### Cart Operations
- Expected: Instant response when clicking buttons

### Sales History Load
- Expected: Table loads in < 1 second for 100 items

---

## ✅ Sign-Off

**Tester Name**: _________________  
**Date**: _________________  
**Overall Status**: ☐ PASS ☐ FAIL  
**Comments**: _________________

---

**Note**: This is a mock data implementation. For production use:
1. Replace mock products with real database
2. Add user authentication
3. Implement inventory tracking
4. Add payment gateway integration
5. Setup audit logging
