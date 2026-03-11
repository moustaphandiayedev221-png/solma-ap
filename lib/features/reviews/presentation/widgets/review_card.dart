import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/review_model.dart';
import '../providers/review_provider.dart';
import 'star_rating.dart';

/// Carte avis professionnelle : titre, badge achat vérifié, utile/pas utile.
class ReviewCard extends ConsumerStatefulWidget {
  const ReviewCard({
    super.key,
    required this.review,
    required this.productId,
    this.isCurrentUser = false,
    this.onEdit,
    this.onDelete,
  });

  final ReviewModel review;
  final String productId;
  final bool isCurrentUser;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  ConsumerState<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends ConsumerState<ReviewCard> {
  bool _votePending = false;

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    final l10n = AppLocalizations.of(context)!;
    if (diff.inDays == 0) return l10n.today;
    if (diff.inDays == 1) return l10n.yesterday;
    if (diff.inDays < 7) {
      return '${diff.inDays} ${l10n.daysAgo}';
    }
    return DateFormat.yMMMd().format(d);
  }

  Future<void> _onVote(bool helpful) async {
    final user = ref.read(currentUserProvider);
    if (user == null || _votePending) return;
    if (widget.review.userVote == helpful) return;

    setState(() => _votePending = true);
    try {
      await ref.read(reviewRepositoryProvider).voteHelpful(
            reviewId: widget.review.id,
            userId: user.id,
            helpful: helpful,
          );
      ref.invalidate(reviewsForProductProvider(widget.productId));
    } finally {
      if (mounted) setState(() => _votePending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final r = widget.review;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                child: Text(
                  (r.userFullName ?? 'U').substring(0, 1).toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.userFullName ?? 'Utilisateur',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        StarRating(rating: r.rating.toDouble(), size: 16),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          _formatDate(r.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (r.verifiedPurchase) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 12,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.verifiedPurchase,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (widget.isCurrentUser) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: widget.onEdit,
                            icon: const Icon(Icons.edit_rounded, size: 16),
                            label: Text(l10n.edit),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: widget.onDelete,
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: theme.colorScheme.error,
                            ),
                            label: Text(
                              l10n.deleteReview,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (r.title != null && r.title!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              r.title!,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (r.comment != null && r.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              r.comment!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ],
          if (r.pros != null && r.pros!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ProsConsRow(
              icon: Icons.thumb_up_outlined,
              label: l10n.pros,
              text: r.pros!,
              theme: theme,
            ),
          ],
          if (r.cons != null && r.cons!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _ProsConsRow(
              icon: Icons.thumb_down_outlined,
              label: l10n.cons,
              text: r.cons!,
              theme: theme,
            ),
          ],
          if ((r.helpfulCount > 0 || r.notHelpfulCount > 0) ||
              (ref.watch(currentUserProvider) != null && !widget.isCurrentUser)) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (r.helpfulCount > 0 || r.notHelpfulCount > 0)
                  Text(
                    l10n.peopleFoundHelpful(r.helpfulCount),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  const SizedBox.shrink(),
                const Spacer(),
                if (ref.watch(currentUserProvider) != null &&
                    !widget.isCurrentUser) ...[
                  _HelpfulButton(
                    label: l10n.helpful,
                    icon: Icons.thumb_up_outlined,
                    isSelected: r.userVote == true,
                    isLoading: _votePending,
                    onTap: () => _onVote(true),
                  ),
                  const SizedBox(width: 8),
                  _HelpfulButton(
                    label: l10n.notHelpful,
                    icon: Icons.thumb_down_outlined,
                    isSelected: r.userVote == false,
                    isLoading: _votePending,
                    onTap: () => _onVote(false),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProsConsRow extends StatelessWidget {
  const _ProsConsRow({
    required this.icon,
    required this.label,
    required this.text,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HelpfulButton extends StatelessWidget {
  const _HelpfulButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
