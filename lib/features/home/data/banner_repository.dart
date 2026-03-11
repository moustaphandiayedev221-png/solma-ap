import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';
import 'banner_model.dart';

/// Repository des bannières (Supabase table banners)
class BannerRepository {
  BannerRepository([SupabaseClient? client])
      : _client = client ?? supabaseClient;

  final SupabaseClient _client;

  static const String _table = 'banners';

  /// Bannières actives, triées par sort_order
  Future<List<BannerModel>> getActiveBanners() async {
    final res = await _client
        .from(_table)
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return (res as List)
        .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
