import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';
import 'publicite_model.dart';

/// Repository des publicités (Supabase).
class PublicitesRepository {
  PublicitesRepository([SupabaseClient? client])
      : _client = client ?? supabaseClient;

  final SupabaseClient _client;

  static const String _table = 'publicites';

  /// Liste les publicités actives, triées par sort_order.
  Future<List<PubliciteModel>> getPublicites({int limit = 20}) async {
    final res = await _client
        .from(_table)
        .select()
        .eq('is_active', true)
        .order('sort_order')
        .limit(limit);
    return (res as List)
        .map((e) => PubliciteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Liste les publicités actives pour une section donnée.
  Future<List<PubliciteModel>> getPublicitesBySection(
    String section, {
    int limit = 10,
  }) async {
    final res = await _client
        .from(_table)
        .select()
        .eq('is_active', true)
        .eq('section', section)
        .order('sort_order')
        .limit(limit);
    return (res as List)
        .map((e) => PubliciteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
