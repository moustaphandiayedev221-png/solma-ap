import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';

class WishlistRepository {
  WishlistRepository([SupabaseClient? client]) : _client = client ?? supabaseClient;

  final SupabaseClient _client;
  static const String _table = 'wishlist';

  Future<List<String>> getWishlist(String userId) async {
    final res = await _client
        .from(_table)
        .select('product_id')
        .eq('user_id', userId);
    return (res as List)
        .map((e) => (e as Map<String, dynamic>)['product_id'] as String)
        .toList();
  }

  Future<void> add(String userId, String productId) async {
    await _client.from(_table).insert({
      'user_id': userId,
      'product_id': productId,
    });
  }

  Future<void> remove(String userId, String productId) async {
    await _client
        .from(_table)
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }

  Future<void> toggle(String userId, String productId) async {
    final existing = await _client
        .from(_table)
        .select('id')
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();
    if (existing != null) {
      await remove(userId, productId);
    } else {
      await add(userId, productId);
    }
  }
}
