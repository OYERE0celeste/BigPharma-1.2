import 'dart:ui';
import 'package:flutter/material.dart';
import 'widgets/global_navbar.dart';
import 'widgets/app_sidebar.dart';
import 'pharmacy_dashboard_page.dart';
import 'ventes/pharmacy_sales_page.dart';
import 'products/pharmacy_products_page.dart';
import 'clients/pharmacy_clients_page.dart';
import 'activites/activity_register_page.dart';
import 'commandes/orders_page.dart';
import 'finances/pharmacy_finance_page.dart';
import 'settings/settings_dialog.dart';
import 'settings/user_management_page.dart';
import 'support/pharmacy_support_page.dart';

// =====================================================================
// MAIN LAYOUT WIDGET - Enveloppe toutes les pages
// =====================================================================

class MainLayout extends StatefulWidget {
  final String pageTitle;
  final Widget child;

  const MainLayout({
    super.key,
    this.pageTitle = 'Dashboard',
    this.child = const SizedBox.shrink(),
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  bool _isSidebarOpen = false;
  late AnimationController _sidebarAnimationController;

  late String _pageTitle;
  late Widget _currentPage;

  @override
  void initState() {
    super.initState();
    _pageTitle = widget.pageTitle;
    _currentPage = widget.child is SizedBox
        ? const PharmacyDashboardPage()
        : widget.child;

    _sidebarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _sidebarAnimationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
      if (_isSidebarOpen) {
        _sidebarAnimationController.forward();
      } else {
        _sidebarAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ===== MAIN COLUMN (NAVBAR + FULL-WIDTH CONTENT) =====
          Column(
            children: [
              GlobalNavbar(
                onMenuToggle: _toggleSidebar,
                isSidebarOpen: _isSidebarOpen,
                onProfileAction: (action) {
                  if (action == 'activity') {
                    _navigateTo('Activity', const PharmacyActivityRegisterPage());
                  } else if (action == 'profile') {
                    // Profile is currently handled by showDialog in Navbar, 
                    // but we could also navigate if needed.
                  }
                },
              ),
              Expanded(
                child: Container(color: Colors.grey[50], child: _currentPage),
              ),
            ],
          ),

          // ===== OVERLAY SIDEBAR + BLUR (TOUTES LARGEURS) =====
          _buildOverlaySidebarWithBlur(),
        ],
      ),
    );
  }

  void _navigateTo(String title, Widget page) {
    setState(() {
      _pageTitle = title;
      _currentPage = page;
      if (_isSidebarOpen) {
        _toggleSidebar();
      }
    });
  }

  Map<String, VoidCallback> _buildNavigationCallbacks() {
    return {
      'Dashboard': () =>
          _navigateTo('Dashboard', const PharmacyDashboardPage()),
      'Stock': () => _navigateTo('Stock', const PharmacyProductsPage()),
      'Sales': () => _navigateTo('Sales', const PharmacySalesPage()),
      'Commandes': () => _navigateTo('Commandes', const PharmacyOrdersPage()),
      'Clients': () => _navigateTo('Clients', const PharmacyClientsPage()),
      'Activity': () =>
          _navigateTo('Activity', const PharmacyActivityRegisterPage()),
      'Consultations': () => _navigateTo(
        'Consultations',
        const FeatureNotAvailablePage(title: 'Consultations'),
      ),
      'Finances': () => _navigateTo('Finances', const PharmacyFinancePage()),
      'Support': () => _navigateTo('Support', const PharmacySupportPage()),
      'Users': () => _navigateTo('Users', const UserManagementDialog()),
      'Paramètres': () {
        if (_isSidebarOpen) _toggleSidebar();
        SettingsDialog.show(context);
      },
    };
  }

  /// Overlay sidebar for tablet/mobile with blur + dark background
  Widget _buildOverlaySidebarWithBlur() {
    final size = MediaQuery.of(context).size;
    const navbarHeight = 70.0;

    return IgnorePointer(
      ignoring: !_isSidebarOpen,
      child: AnimatedOpacity(
        opacity: _isSidebarOpen ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: Stack(
          children: [
            // Darkened, blurred background (seulement sous la barre du haut)
            GestureDetector(
              onTap: _toggleSidebar,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  margin: const EdgeInsets.only(top: navbarHeight),
                  width: size.width,
                  height: size.height - navbarHeight,
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
            // Sliding sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: navbarHeight, // sous la navbar
              bottom: 0,
              left: _isSidebarOpen ? 0 : -260,
              child: SizedBox(
                width: 240,
                child: Material(
                  elevation: 8,
                  child: AppSidebar(
                    selectedLabel: _pageTitle,
                    callbacks: _buildNavigationCallbacks(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// ENHANCED RESPONSIVE LAYOUT HELPER
// =====================================================================

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget tabletBody;
  final Widget desktopBody;

  const ResponsiveLayout({
    required this.mobileBody,
    required this.tabletBody,
    required this.desktopBody,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          return mobileBody;
        } else if (constraints.maxWidth < 1200) {
          return tabletBody;
        } else {
          return desktopBody;
        }
      },
    );
  }
}

// =====================================================================
// FALLBACK PAGE FOR MISSING FEATURES
// =====================================================================

class FeatureNotAvailablePage extends StatelessWidget {
  final String title;
  const FeatureNotAvailablePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '$title en construction...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nous travaillons sur cette fonctionnalité.',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
