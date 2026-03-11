import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../product/presentation/constants/product_detail_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/review_model.dart';
import '../providers/review_provider.dart';
import 'add_review_sheet.dart';
import 'review_card.dart';
import 'review_summary.dart';

/// Section avis professionnelle avec tri, résumé et liste.
class ProfessionalReviewsSection extends ConsumerStatefulWidget {
  const ProfessionalReviewsSection({
    super.key,
    required this.productId,
    this.initialLimit = 5,
    this.showTitle = true,
  });

  final String productId;
  final int initialLimit;
  final bool showTitle;

  @override
  ConsumerState<ProfessionalReviewsSection> createState() =>
      _ProfessionalReviewsSectionState();
}

class _ProfessionalReviewsSectionState
    extends ConsumerState<ProfessionalReviewsSection> {
  int _displayLimit = 5;
  ReviewSort _sortBy = ReviewSort.recent;

  List<ReviewModel> _sortedReviews(List<ReviewModel> reviews) {
    final list = List<ReviewModel>.from(reviews);
    switch (_sortBy) {
      case ReviewSort.recent:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ReviewSort.highest:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ReviewSort.lowest:
        list.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case ReviewSort.helpful:
        list.sort((a, b) =>
            (b.helpfulCount + b.notHelpfulCount)
                .compareTo(a.helpfulCount + a.notHelpfulCount));
        break;
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _displayLimit = widget.initialLimit;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final reviewsAsync = ref.watch(reviewsForProductProvider(widget.productId));
    final user = ref.watch(currentUserProvider);
    final userReviewAsync = ref.watch(userReviewProvider(widget.productId));

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ProductDetailConstants.horizontalPadding,
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bouton "Donner mon avis" EN PREMIER — toujours visible
        if (user != null)
          userReviewAsync.when(
            data: (existingReview) => _buildWriteReviewButton(
              context, theme, l10n, existingReview,
            ),
            loading: () => _buildWriteReviewButton(
              context, theme, l10n, null, isLoading: true,
            ),
            error: (error, stackTrace) => _buildWriteReviewButton(
              context, theme, l10n, null,
            ),
          )
        else
          _buildLoginToReviewPrompt(context, theme, l10n),
        const SizedBox(height: 20),
        if (widget.showTitle) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.reviews,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              ReviewSummary(
                productId: widget.productId,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        ReviewSummary(
          productId: widget.productId,
          showDistribution: true,
        ),
        const SizedBox(height: 24),
        reviewsAsync.when(
          data: (reviews) {
            if (reviews.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 40,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.beFirstToReview,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (user != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            showAddReviewSheet(
                              context,
                              productId: widget.productId,
                            );
                          },
                          icon: const Icon(Icons.add_comment_rounded, size: 20),
                          label: Text(
                            l10n.writeReview,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }

            final sorted = _sortedReviews(reviews);
            final displayed = sorted.take(_displayLimit).toList();
            final hasMore = sorted.length > _displayLimit;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${reviews.length} ${l10n.reviews}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    PopupMenuButton<ReviewSort>(
                      onSelected: (s) => setState(() => _sortBy = s),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _sortLabel(l10n),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      itemBuilder: (context) => [
                        _sortItem(ReviewSort.recent, l10n.sortRecent, Icons.schedule_rounded),
                        _sortItem(ReviewSort.highest, l10n.sortHighest, Icons.trending_up_rounded),
                        _sortItem(ReviewSort.lowest, l10n.sortLowest, Icons.trending_down_rounded),
                        _sortItem(ReviewSort.helpful, l10n.sortHelpful, Icons.thumb_up_rounded),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...displayed.map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ReviewCard(
                      review: review,
                      productId: widget.productId,
                      isCurrentUser: user?.id == review.userId,
                      onEdit: () {
                        showAddReviewSheet(
                          context,
                          productId: widget.productId,
                          existingReview: review,
                        );
                      },
                      onDelete: () => _confirmDelete(context, ref, review, l10n),
                    ),
                  ),
                ),
                if (hasMore)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() => _displayLimit += 5);
                      },
                      child: Text(
                        l10n.seeMoreReviews(sorted.length - _displayLimit),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          error: (error, stackTrace) => const SizedBox.shrink(),
        ),
      ],
    ),
    );
  }

  Widget _buildWriteReviewButton(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    ReviewModel? existingReview, {
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isLoading
            ? null
            : () {
                showAddReviewSheet(
                  context,
                  productId: widget.productId,
                  existingReview: existingReview,
                );
              },
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onPrimary,
                ),
              )
            : Icon(
                existingReview != null
                    ? Icons.edit_rounded
                    : Icons.rate_review_rounded,
                size: 20,
              ),
        label: Text(
          existingReview != null
              ? l10n.editReview
              : l10n.writeReview,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginToReviewPrompt(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 24,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.loginToReview,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sortLabel(AppLocalizations l10n) {
    switch (_sortBy) {
      case ReviewSort.recent:
        return l10n.sortRecent;
      case ReviewSort.highest:
        return l10n.sortHighest;
      case ReviewSort.lowest:
        return l10n.sortLowest;
      case ReviewSort.helpful:
        return l10n.sortHelpful;
    }
  }

  PopupMenuItem<ReviewSort> _sortItem(
    ReviewSort value,
    String label,
    IconData icon,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ReviewModel review,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteReview),
        content: Text(l10n.deleteReviewConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.deleteReview,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(reviewRepositoryProvider).deleteReview(review.id);
      ref.invalidate(reviewsForProductProvider(widget.productId));
      ref.invalidate(userReviewProvider(widget.productId));
      if (context.mounted) {
        AppToast.show(context, message: l10n.reviewDeleted);
      }
    }
  }
}

enum ReviewSort { recent, highest, lowest, helpful }
