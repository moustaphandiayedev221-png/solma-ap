import 'package:flutter/material.dart';
import '../../../../../gen_l10n/app_localizations.dart';
import '../../constants/product_detail_constants.dart';
import '../../../data/product_model.dart';

/// Section "Choisir la pointure" avec boutons de taille (scroll horizontal).
class ProductDetailSizeSection extends StatelessWidget {
  const ProductDetailSizeSection({
    super.key,
    required this.product,
    required this.selectedIndex,
    required this.onSizeSelected,
  });

  final ProductModel product;
  final int selectedIndex;
  final ValueChanged<int> onSizeSelected;

  List<String> get _sizeLabels =>
      product.sizes.isNotEmpty ? product.sizes : ProductDetailConstants.defaultSizes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ProductDetailConstants.horizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.selectSize,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_sizeLabels.length, (i) {
                final selected = i == selectedIndex;
                final label = _formatSizeLabel(_sizeLabels[i]);
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => onSizeSelected(i),
                    child: AnimatedContainer(
                      duration: ProductDetailConstants.animationShort,
                      padding: const EdgeInsets.symmetric(
                        horizontal: ProductDetailConstants.sizeButtonHorizontalPadding,
                        vertical: ProductDetailConstants.sizeButtonVerticalPadding,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                          width: 1.5,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatSizeLabel(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.startsWith('size ')) return raw.trim().substring(5).trim();
    if (lower.startsWith('size')) return raw.trim().substring(4).trim();
    return raw.trim();
  }
}
