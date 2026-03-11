import 'package:flutter/material.dart';
import 'product_card_shimmer.dart';

/// Shimmer pour la liste horizontale type Home (paires de cartes).
class ProductRowShimmer extends StatelessWidget {
  const ProductRowShimmer({
    super.key,
    this.rowCount = 2,
  });

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    const double gapBetweenCards = 16;
    const double gapBetweenRows = 14;
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 301,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: rowCount,
          itemBuilder: (context, rowIndex) {
            return Padding(
              padding: const EdgeInsets.only(right: gapBetweenRows),
              child: SizedBox(
                width: 2 * ProductCardShimmer.cardWidth + gapBetweenCards,
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductCardShimmer(),
                    SizedBox(width: gapBetweenCards),
                    ProductCardShimmer(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Shimmer pour la grille type ProductListScreen (2 colonnes).
class ProductGridShimmer extends StatelessWidget {
  const ProductGridShimmer({
    super.key,
    this.itemCount = 6,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, i) => const ProductCardShimmer(),
    );
  }
}
