import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../checkout/presentation/providers/order_provider.dart';
import '../../../reviews/presentation/providers/review_provider.dart';
import '../../data/profile_repository.dart';

final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => ProfileRepository());

/// Profil de l'utilisateur connecté (table profiles). Null si non connecté.
final profileProvider = FutureProvider<ProfileModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.read(profileRepositoryProvider).getProfile(user.id);
});

/// Statistiques du profil : commandes, note, points, avis.
final profileStatsProvider = FutureProvider<ProfileStats>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const ProfileStats(0, 0, 0, 0);

  final ordersAsync = ref.watch(userOrdersProvider);
  final orders = ordersAsync.valueOrNull ?? [];
  final totalOrders = orders.length;

  final reviewRepo = ref.read(reviewRepositoryProvider);
  final reviewStats = await reviewRepo.getUserReviewStats(user.id);
  final rating = reviewStats.avgRating;
  final reviewCount = reviewStats.count;

  // Points : 100 par commande livrée + 50 par avis (exemple)
  final deliveredCount = orders.where((o) => o.status == 'delivered').length;
  final points = (deliveredCount * 100) + (reviewCount * 50);

  return ProfileStats(totalOrders, rating, points, reviewCount);
});

class ProfileStats {
  const ProfileStats(
    this.totalOrders,
    this.rating,
    this.points,
    this.reviewCount,
  );
  final int totalOrders;
  final double rating;
  final int points;
  final int reviewCount;
}
