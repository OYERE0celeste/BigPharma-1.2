import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'activites/activity_register_page.dart';
import 'clients/pharmacy_clients_page.dart';
import 'commandes/orders_page.dart';
import 'finances/pharmacy_finance_page.dart';
import 'models/user_model.dart';
import 'pharmacy_dashboard_page.dart';
import 'products/pharmacy_products_page.dart';
import 'providers/auth_provider.dart';
import 'security/rbac.dart';
import 'settings/rights_management_page.dart';
import 'settings/settings_dialog.dart';
import 'settings/user_management_page.dart';
import 'support/pharmacy_support_page.dart';
import 'ventes/pharmacy_sales_page.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/global_navbar.dart';

typedef SectionNavigationCallback = void Function(String section);

class MainLayoutScope extends InheritedWidget {
  final SectionNavigationCallback navigateToSection;

  const MainLayoutScope({
    super.key,
    required this.navigateToSection,
    required super.child,
  });

  static MainLayoutScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainLayoutScope>();
  }

  @override
  bool updateShouldNotify(MainLayoutScope oldWidget) {
    return oldWidget.navigateToSection != navigateToSection;
  }
}

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

    final auth = context.read<AuthProvider>();
    final initialSection = widget.child is SizedBox
        ? _resolveInitialSection(auth.user)
        : widget.pageTitle;

    _pageTitle = _normalizeSection(initialSection);
    _currentPage = widget.child is SizedBox
        ? _pageForSection(initialSection)
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

  String _normalizeSection(String section) {
    switch (section) {
      case 'Stock':
        return 'Products';
      case 'POS':
        return 'Sales';
      case 'Commandes':
        return 'Orders';
      default:
        return section;
    }
  }

  String _resolveInitialSection(UserModel? user) {
    if (user == null) return 'Dashboard';

    const preferredSections = [
      'Dashboard',
      'Products',
      'Sales',
      'Clients',
      'Orders',
      'Support',
      'Finances',
      'Rights',
      'Users',
      'Activity',
    ];

    for (final section in preferredSections) {
      for (final entry in kSidebarEntries) {
        if (entry.key == section && user.canAny(entry.permissions)) {
          return section;
        }
      }
    }

    return 'Settings';
  }

  Widget _pageForSection(String section) {
    switch (_normalizeSection(section)) {
      case 'Dashboard':
        return const PharmacyDashboardPage();
      case 'Products':
        return const PharmacyProductsPage();
      case 'Sales':
        return const PharmacySalesPage();
      case 'Orders':
        return const PharmacyOrdersPage();
      case 'Clients':
        return const PharmacyClientsPage();
      case 'Activity':
        return const PharmacyActivityRegisterPage();
      case 'Finances':
        return const PharmacyFinancePage();
      case 'Support':
        return const PharmacySupportPage();
      case 'Users':
        return const UserManagementDialog();
      case 'Rights':
        return const RightsManagementDialog();
      default:
        return const PharmacyDashboardPage();
    }
  }

  bool _canAccessSection(String section) {
    final normalizedSection = _normalizeSection(section);
    if (normalizedSection == 'Settings') return true;

    final user = context.read<AuthProvider>().user;
    if (user == null) return false;

    for (final entry in kSidebarEntries) {
      if (entry.key == normalizedSection) {
        return user.canAny(entry.permissions);
      }
    }

    return false;
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
      body: MainLayoutScope(
        navigateToSection: _navigateToSection,
        child: Stack(
          children: [
            Column(
              children: [
                GlobalNavbar(
                  onMenuToggle: _toggleSidebar,
                  isSidebarOpen: _isSidebarOpen,
                  onProfileAction: (action) {
                    if (action == 'activity') {
                      _navigateToSection('Activity');
                    }
                  },
                  onNotificationNavigate: (type, data) {
                    switch (type) {
                      case 'order':
                        _navigateToSection('Orders');
                        break;
                      case 'support':
                      case 'review':
                      case 'complaint':
                        _navigateToSection('Support');
                        break;
                      case 'invoice':
                        _navigateToSection('Orders');
                        break;
                      case 'stock':
                        _navigateToSection('Products');
                        break;
                      default:
                        _navigateToSection(
                          _resolveInitialSection(
                            context.read<AuthProvider>().user,
                          ),
                        );
                    }
                  },
                ),
                Expanded(
                  child: Container(color: Colors.grey[50], child: _currentPage),
                ),
              ],
            ),
            _buildOverlaySidebarWithBlur(),
          ],
        ),
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

  void _navigateToSection(String section) {
    final normalizedSection = _normalizeSection(section);

    if (!_canAccessSection(normalizedSection)) {
      final fallback = _resolveInitialSection(
        context.read<AuthProvider>().user,
      );
      if (normalizedSection != fallback) {
        _navigateTo(fallback, _pageForSection(fallback));
      }
      return;
    }

    if (normalizedSection == 'Settings') {
      if (_isSidebarOpen) _toggleSidebar();
      SettingsDialog.show(context);
      return;
    }

    _navigateTo(normalizedSection, _pageForSection(normalizedSection));
  }

  Map<String, VoidCallback> _buildNavigationCallbacks() {
    return {
      'Dashboard': () => _navigateToSection('Dashboard'),
      'Products': () => _navigateToSection('Products'),
      'Sales': () => _navigateToSection('Sales'),
      'Orders': () => _navigateToSection('Orders'),
      'Clients': () => _navigateToSection('Clients'),
      'Activity': () => _navigateToSection('Activity'),
      'Finances': () => _navigateToSection('Finances'),
      'Support': () => _navigateToSection('Support'),
      'Users': () => _navigateToSection('Users'),
      'Rights': () => _navigateToSection('Rights'),
    };
  }

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
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: navbarHeight,
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
            'Nous travaillons sur cette fonctionnalite.',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
