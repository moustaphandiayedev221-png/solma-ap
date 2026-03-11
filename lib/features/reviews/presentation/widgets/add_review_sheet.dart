import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/review_model.dart';
import '../providers/review_provider.dart';
import 'star_rating.dart';

/// Bottom sheet professionnel pour ajouter ou modifier un avis.
class AddReviewSheet extends ConsumerStatefulWidget {
  const AddReviewSheet({
    super.key,
    required this.productId,
    this.existingReview,
  });

  final String productId;
  final ReviewModel? existingReview;

  @override
  ConsumerState<AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends ConsumerState<AddReviewSheet> {
  late int _selectedRating;
  late final TextEditingController _titleController;
  late final TextEditingController _commentController;
  late final TextEditingController _prosController;
  late final TextEditingController _consController;
  bool _isLoading = false;

  bool get _isEditing => widget.existingReview != null;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.existingReview?.rating ?? 0;
    _titleController =
        TextEditingController(text: widget.existingReview?.title ?? '');
    _commentController =
        TextEditingController(text: widget.existingReview?.comment ?? '');
    _prosController =
        TextEditingController(text: widget.existingReview?.pros ?? '');
    _consController =
        TextEditingController(text: widget.existingReview?.cons ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    _prosController.dispose();
    _consController.dispose();
    super.dispose();
  }

  String _ratingLabel(AppLocalizations l10n) {
    if (_selectedRating < 1 || _selectedRating > 5) return '';
    switch (_selectedRating) {
      case 1:
        return l10n.starBad;
      case 2:
        return l10n.starPoor;
      case 3:
        return l10n.starAverage;
      case 4:
        return l10n.starGood;
      case 5:
        return l10n.starExcellent;
      default:
        return '';
    }
  }

  Future<void> _submit() async {
    if (_selectedRating == 0) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(reviewRepositoryProvider);
      final title = _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim();
      final comment = _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim();
      final pros = _prosController.text.trim().isEmpty
          ? null
          : _prosController.text.trim();
      final cons = _consController.text.trim().isEmpty
          ? null
          : _consController.text.trim();

      final verifiedPurchase = await repo.hasUserPurchasedProduct(
        user.id,
        widget.productId,
      );

      if (_isEditing) {
        await repo.updateReview(
          reviewId: widget.existingReview!.id,
          rating: _selectedRating,
          comment: comment,
          title: title,
          pros: pros,
          cons: cons,
        );
      } else {
        await repo.addReview(
          productId: widget.productId,
          userId: user.id,
          rating: _selectedRating,
          comment: comment,
          title: title,
          pros: pros,
          cons: cons,
          verifiedPurchase: verifiedPurchase,
        );
      }

      ref.invalidate(reviewsForProductProvider(widget.productId));
      ref.invalidate(userReviewProvider(widget.productId));

      if (!mounted) return;
      Navigator.of(context).pop(true);

      final l10n = AppLocalizations.of(context);
      AppToast.show(
        context,
        message: _isEditing
            ? (l10n?.reviewUpdated ?? 'Avis modifié')
            : (l10n?.reviewSubmitted ?? 'Avis publié'),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppToast.show(
        context,
        message: AppLocalizations.of(context)?.errorGeneric ?? 'Une erreur est survenue',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isEditing ? l10n.editReview : l10n.writeReview,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.yourRating,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  StarRating(
                    rating: _selectedRating.toDouble(),
                    onRatingChanged: (rating) {
                      setState(() => _selectedRating = rating);
                    },
                    size: 44,
                    spacing: 10,
                  ),
                  if (_selectedRating > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      _ratingLabel(l10n),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.reviewTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              maxLength: 80,
              decoration: InputDecoration(
                hintText: l10n.reviewTitleHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.yourComment,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: l10n.yourComment,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.pros,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _prosController,
              maxLines: 2,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: l10n.prosHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.cons,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _consController,
              maxLines: 2,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: l10n.consHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: l10n.submitReview,
              onPressed: _selectedRating == 0 ? null : _submit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

/// Ouvre le bottom sheet d'ajout/modification d'avis.
Future<bool?> showAddReviewSheet(
  BuildContext context, {
  required String productId,
  ReviewModel? existingReview,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => AddReviewSheet(
      productId: productId,
      existingReview: existingReview,
    ),
  );
}
