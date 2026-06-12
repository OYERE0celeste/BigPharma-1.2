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
import 'widgets/bp_theme.dart';
import 'widgets/common/app_ui.dart';
import 'widgets/global_navbar.dart';
import 'commandes/prescriptions_page.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarOpen = false;
  late AnimationController _sidebarAnimationController;

  late String _currentSection;

  @override
  void initState() {
    super.initState();

    final auth = context.read<AuthProvider>();
    final initialSection = widget.child is SizedBox
        ? _resolveInitialSection(auth.user)
        : widget.pageTitle;

    _currentSection = _normalizeSection(initialSection);
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
      'Prescriptions',
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
      case 'Prescriptions':
        return const PrescriptionsPage();
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppResponsive.mobileBreakpoint;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          drawer: isMobile
              ? Drawer(
                  child: SafeArea(
                    child: AppSidebar(
                      selectedLabel: _currentSection,
                      callbacks: _buildNavigationCallbacks(),
                    ),
                  ),
                )
              : null,
          body: MainLayoutScope(
            navigateToSection: _navigateToSection,
            child: Stack(
              children: [
                Column(
                  children: [
                    GlobalNavbar(
                      onMenuToggle: () {
                        if (isMobile) {
                          _scaffoldKey.currentState?.openDrawer();
                        } else {
                          _toggleSidebar();
                        }
                      },
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
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isMobile ? 12 : 16,
                          0,
                          isMobile ? 12 : 16,
                          isMobile ? 12 : 16,
                        ),
                        child: AppContentShell(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position:
                                        Tween<Offset>(
                                          begin: const Offset(0.1, 0),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOutCubic,
                                          ),
                                        ),
                                    child: child,
                                  ),
                                ),
                            child: KeyedSubtree(
                              key: ValueKey(_currentSection),
                              child: _pageForSection(_currentSection),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isMobile) _buildOverlaySidebarWithBlur(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _setCurrentSection(String section) {
    final shouldCloseSidebar = _isSidebarOpen;
    setState(() {
      _currentSection = section;
    });
    if (shouldCloseSidebar) {
      _toggleSidebar();
    }
  }

  void _navigateToSection(String section) {
    final normalizedSection = _normalizeSection(section);

    if (!_canAccessSection(normalizedSection)) {
      final fallback = _resolveInitialSection(
        context.read<AuthProvider>().user,
      );
      if (normalizedSection != fallback) {
        _setCurrentSection(fallback);
      }
      return;
    }

    if (normalizedSection == 'Settings') {
      if (_isSidebarOpen) _toggleSidebar();
      SettingsDialog.show(context);
      return;
    }

    _setCurrentSection(normalizedSection);
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
              child: Container(
                margin: const EdgeInsets.only(top: navbarHeight),
                width: size.width,
                height: size.height - navbarHeight,
                color: Colors.black.withOpacity(0.34),
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
                  color: Colors.transparent,
                  child: AppSidebar(
                    selectedLabel: _currentSection,
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
          Icon(Icons.construction, size: 80, color: BpColors.textHint),
          SizedBox(height: 16),
          Text(
            '$title en construction...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: BpColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nous travaillons sur cette fonctionnalite.',
            style: TextStyle(fontSize: 16, color: BpColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
