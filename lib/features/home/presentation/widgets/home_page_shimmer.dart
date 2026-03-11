import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/responsive/responsive_module.dart';

/// Shimmer professionnel unifié pour la page Home — une seule expérience de chargement.
/// Simule le layout complet : header, bannière, catégories, sections produits.
class HomePageShimmer extends StatelessWidget {
  const HomePageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = context.responsive;
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
        : theme.colorScheme.surfaceContainerHighest;
    final highlightColor = isDark
        ? theme.colorScheme.surface.withValues(alpha: 0.6)
        : theme.colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1500),
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                r.horizontalPadding,
                r.isCompactSmall ? 44 : 56,
                r.horizontalPadding,
                r.verticalPadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ShimmerCircle(size: 44, baseColor: baseColor),
                  const SizedBox(width: 8),
                  _ShimmerCircle(size: 44, baseColor: baseColor),
                ],
              ),
            ),
          ),
          // Bannière
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: r.isCompactSmall ? 160 : 196,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 6)),
          // Bande noire "Pourquoi choisir SOLMA"
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
              child: Container(
                height: r.isCompactSmall ? 24 : 28,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          // Indicateurs bannière
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (_) => _ShimmerDot(baseColor: baseColor)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          // Catégories (chips) — défilable horizontalement pour éviter l'overflow
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  return Padding(
                    padding: EdgeInsets.only(right: i < 4 ? 10 : 0),
                    child: Container(
                      width: i == 0 ? 48 : 72 + (i * 8),
                      height: 40,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          // Section titre + produits
          _buildSectionShimmer(r, baseColor),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          // Section featured
          _buildFeaturedShimmer(r, baseColor),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          // Section sports
          _buildSectionShimmer(r, baseColor),
          SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 20)),
        ],
      ),
    );
  }

  Widget _buildSectionShimmer(ResponsiveValues r, Color baseColor) {
    const cardW = 200.0;
    const gap = 16.0;
    const rowW = 2 * cardW + gap;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 22,
                  width: 140,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  height: 16,
                  width: 50,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 301,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(r.horizontalPadding, 0, r.horizontalPadding, 16),
              itemCount: 2,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 14),
                child: SizedBox(
                  width: rowW,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerProductCard(baseColor: baseColor),
                      const SizedBox(width: gap),
                      _ShimmerProductCard(baseColor: baseColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedShimmer(ResponsiveValues r, Color baseColor) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 22,
                  width: 160,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  height: 16,
                  width: 50,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  const _ShimmerCircle({required this.size, required this.baseColor});

  final double size;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: baseColor,
      ),
    );
  }
}

class _ShimmerProductCard extends StatelessWidget {
  const _ShimmerProductCard({required this.baseColor});

  final Color baseColor;

  static const double cardWidth = 200;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 14,
            width: 120,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 60,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerDot extends StatelessWidget {
  const _ShimmerDot({required this.baseColor});

  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 8,
      height: 4,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
