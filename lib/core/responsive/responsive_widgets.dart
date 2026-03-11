import 'package:flutter/material.dart';

import 'responsive.dart';

/// Padding horizontal (et optionnel vertical) adapté à la largeur d'écran.
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.vertical = false,
    this.horizontal = true,
    this.multiplier = 1.0,
  });

  final Widget child;
  final bool vertical;
  final bool horizontal;
  final double multiplier;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final h = horizontal ? r.horizontalPadding * multiplier : 0.0;
    final v = vertical ? r.verticalPadding * multiplier : 0.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(h, v, h, v),
      child: child,
    );
  }
}

/// Contient le contenu avec une largeur max et le centre sur grand écran (style grandes apps).
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding = true,
  });

  final Widget child;
  final double? maxWidth;
  final bool padding;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final width = MediaQuery.sizeOf(context).width;
    final max = maxWidth ?? Breakpoint.maxContentWidth;
    final useMax = width > max;
    return Padding(
      padding: padding
          ? EdgeInsets.symmetric(
              horizontal: r.horizontalPadding,
              vertical: r.verticalPadding,
            )
          : EdgeInsets.zero,
      child: useMax
          ? Center(
              child: SizedBox(
                width: max,
                child: child,
              ),
            )
          : child,
    );
  }
}

/// Grille adaptive : 2/3/4 colonnes selon la largeur, espacements et padding responsive.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.crossAxisCount,
    this.childAspectRatio = 0.68,
    this.padding = true,
  });

  final List<Widget> children;
  final int? crossAxisCount;
  final double childAspectRatio;
  final bool padding;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final count = crossAxisCount ?? r.gridCrossAxisCount;
    final gap = r.gap;
    return Padding(
      padding: padding
          ? EdgeInsets.fromLTRB(
              r.horizontalPadding,
              r.verticalPadding * 0.5,
              r.horizontalPadding,
              r.verticalPadding,
            )
          : EdgeInsets.zero,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: count,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        childAspectRatio: childAspectRatio,
        children: children,
      ),
    );
  }
}

double responsiveTextScale(BuildContext context) =>
    context.responsive.textScale;
