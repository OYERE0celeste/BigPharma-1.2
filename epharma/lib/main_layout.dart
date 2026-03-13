import 'package:flutter/material.dart';
import 'widgets/global_navbar.dart';
import 'widgets/app_sidebar.dart';

// =====================================================================
// MAIN LAYOUT WIDGET - Enveloppe toutes les pages
// =====================================================================

class MainLayout extends StatefulWidget {
  final Widget child;
  final String? pageTitle;

  const MainLayout({required this.child, this.pageTitle, super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  late AnimationController _sidebarAnimationController;

  @override
  void initState() {
    super.initState();
    _sidebarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    if (_isSidebarOpen) {
      _sidebarAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _sidebarAnimationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });

    if (_isSidebarOpen) {
      _sidebarAnimationController.forward();
    } else {
      _sidebarAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    // Adapt sidebar visibility based on screen size
    bool effectiveSidebarOpen = _isSidebarOpen;
    if (isMobile) {
      effectiveSidebarOpen = _isSidebarOpen; // On mobile, use toggle state
    }

    return Scaffold(
      body: Column(
        children: [
          // ===== GLOBAL NAVBAR =====
          GlobalNavbar(
            onMenuToggle: _toggleSidebar,
            isSidebarOpen: effectiveSidebarOpen,
            onProfileAction: (action) {
              // Handle profile actions globally if needed
            },
          ),

          // ===== MAIN CONTENT AREA =====
          Expanded(
            child: Row(
              children: [
                // ===== ANIMATED SIDEBAR =====
                if (!isMobile)
                  _buildAnimatedSidebar()
                else if (effectiveSidebarOpen)
                  // Mobile sidebar as drawer
                  _buildMobileSidebar(),

                // ===== PAGE CONTENT =====
                Expanded(
                  child: Material(color: Colors.grey[50], child: widget.child),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build navigation callbacks for sidebar
  Map<String, VoidCallback> _buildNavigationCallbacks() {
    return {
      'Dashboard': () => Navigator.pushNamed(context, '/'),
      'Stock': () => Navigator.pushNamed(context, '/products'),
      'Sales': () => Navigator.pushNamed(context, '/sales'),
      'Clients': () => Navigator.pushNamed(context, '/clients'),
      'Activity': () => Navigator.pushNamed(context, '/activity'),
      'Finances': () => Navigator.pushNamed(context, '/finance'),
    };
  }

  /// Animated sidebar for desktop view
  Widget _buildAnimatedSidebar() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(
          parent: _sidebarAnimationController,
          curve: Curves.easeInOut,
        ),
      ),
      alignment: Alignment.centerLeft,
      child: FadeTransition(
        opacity: _sidebarAnimationController,
        child: AppSidebar(
          selectedLabel: widget.pageTitle ?? '',
          callbacks: _buildNavigationCallbacks(),
        ),
      ),
    );
  }

  /// Mobile drawer sidebar
  Widget _buildMobileSidebar() {
    return Container(
      width: 220,
      color: Colors.white,
      child: Stack(
        children: [
          AppSidebar(
            selectedLabel: widget.pageTitle ?? '',
            callbacks: _buildNavigationCallbacks(),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleSidebar,
              ),
            ),
          ),
        ],
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
