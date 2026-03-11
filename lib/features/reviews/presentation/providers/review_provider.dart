import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/review_model.dart';
import '../../data/review_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Repository provider pour les avis.
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});

/// Liste des avis pour un produit donné (avec votes de l'utilisateur courant).
final reviewsForProductProvider =
    FutureProvider.family<List<ReviewModel>, String>((ref, productId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final reviews = await repo.getReviewsForProduct(productId);
  if (user == null || reviews.isEmpty) return reviews;

  final votes = await repo.getUserVotesForProduct(productId, user.id);
  return reviews
      .map((r) => r.copyWith(userVote: votes[r.id]))
      .toList();
});

/// Avis de l'utilisateur courant pour un produit donné.
final userReviewProvider =
    FutureProvider.family<ReviewModel?, String>((ref, productId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return repo.getUserReview(productId, user.id);
});

/// Indique si l'utilisateur a acheté le produit (pour badge "achat vérifié").
final hasPurchasedProductProvider =
    FutureProvider.family<bool, ({String productId, String? userId})>((ref, params) async {
  if (params.userId == null) return false;
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.hasUserPurchasedProduct(params.userId!, params.productId);
});

/// Note moyenne d'un produit.
final averageRatingProvider =
    Provider.family<double, String>((ref, productId) {
  final reviewsAsync = ref.watch(reviewsForProductProvider(productId));
  return reviewsAsync.when(
    data: (reviews) {
      if (reviews.isEmpty) return 0.0;
      final total = reviews.fold<int>(0, (sum, r) => sum + r.rating);
      return total / reviews.length;
    },
    loading: () => 0.0,
    error: (error, stackTrace) => 0.0,
  );
});

/// Nombre d'avis d'un produit.
final reviewCountProvider =
    Provider.family<int, String>((ref, productId) {
  final reviewsAsync = ref.watch(reviewsForProductProvider(productId));
  return reviewsAsync.when(
    data: (reviews) => reviews.length,
    loading: () => 0,
    error: (error, stackTrace) => 0,
  );
});

/// Distribution des notes (5→n5, 4→n4, etc.) pour affichage barres.
final reviewDistributionProvider =
    Provider.family<Map<int, int>, String>((ref, productId) {
  final reviewsAsync = ref.watch(reviewsForProductProvider(productId));
  return reviewsAsync.when(
    data: (reviews) {
      final m = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (final r in reviews) {
        m[r.rating] = (m[r.rating] ?? 0) + 1;
      }
      return m;
    },
    loading: () => {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
    error: (error, stackTrace) => {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
  );
});
