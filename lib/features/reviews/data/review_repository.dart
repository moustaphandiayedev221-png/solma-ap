import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_provider.dart';
import 'review_model.dart';

/// Repository pour les avis produits — CRUD complet, système professionnel.
class ReviewRepository {
  ReviewRepository([SupabaseClient? client])
      : _client = client ?? supabaseClient;

  final SupabaseClient _client;
  static const String _table = 'reviews';
  static const String _votesTable = 'review_helpful_votes';

  /// Récupère tous les avis d'un produit, triés par date décroissante.
  Future<List<ReviewModel>> getReviewsForProduct(String productId) async {
    final res = await _client
        .from(_table)
        .select('*, profiles(full_name)')
        .eq('product_id', productId)
        .order('created_at', ascending: false);

    return (res as List)
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Votes "utile / pas utile" de l'utilisateur pour les avis d'un produit.
  Future<Map<String, bool>> getUserVotesForProduct(
    String productId,
    String userId,
  ) async {
    final reviewsRes = await _client
        .from(_table)
        .select('id')
        .eq('product_id', productId);
    final reviewIds =
        (reviewsRes as List).map((e) => (e as Map)['id'] as String).toList();
    if (reviewIds.isEmpty) return {};

    final votesRes = await _client
        .from(_votesTable)
        .select('review_id, helpful')
        .eq('user_id', userId)
        .inFilter('review_id', reviewIds);

    return {
      for (final v in votesRes as List)
        (v as Map)['review_id'] as String: (v['helpful'] as bool),
    };
  }

  /// Indique si l'utilisateur a acheté le produit (pour "achat vérifié").
  Future<bool> hasUserPurchasedProduct(String userId, String productId) async {
    final ordersRes = await _client
        .from('orders')
        .select('id')
        .eq('user_id', userId)
        .inFilter('status', ['paid', 'shipped', 'delivered']);
    final orderIds =
        (ordersRes as List).map((e) => (e as Map)['id'] as String).toList();
    if (orderIds.isEmpty) return false;

    final match = await _client
        .from('order_items')
        .select('id')
        .eq('product_id', productId)
        .inFilter('order_id', orderIds)
        .limit(1)
        .maybeSingle();
    return match != null;
  }

  /// Récupère l'avis de l'utilisateur courant pour un produit donné.
  Future<ReviewModel?> getUserReview(String productId, String userId) async {
    final res = await _client
        .from(_table)
        .select('*, profiles(full_name)')
        .eq('product_id', productId)
        .eq('user_id', userId)
        .maybeSingle();

    if (res == null) return null;
    return ReviewModel.fromJson(res);
  }

  /// Ajoute un nouvel avis.
  Future<ReviewModel> addReview({
    required String productId,
    required String userId,
    required int rating,
    String? comment,
    String? title,
    String? pros,
    String? cons,
    bool verifiedPurchase = false,
  }) async {
    final res = await _client
        .from(_table)
        .insert({
          'product_id': productId,
          'user_id': userId,
          'rating': rating,
          'comment': comment,
          'title': title,
          'pros': pros,
          'cons': cons,
          'verified_purchase': verifiedPurchase,
        })
        .select('*, profiles(full_name)')
        .single();

    return ReviewModel.fromJson(res);
  }

  /// Met à jour un avis existant.
  Future<ReviewModel> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
    String? title,
    String? pros,
    String? cons,
  }) async {
    final res = await _client
        .from(_table)
        .update({
          'rating': rating,
          'comment': comment,
          'title': title,
          'pros': pros,
          'cons': cons,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', reviewId)
        .select('*, profiles(full_name)')
        .single();

    return ReviewModel.fromJson(res);
  }

  /// Supprime un avis.
  Future<void> deleteReview(String reviewId) async {
    await _client.from(_table).delete().eq('id', reviewId);
  }

  /// Vote "utile" ou "pas utile" sur un avis.
  /// Le trigger DB met à jour automatiquement helpful_count / not_helpful_count.
  Future<void> voteHelpful({
    required String reviewId,
    required String userId,
    required bool helpful,
  }) async {
    await _client.from(_votesTable).upsert({
      'review_id': reviewId,
      'user_id': userId,
      'helpful': helpful,
    }, onConflict: 'review_id,user_id');
  }

  /// Nombre d'avis et note moyenne de l'utilisateur.
  Future<({int count, double avgRating})> getUserReviewStats(String userId) async {
    final res = await _client
        .from(_table)
        .select('rating')
        .eq('user_id', userId);
    final list = res as List;
    if (list.isEmpty) return (count: 0, avgRating: 0.0);
    final ratings = list.map((e) => (e as Map)['rating'] as int).toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;
    return (count: ratings.length, avgRating: avg);
  }
}
