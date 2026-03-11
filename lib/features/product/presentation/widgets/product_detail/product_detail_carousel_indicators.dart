import 'package:flutter/material.dart';

import '../../../../../core/theme/app_shadows.dart';

/// Indicateurs verticaux du carrousel — positionnés à droite de l'image.
/// Cercle actif : centre noir, anneau blanc, contour noir.
class ProductDetailCarouselIndicators extends StatelessWidget {
  const ProductDetailCarouselIndicators({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    this.onTap,
  });

  final int itemCount;
  final int currentIndex;
  final ValueChanged<int>? onTap;

  static const double _inactiveSize = 8.0;
  static const double _activeOuterSize = 20.0;
  static const double _spacing = 10.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (i) {
        final isSelected = i == currentIndex;
        return Padding(
          padding: const EdgeInsets.only(bottom: _spacing),
          child: GestureDetector(
            onTap: onTap != null ? () => onTap!(i) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? _activeOuterSize : _inactiveSize,
              height: isSelected ? _activeOuterSize : _inactiveSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : theme.colorScheme.outline.withValues(alpha: 0.4),
                border: isSelected
                    ? Border.all(color: theme.colorScheme.onSurface, width: 1.5)
                    : null,
                boxShadow: isSelected ? AppShadows.subtle(context) : null,
              ),
              padding: isSelected ? const EdgeInsets.all(4) : null,
              child: isSelected
                  ? Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                    )
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
