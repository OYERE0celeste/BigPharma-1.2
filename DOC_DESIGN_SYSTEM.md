# BigPharma 1.2 - Design System & UI/UX Guidelines

## 🎨 Visual Identity

### Color Palette
- **Primary (Health/Trust)**: `#10b981` (Emerald 500)
- **Secondary (Professional/Modern)**: `#0f172a` (Slate 900)
- **Accent (Action/Focus)**: `#3b82f6` (Blue 500)
- **Warning (Urgency/Expiration)**: `#f59e0b` (Amber 500)
- **Danger (Errors/Low Stock)**: `#ef4444` (Red 500)
- **Background**: `#f8fafc` (Slate 50)

### Typography
- **Font Family**: `Inter` (Sans-serif)
- **Headings**: Semi-bold (600) or Bold (700)
- **Body**: Regular (400)
- **Data/Tables**: Medium (500) for readability

## 🧩 Core Components

### 1. The "Premium" Card
- **Border Radius**: `12px` (var(--radius-lg))
- **Border**: `1px solid #e2e8f0`
- **Shadow**: `0 4px 6px -1px rgb(0 0 0 / 0.1)`
- **Hover Effect**: Subtle lift `transform: translateY(-2px)`

### 2. Navigation
- **Sidebar**: White background, active item with primary light tint and vertical indicator.
- **Navbar**: Glassmorphism (`blur(10px)`) with transparent white background.

### 3. Data Presentation
- **Status Badges**: Rounded pills with light background and dark text (e.g., Green bg / Dark Green text for "Validé").
- **Empty States**: Minimalist illustrations with muted text.

## ✨ Experience Principles (UX)

- **Micro-interactions**: Use `framer-motion` (Web) or `flutter_animate` (Mobile) for all state transitions.
- **Loading**: Use **Skeleton Loaders** instead of simple spinners for a smoother feel.
- **Feedback**: Immediate visual feedback for every action (Snackbars, Toast notifications).
- **Density**: High density for staff dashboards (efficiency), Low density for client app (clarity).
