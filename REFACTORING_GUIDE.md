/// REFACTORING GUIDE - How to convert existing pages to use MainLayout
/// 
/// This file documents the process for converting pages to the new MainLayout system.
///
/// BEFORE (Old Structure):
/// ```
/// class MyPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(...),  // OPTIONAL
///       body: Row(
///         children: [
///           AppSidebar(...),  // REMOVED - now managed by MainLayout
///           Expanded(
///             child: MyContent(),
///           ),
///         ],
///       ),
///     );
///   }
/// }
/// ```
///
/// AFTER (New Structure):
/// ```
/// class MyPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MainLayout(
///       pageTitle: 'My Page Title',
///       child: const MyPageContent(),
///     );
///   }
/// }
///
/// class MyPageContent extends StatefulWidget {
///   // Move all the logic here from the old body
///   // Remove AppSidebar completely
///   // Remove Row wrapper
///   // Content automatically fills available space
/// }
/// ```
///
/// STEPS TO REFACTOR A PAGE:
/// 1. Import MainLayout
/// 2. Change page state: StatelessWidget → StatelessWidget or keep StatefulWidget for the Content
/// 3. Replace Scaffold + Row with MainLayout
/// 4. Move all content into a new *Content widget
/// 5. Remove AppSidebar initialization
/// 6. Remove Scaffold body Row structure
/// 7. Test navigation in navbar
///
/// EXAMPLE REFACTORING:
/// 
/// Original PharmacyProductsPage (250+ lines):
/// - Had AppSidebar + Callbacks
/// - Had full Row structure
/// - Had AppBar
///
/// New Structure:
/// - Main page wraps content in MainLayout
/// - Content class handles all the UI
/// - Navbar/Sidebar now managed globally
/// - 20-30 lines in main class, rest in Content class

/// =====================================================================
/// REFACTORED PAGES STATUS
/// =====================================================================

/// ✅ DONE:
/// - pharmacy_dashboard_page.dart → Refactored with MainLayout
///   - PharmacyDashboardPage (wrapper)
///   - DashboardPageContent (actual UI)

/// 🔄 IN PROGRESS:
/// - pharmacy_products_page.dart → Needs refactoring
/// - pharmacy_sales_page.dart → Needs refactoring  
/// - pharmacy_clients_page.dart → Needs refactoring
/// - pharmacy_activity_register_page.dart → Needs refactoring

/// QUICK MIGRATION CHECKLIST:
/// [ ] Add import for main_layout.dart
/// [ ] Create new [PageName]Content class
/// [ ] Move all business logic to Content class
/// [ ] Move all widgets to Content class
/// [ ] Replace main widget to return MainLayout
/// [ ] Remove AppSidebar imports if not used elsewhere
/// [ ] Remove Scaffold/Row structure
/// [ ] Test page renders correctly
/// [ ] Test navbar buttons work
/// [ ] Test hamburger menu toggles sidebar
/// [ ] Test responsive behavior

/// =====================================================================

// REFACTORING IN PROGRESS - Pages are being migrated gradually
// The old structure still works but will be deprecated
// New pages should use MainLayout pattern

// Migration Priority:
// 1. pharmacy_dashboard_page.dart ✅ DONE
// 2. pharmacy_products_page.dart → Next
// 3. pharmacy_sales_page.dart → Next
// 4. pharmacy_clients_page.dart → Next
// 5. pharmacy_activity_register_page.dart → Last
