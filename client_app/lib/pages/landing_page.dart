import 'package:client_app/pages/login_page.dart';
import 'package:client_app/pages/register_page.dart';
import 'package:client_app/widgets/bp_theme.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1000;
        final isTablet = width >= 720 && width < 1000;
        final isMobile = width < 720;
        final horizontalPadding = isMobile
            ? 16.0
            : isTablet
            ? 20.0
            : 24.0;
        final contentMaxWidth = isDesktop ? 1200.0 : 980.0;

        return Scaffold(
          backgroundColor: BpColors.scaffold,
          body: SafeArea(
            child: Stack(
              children: [
                _buildBackgroundDecorations(context),
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: isMobile ? 18 : 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _LandingHeader(
                              isDesktop: isDesktop,
                              isMobile: isMobile,
                            ),
                            SizedBox(height: isMobile ? 28 : 40),
                            _LandingHero(
                              isDesktop: isDesktop,
                              isMobile: isMobile,
                            ),
                            SizedBox(height: isMobile ? 32 : 48),
                            _FeatureSection(
                              isDesktop: isDesktop,
                              isTablet: isTablet,
                            ),
                            SizedBox(height: isMobile ? 32 : 48),
                            _WhyUsSection(
                              isDesktop: isDesktop,
                              isTablet: isTablet,
                            ),
                            SizedBox(height: isMobile ? 32 : 48),
                            _LandingFooter(isMobile: isMobile),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundDecorations(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -size.height * 0.14,
            left: -size.width * 0.08,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    BpColors.primary.withOpacity(0.18),
                    BpColors.primaryLight.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: BpColors.primary.withOpacity(0.12),
                    blurRadius: 64,
                    spreadRadius: 14,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.12,
            right: -size.width * 0.12,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    BpColors.accent.withOpacity(0.12),
                    BpColors.primaryLight.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: BpColors.accent.withOpacity(0.10),
                    blurRadius: 72,
                    spreadRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingHeader extends StatelessWidget {
  const _LandingHeader({required this.isDesktop, required this.isMobile});
  final bool isDesktop;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.medication, color: Colors.white, size: 48),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Text(
                      'BigPharma',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            if (!isMobile)
              Row(
                children: [
                  _HeaderButton(
                    label: 'Connexion',
                    isPrimary: false,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _HeaderButton(
                    label: 'Inscription',
                    isPrimary: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    ),
                  ),
                ],
              ),
          ],
        ),
        if (isMobile) ...[
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeaderButton(
                label: 'Connexion',
                isPrimary: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
              ),
              _HeaderButton(
                label: 'Inscription',
                isPrimary: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _HeaderButton extends StatefulWidget {
  const _HeaderButton({
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final background = widget.isPrimary ? BpColors.accent : Colors.white;
    final foreground = BpColors.primaryDark;
    final borderColor = widget.isPrimary
        ? Colors.transparent
        : BpColors.borderStrong;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, isHovering ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            if (isHovering)
              BoxShadow(
                color: BpColors.primary.withOpacity(0.16),
                blurRadius: 24,
                offset: const Offset(0.0, 12.0),
              ),
          ],
        ),
        child: TextButton(
          onPressed: widget.onTap,
          style: TextButton.styleFrom(
            foregroundColor: foreground,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ),
    );
  }
}

class _LandingHero extends StatelessWidget {
  const _LandingHero({required this.isDesktop, required this.isMobile});
  final bool isDesktop;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Votre pharmacie numérique moderne',
          style: TextStyle(
            fontSize: isDesktop
                ? 50
                : isMobile
                ? 34
                : 42,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.1,
            color: BpColors.primaryDark,
            height: 1.04,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Commandez vos médicaments rapidement et en toute sécurité.',
          style: TextStyle(fontSize: 18, color: Color(0xFF4A6A76), height: 1.5),
        ),
        const SizedBox(height: 18),
        const Text(
          'BigPharma rend vos commandes pharmaceutiques simples et intuitives. En quelques clics, vous choisissez vos produits, validez votre commande en toute sécurité et suivez son traitement en temps réel. Notre support santé dédié reste disponible pour vous accompagner et répondre à vos besoins, afin que chaque commande devienne une expérience fluide et rassurante.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF5C6970),
            height: 1.75,
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: BpColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Commencer',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: BpColors.primaryDark,
                side: BorderSide(color: BpColors.primary.withOpacity(0.35)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Se connecter',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    );

    final illustration = _HeroIllustration(
      isDesktop: isDesktop,
      isMobile: isMobile,
    );

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 36,
            offset: const Offset(0.0, 18.0),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: content),
                const SizedBox(width: 32),
                Expanded(child: illustration),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [content, const SizedBox(height: 28), illustration],
            ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration({required this.isDesktop, required this.isMobile});
  final bool isDesktop;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final height = isDesktop
        ? 440.0
        : isMobile
        ? 320.0
        : 380.0;
    final badgeSize = isMobile ? 92.0 : 104.0;
    final infoCardWidth = isMobile ? 120.0 : 150.0;
    final squareSize = isMobile ? 130.0 : 170.0;
    final edgePadding = isMobile ? 16.0 : 24.0;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFFE8FBF7), Color(0xFFF1F8FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: BpColors.border, width: 1.2),
            ),
          ),
          Positioned(
            top: edgePadding,
            left: edgePadding,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: BpColors.primary.withOpacity(0.12),
                    blurRadius: 28.0,
                    offset: const Offset(0.0, 14.0),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.health_and_safety_rounded,
                  size: 42,
                  color: BpColors.primary,
                ),
              ),
            ),
          ),
          Positioned(
            top: isMobile ? 86.0 : 92.0,
            right: edgePadding,
            child: _InfoChip(
              icon: Icons.shield_rounded,
              label: 'Protection avancée',
              color: BpColors.primaryLight,
            ),
          ),
          Positioned(
            bottom: edgePadding,
            left: edgePadding,
            child: _InfoChip(
              icon: Icons.local_shipping_rounded,
              label: 'Livraison express',
              color: BpColors.accent,
            ),
          ),
          Positioned(
            bottom: edgePadding + 12,
            right: edgePadding + 4,
            child: Container(
              width: infoCardWidth,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 24,
                    offset: const Offset(0.0, 12.0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Prescription',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A6A76),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gestion numérique rapide',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A8B97),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: isMobile ? 30.0 : 50.0,
            left: isMobile ? 110.0 : 140.0,
            child: Container(
              width: squareSize,
              height: squareSize,
              decoration: BoxDecoration(
                color: const Color(0xFFCAF2E8),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Center(
                child: Icon(
                  Icons.medical_services_rounded,
                  size: 56,
                  color: BpColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: BpColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  const _FeatureSection({required this.isDesktop, required this.isTablet});
  final bool isDesktop;
  final bool isTablet;

  static final List<_FeatureItem> _features = [
    _FeatureItem(
      icon: Icons.search_rounded,
      title: 'Recherche rapide de médicaments',
      description:
          'Trouvez instantanément vos traitements et génériques disponibles.',
    ),
    _FeatureItem(
      icon: Icons.lock_outline_rounded,
      title: 'Commande sécurisée',
      description:
          'Paiement, identité et données protégés par des normes médicales strictes.',
    ),
    _FeatureItem(
      icon: Icons.local_shipping_rounded,
      title: 'Livraison ou retrait rapide',
      description: 'Choisissez le mode de retrait le plus pratique pour vous.',
    ),
    _FeatureItem(
      icon: Icons.receipt_long_rounded,
      title: 'Gestion numérique des ordonnances',
      description:
          'Conservez et partagez vos prescriptions en toute simplicité.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fonctionnalités clés',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: BpColors.primaryDark,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Une plateforme pensée pour la pharmacie moderne, la sécurité et un parcours client sans friction.',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF5C6970),
            height: 1.65,
          ),
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = isDesktop
                ? 4
                : isTablet
                ? 2
                : 1;
            final width = crossAxisCount == 1
                ? double.infinity
                : constraints.maxWidth / crossAxisCount - 14;
            return Wrap(
              spacing: 18,
              runSpacing: 18,
              children: _features
                  .map(
                    (feature) => SizedBox(
                      width: width,
                      child: _FeatureCard(item: feature),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({required this.item});
  final _FeatureItem item;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovering ? -6 : 0, 0),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: BpColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovering ? 0.08 : 0.04),
              blurRadius: _hovering ? 28 : 18,
              offset: const Offset(0.0, 12.0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: BpColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(widget.item.icon, color: BpColors.primary, size: 26),
            ),
            const SizedBox(height: 18),
            Text(
              widget.item.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: BpColors.primaryDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.item.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5C6970),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhyUsSection extends StatelessWidget {
  const _WhyUsSection({required this.isDesktop, required this.isTablet});
  final bool isDesktop;
  final bool isTablet;

  static final List<_WhyUsItem> _advantages = [
    _WhyUsItem(
      icon: Icons.flash_on_rounded,
      title: 'Rapidité',
      description:
          'Processus optimisé pour vos commandes et administratifs santé.',
    ),
    _WhyUsItem(
      icon: Icons.security_rounded,
      title: 'Sécurité',
      description:
          'Confidentialité, conformité et protection de vos données médicales.',
    ),
    _WhyUsItem(
      icon: Icons.access_time_rounded,
      title: 'Disponibilité',
      description: 'Accès à votre pharmacie 24/7, depuis tous vos appareils.',
    ),
    _WhyUsItem(
      icon: Icons.thumb_up_rounded,
      title: 'Simplicité',
      description: 'Interface claire et parcours client fluide, sans friction.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pourquoi nous ?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: BpColors.primaryDark,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Une solution pensée pour les patients, les pharmacies partenaires et le suivi médical intelligent.',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF5C6970),
            height: 1.65,
          ),
        ),
        const SizedBox(height: 26),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = isDesktop
                ? 4
                : isTablet
                ? 2
                : 1;
            final cardWidth = crossAxisCount == 1
                ? double.infinity
                : constraints.maxWidth / crossAxisCount - 12;
            return Wrap(
              spacing: 18,
              runSpacing: 18,
              children: _advantages
                  .map(
                    (item) => SizedBox(
                      width: cardWidth,
                      child: _WhyUsCard(item: item),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _WhyUsItem {
  const _WhyUsItem({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;
}

class _WhyUsCard extends StatefulWidget {
  const _WhyUsCard({required this.item});
  final _WhyUsItem item;

  @override
  State<_WhyUsCard> createState() => _WhyUsCardState();
}

class _WhyUsCardState extends State<_WhyUsCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: BpColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovering ? 0.08 : 0.04),
              blurRadius: _hovering ? 30 : 18,
              offset: const Offset(0.0, 14.0),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: BpColors.primaryLight.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(widget.item.icon, color: BpColors.primary, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: BpColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5C6970),
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandingFooter extends StatelessWidget {
  const _LandingFooter({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isMobile ? 22 : 26,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: BpColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _FooterDescription(),
                const SizedBox(height: 24),
                const _FooterContact(),
                const SizedBox(height: 24),
                const _FooterSocial(),
                const SizedBox(height: 24),
                const Divider(color: BpColors.border, height: 1),
                const SizedBox(height: 18),
                const _FooterBottom(),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(child: _FooterDescription()),
                    SizedBox(width: 24),
                    _FooterContact(),
                    SizedBox(width: 24),
                    _FooterSocial(),
                  ],
                ),
                const SizedBox(height: 30),
                const Divider(color: BpColors.border, height: 1),
                const SizedBox(height: 18),
                const _FooterBottom(),
              ],
            ),
    );
  }
}

class _FooterDescription extends StatelessWidget {
  const _FooterDescription();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.medication, color: BpColors.primaryDark, size: 24),
            SizedBox(width: 8),
            Text(
              'BigPharma',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: BpColors.primaryDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          'Une plateforme e-santé sécurisée et moderne pour commander vos médicaments, gérer vos ordonnances et accéder à un service client dédié.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF5C6970),
            height: 1.75,
          ),
        ),
      ],
    );
  }
}

class _FooterContact extends StatelessWidget {
  const _FooterContact();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Contact',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: BpColors.primaryDark,
          ),
        ),
        SizedBox(height: 12),
        _FooterLink(label: 'support@bigpharma.com'),
        SizedBox(height: 8),
        _FooterLink(label: '+242 06 824 4853'),
      ],
    );
  }
}

class _FooterSocial extends StatelessWidget {
  const _FooterSocial();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Réseaux',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: BpColors.primaryDark,
          ),
        ),
        SizedBox(height: 12),
        _FooterLink(label: 'LinkedIn'),
        SizedBox(height: 8),
        _FooterLink(label: 'Twitter'),
      ],
    );
  }
}

class _FooterBottom extends StatelessWidget {
  const _FooterBottom();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: const [
        Text(
          '© 2026 BigPharma. Tous droits réservés.',
          style: TextStyle(fontSize: 13, color: Color(0xFF8A9AA5)),
        ),
        Text(
          'Design professionnel pour la pharmacie numérique.',
          style: TextStyle(fontSize: 13, color: Color(0xFF8A9AA5)),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        color: BpColors.primaryDark,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
