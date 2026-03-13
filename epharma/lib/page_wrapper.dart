import 'package:epharma/main_layout.dart';
import 'package:flutter/material.dart';

// =====================================================================
// PAGE WRAPPER - Utility class to wrap pages with MainLayout
// =====================================================================

class PageWrapper extends StatelessWidget {
  final Widget page;
  final String? pageTitle;

  const PageWrapper({required this.page, this.pageTitle, super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(pageTitle: pageTitle, child: page);
  }
}

// =====================================================================
// WRAPPED PAGE DEFINITIONS - Ready to use in routes
// =====================================================================

// Import other pages at the top of main.dart to use these:
// import 'pharmacy_dashboard_page.dart' as dashboard;
// import 'pharmacy_products_page.dart' as products;
// etc.

// Example usage in main.dart routes:
// '/': (context) => PageWrapper(
//   page: const dashboard.DashboardPageContent(),
//   pageTitle: 'Dashboard',
// ),

// =====================================================================
// MINI LAYOUT - For pages that need custom layout control
// =====================================================================

class MiniLayout extends StatelessWidget {
  final Widget child;
  final Widget? appBar;
  final Color backgroundColor;
  final bool showSidebar;

  const MiniLayout({
    required this.child,
    this.appBar,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.showSidebar = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(color: backgroundColor, child: child);
  }
}

// =====================================================================
// LAYOUT MANAGER - Singleton for managing global layout state
// =====================================================================

class LayoutManager {
  static final LayoutManager _instance = LayoutManager._internal();

  factory LayoutManager() {
    return _instance;
  }

  LayoutManager._internal();

  bool _isSidebarVisible = true;
  String? _currentPage;

  bool get isSidebarVisible => _isSidebarVisible;
  String? get currentPage => _currentPage;

  void setSidebarVisible(bool value) {
    _isSidebarVisible = value;
  }

  void setCurrentPage(String? page) {
    _currentPage = page;
  }

  void reset() {
    _isSidebarVisible = true;
    _currentPage = null;
  }
}
