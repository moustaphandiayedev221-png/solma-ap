import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';
import 'category_model.dart';

/// Repository des catégories (Supabase table categories)
class CategoryRepository {
  CategoryRepository([SupabaseClient? client]) : _client = client ?? supabaseClient;

  final SupabaseClient _client;

  static const String _table = 'categories';

  /// Liste toutes les catégories, triées par name, sans doublon de slug
  Future<List<CategoryModel>> getCategories() async {
    final res = await _client
        .from(_table)
        .select()
        .order('name', ascending: true);
    final list = (res as List)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
    // Une seule catégorie par slug (évite tout doublon venant de la base)
    final bySlug = <String, CategoryModel>{};
    for (final c in list) {
      final slug = c.slug.trim().toLowerCase();
      bySlug.putIfAbsent(slug, () => c);
    }
    return bySlug.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
}
