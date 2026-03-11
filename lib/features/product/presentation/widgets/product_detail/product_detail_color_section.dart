import 'package:flutter/material.dart';

import '../../../../../core/theme/app_shadows.dart';
import '../../../../../gen_l10n/app_localizations.dart';
import '../../../data/product_model.dart';

/// Sélecteur de couleur oblique (légèrement incliné) à gauche de l'image produit.
/// Affiche "Couleur" en titre avec des pastilles circulaires (sélection = anneau).
class ProductDetailColorSection extends StatelessWidget {
  const ProductDetailColorSection({
    super.key,
    required this.colors,
    required this.selectedIndex,
    required this.onColorSelected,
  });

  final List<ProductColor> colors;
  final int selectedIndex;
  final ValueChanged<int> onColorSelected;

  static const double _swatchSize = 22.0;
  static const double _selectedRingWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.chip(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              l10n.colour,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(colors.length, (i) {
            final color = colors[i];
            final selected = i == selectedIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => onColorSelected(i),
                child: Container(
                  width: _swatchSize + _selectedRingWidth * 2,
                  height: _swatchSize + _selectedRingWidth * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: _selectedRingWidth,
                    ),
                  ),
                  padding: const EdgeInsets.all(_selectedRingWidth),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _parseColor(color.hex),
                      border: Border.all(
                        color: _isLightColor(color.hex)
                            ? theme.dividerColor
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  static Color _parseColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    if (clean.length == 8) {
      return Color(int.parse(clean, radix: 16));
    }
    return Colors.grey;
  }

  static bool _isLightColor(String hex) {
    final c = _parseColor(hex);
    final luminance = c.computeLuminance();
    return luminance > 0.5;
  }
}
