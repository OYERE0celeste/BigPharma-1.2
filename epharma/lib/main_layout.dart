import 'dart:ui';
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
  bool _isSidebarOpen = false;
  late AnimationController _sidebarAnimationController;

  @override
  void initState() {
    super.initState();
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
                onProfileAction: (action) {},
              ),
              Expanded(
                child: Container(
                  color: Colors.grey[50],
                  // Chaque page gère son propre scroll/padding
                  child: widget.child,
                ),
              ),
            ],
          ),

          // ===== OVERLAY SIDEBAR + BLUR (TOUTES LARGEURS) =====
          _buildOverlaySidebarWithBlur(),
        ],
      ),
    );
  }

  /// Build navigation callbacks for sidebar
  Map<String, VoidCallback> _buildNavigationCallbacks() {
    return {
      'Dashboard': () => Navigator.pushNamed(context, '/'),
      'Stock': () => Navigator.pushNamed(context, '/products'),
      'Ventes': () => Navigator.pushNamed(context, '/sales'),
      'Clients': () => Navigator.pushNamed(context, '/clients'),
      'Activités': () => Navigator.pushNamed(context, '/activity'),
      'Fournisseurs': () => Navigator.pushNamed(context, '/suppliers'),
      //'Consultations': () => Navigator.pushNamed(context, '/consultations'),
      'Finances': () => Navigator.pushNamed(context, '/finance'),
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
                    selectedLabel: widget.pageTitle ?? '',
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
