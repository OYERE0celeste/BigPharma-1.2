import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/color_tokens.dart';
import '../core/theme/theme_extensions.dart';
import '../core/theme/theme_provider.dart';
import '../widgets/bp_theme.dart';

class AppearanceSettings extends StatelessWidget {
  const AppearanceSettings({super.key});

  void _showThemeSelector(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    themeProvider.startPreview(
      seedColor: themeProvider.seedColor,
      darkMode: themeProvider.isDarkMode,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Consumer<ThemeProvider>(
          builder: (context, controller, _) {
            final previewTheme = controller.previewThemeData();
            final selectedSeedColor = controller.previewSeedColor;
            final selectedTheme = controller.previewTheme;

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(BpSpacing.radiusXl),
              ),
              child: AnimatedTheme(
                data: previewTheme,
                duration: AppTheme.themeAnimationDuration,
                curve: AppTheme.themeAnimationCurve,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 960,
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: context.colorScheme.primary.withOpacity(0.12),
                                borderRadius:
                                    BorderRadius.circular(BpSpacing.radiusLg),
                              ),
                              child: Icon(
                                Icons.palette_rounded,
                                color: context.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Choisir une palette',
                                    style: context.textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Chaque sélection change instantanément l’aperçu des composants avant validation.',
                                    style: context.textTheme.bodyMedium?.copyWith(
                                      color: context.appTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isCompact = constraints.maxWidth < 780;
                              final selector = _ThemeSelectorList(
                                selectedSeedColor: selectedSeedColor,
                                onSelected: (theme) {
                                  controller.updatePreview(seedColor: theme.seedColor);
                                },
                              );
                              final preview = _ThemePreviewPanel(
                                activeTheme: selectedTheme,
                              );

                              if (isCompact) {
                                return SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      selector,
                                      const SizedBox(height: 20),
                                      preview,
                                    ],
                                  ),
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 5, child: selector),
                                  const SizedBox(width: 20),
                                  Expanded(flex: 4, child: preview),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                controller.cancelPreview();
                                Navigator.of(dialogContext).pop();
                              },
                              icon: const Icon(Icons.close_rounded),
                              label: const Text('Annuler'),
                            ),
                            const Spacer(),
                            OutlinedButton.icon(
                              onPressed: () {
                                controller.updatePreview(
                                  seedColor: AppThemeColors.pharmacyGreen.seedColor,
                                );
                              },
                              icon: const Icon(Icons.restart_alt_rounded),
                              label: const Text('Palette par défaut'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: () async {
                                await controller.commitPreview();
                                if (dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                              icon: const Icon(Icons.check_rounded),
                              label: const Text('Appliquer'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(themeProvider.cancelPreview);
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Réinitialiser l’apparence'),
        content: const Text(
          'Vous allez revenir à la palette professionnelle par défaut et au mode clair.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ThemeProvider>().resetAppearance();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Apparence réinitialisée'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Apparence',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            _SettingsTile(
              icon: Icons.dark_mode_rounded,
              title: 'Mode sombre',
              subtitle: 'S’applique à toutes les palettes',
              trailing: Switch.adaptive(
                value: themeProvider.isDarkMode,
                onChanged: themeProvider.setDarkMode,
              ),
            ),
            _SettingsTile(
              icon: Icons.palette_rounded,
              title: 'Couleur du thème',
              subtitle: themeProvider.currentTheme.name,
              trailing: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: themeProvider.currentTheme.seedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: BpColors.borderStrong, width: 2),
                ),
              ),
              onTap: () => _showThemeSelector(context),
            ),
            _SettingsTile(
              icon: Icons.refresh_rounded,
              title: 'Réinitialiser l’apparence',
              subtitle: 'Restaurer la palette professionnelle par défaut',
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: BpColors.textSecondary,
              ),
              onTap: () => _showResetConfirmation(context),
            ),
          ],
        );
      },
    );
  }
}

class _ThemeSelectorList extends StatelessWidget {
  const _ThemeSelectorList({
    required this.selectedSeedColor,
    required this.onSelected,
  });

  final Color selectedSeedColor;
  final ValueChanged<ThemeColorPalette> onSelected;

  @override
  Widget build(BuildContext context) {
    final themes = context.read<ThemeProvider>().availableThemes;

    return Container(
      decoration: BoxDecoration(
        color: context.appTheme.card,
        borderRadius: BorderRadius.circular(BpSpacing.radiusXl),
        border: Border.all(color: context.appTheme.border),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Palettes',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Sélectionnez une base visuelle cohérente et premium.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.appTheme.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: themes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, index) {
              final theme = themes[index];
              final isSelected = theme.seedColor.value == selectedSeedColor.value;
              return _ThemeSwatchCard(
                theme: theme,
                isSelected: isSelected,
                onTap: () => onSelected(theme),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeSwatchCard extends StatelessWidget {
  const _ThemeSwatchCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  final ThemeColorPalette theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final readable = ThemeAccessibility.readableOn(theme.seedColor);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        child: AnimatedContainer(
          duration: AppTheme.themeAnimationDuration,
          curve: AppTheme.themeAnimationCurve,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.seedColor.withOpacity(0.10)
                : context.colorScheme.surface,
            borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
            border: Border.all(
              color: isSelected ? theme.seedColor : context.appTheme.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: theme.seedColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.seedColor.withOpacity(0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  isSelected ? Icons.check_rounded : theme.icon,
                  color: readable,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      theme.name,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: context.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _TinyDot(color: theme.primary),
                        _TinyDot(color: theme.primaryLight),
                        _TinyDot(color: theme.primaryDark),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TinyDot extends StatelessWidget {
  const _TinyDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ThemePreviewPanel extends StatelessWidget {
  const _ThemePreviewPanel({
    required this.activeTheme,
  });

  final ThemeColorPalette activeTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appTheme.card,
        borderRadius: BorderRadius.circular(BpSpacing.radiusXl),
        border: Border.all(color: context.appTheme.border),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aperçu en direct',
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeTheme.name,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.appTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Badge(
                backgroundColor: context.colorScheme.primary,
                textColor: context.colorScheme.onPrimary,
                label: const Text('Live'),
                child: const SizedBox(width: 10, height: 10),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _PreviewContent(),
        ],
      ),
    );
  }
}

class _PreviewContent extends StatelessWidget {
  const _PreviewContent();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.medical_services_rounded),
                label: const Text('Action primaire'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Secondaire'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carte d’exemple',
                  style: context.textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Les boutons, cartes, champs et badges suivent le futur thème.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.appTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Badge(
                      backgroundColor: scheme.primaryContainer,
                      textColor: scheme.onPrimaryContainer,
                      label: const Text('Nouveau'),
                      child: Icon(
                        Icons.notifications_rounded,
                        color: scheme.primary,
                      ),
                    ),
                    const Spacer(),
                    Chip(
                      label: const Text('Statut'),
                      avatar: Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          decoration: InputDecoration(
            labelText: 'Champ texte',
            hintText: 'Texte de démonstration',
            prefixIcon: const Icon(Icons.edit_rounded),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Tooltip(
              message: 'Un exemple de tooltip',
              child: Icon(
                Icons.info_outline_rounded,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Lisibilité vérifiée, contraste ajusté.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.appTheme.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: BpColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: BpColors.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: BpColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: BpColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: trailing!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
