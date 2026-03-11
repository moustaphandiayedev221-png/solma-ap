import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/responsive/responsive_module.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../gen_l10n/app_localizations.dart';

/// Bottom bar style Sneaker Shop : fond blanc opaque, coins 30, Home en pill noir.
/// Responsive sur petit écran (iPhone X, SE) et respecte la safe area (encoche / barre d'accueil).
class MainBottomNav extends StatelessWidget {
  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final r = context.responsive;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navHeight = r.isCompactSmall ? 60.0 : 72.0;
    final navColor = isDark ? theme.colorScheme.surface : Colors.white;
    return Container(
      margin: EdgeInsets.fromLTRB(r.horizontalPadding, 0, r.horizontalPadding, bottomPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.nav(context),
      ),
      child: Material(
        color: navColor,
        elevation: 0,
        borderRadius: BorderRadius.circular(30),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: navHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                _NavItem(
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                  icon: LucideIcons.home,
                  label: l10n.navHome,
                  showLabel: true,
                ),
                _NavItem(
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                  icon: LucideIcons.search,
                  label: l10n.navSearch,
                  showLabel: true,
                ),
                _NavItem(
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                  icon: LucideIcons.heart,
                  label: l10n.wishlist,
                  showLabel: true,
                ),
                _NavItem(
                  isActive: currentIndex == 3,
                  onTap: () => onTap(3),
                  icon: LucideIcons.shoppingBag,
                  label: l10n.navCart,
                  showLabel: true,
                ),
                _NavItem(
                  isActive: currentIndex == 4,
                  onTap: () => onTap(4),
                  icon: LucideIcons.user,
                  label: l10n.navProfile,
                  showLabel: true,
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.isActive,
    required this.onTap,
    required this.icon,
    this.label,
    this.showLabel = false,
  });

  final bool isActive;
  final VoidCallback onTap;
  final IconData icon;
  final String? label;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final r = context.responsive;
    final circleSize = r.isCompactSmall ? 38.0 : 44.0;
    final pillWidth = r.isCompactSmall ? 95.0 : 122.0;
    final isPill = isActive && showLabel;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isPill ? pillWidth : circleSize,
        height: circleSize,
        padding: isPill
            ? EdgeInsets.symmetric(
                horizontal: r.isCompactSmall ? 8 : 12,
                vertical: r.isCompactSmall ? 10 : 12,
              )
            : null,
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(circleSize / 2),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showLabel = isPill && label != null && constraints.maxWidth >= (r.isCompactSmall ? 70 : 85);
            return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: r.isCompactSmall ? 20 : 22,
                    color: isActive
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                  if (showLabel) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label!,
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: r.isCompactSmall ? 11 : 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
