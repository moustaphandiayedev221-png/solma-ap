import 'package:flutter/material.dart';

import '../responsive/responsive_module.dart';
import '../theme/app_shadows.dart';

/// Carte avec coins arrondis et ombre douce (soft shadow) — responsive.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final radius = borderRadius ?? BorderRadius.circular(r.isCompactSmall ? 12 : 16);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppShadows.card(context),
      ),
      child: Material(
        color: cardColor,
        elevation: 0,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? EdgeInsets.all(r.isCompactSmall ? 12 : 16),
            child: child,
          ),
        ),
      ),
    );
  }
}
