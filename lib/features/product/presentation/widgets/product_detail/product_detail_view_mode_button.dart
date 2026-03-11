import 'package:flutter/material.dart';
/// Bouton circulaire noir avec icône "<>" pour bascule de mode de vue (ex. 3D).
class ProductDetailViewModeButton extends StatelessWidget {
  const ProductDetailViewModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '<>',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
