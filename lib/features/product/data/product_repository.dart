import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';
import 'product_model.dart';

/// Résultat paginé avec indication s'il y a une page suivante.
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.hasMore,
  });
  final List<T> items;
  final bool hasMore;
}

/// Repository des produits (Supabase)
class ProductRepository {
  ProductRepository([SupabaseClient? client]) : _client = client ?? supabaseClient;

  final SupabaseClient _client;

  static const String _table = 'products';

  /// Alias de slugs pour compatibilité (ex: "enfants" -> "kids", "hommes" -> "men").
  /// Les slugs canoniques en DB sont men, women, kids.
  static const Map<String, String> _slugAliases = {
    'enfants': 'kids',
    'enfant': 'kids',
    'hommes': 'men',
    'homme': 'men',
    'femmes': 'women',
    'femme': 'women',
  };

  /// Slugs à essayer pour la recherche (canonique + variantes françaises).
  static const Map<String, List<String>> _slugVariants = {
    'men': ['men', 'hommes'],
    'women': ['women', 'femmes'],
    'kids': ['kids', 'enfants'],
  };

  String _resolveCategorySlug(String slug) {
    final lower = slug.trim().toLowerCase();
    return _slugAliases[lower] ?? lower;
  }

  /// Produits de la section "popular" : section='popular' OU is_featured=true.
  /// Un produit "en vedette" (ex: Sacs à Main) apparaît aussi dans Populaire.
  Future<List<ProductModel>> getPopularProducts({
    int limit = 10,
    String? categorySlug,
    String? categoryId,
  }) async {
    var query = _client
        .from(_table)
        .select()
        .or('section.eq.popular,is_featured.eq.true');
    String? catId = categoryId;
    if (catId == null &&
        categorySlug != null &&
        categorySlug.isNotEmpty &&
        categorySlug.toLowerCase() != 'all') {
      final resolvedSlug = _resolveCategorySlug(categorySlug);
      final catRes = await _client
          .from('categories')
          .select('id')
          .eq('slug', resolvedSlug)
          .maybeSingle();
      catId = catRes?['id'] as String?;
    }
    if (catId != null && catId.isNotEmpty) {
      query = query.eq('category_id', catId);
    }
    final res = await query.order('is_featured', ascending: false).limit(limit);
    return (res as List).map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Produits nouveaux (is_new = true).
  Future<List<ProductModel>> getNewProducts({
    int limit = 50,
  }) async {
    final res = await _client
        .from(_table)
        .select()
        .eq('is_new', true)
        .order('created_at', ascending: false)
        .limit(limit);
    return (res as List).map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Produits de la section "sacs-a-main".
  Future<List<ProductModel>> getSacsAMainProducts({
    int limit = 10,
    String? categorySlug,
    String? categoryId,
  }) async {
    var query = _client.from(_table).select().eq('section', 'sacs-a-main');
    String? catId = categoryId;
    if (catId == null &&
        categorySlug != null &&
        categorySlug.isNotEmpty &&
        categorySlug.toLowerCase() != 'all') {
      final resolvedSlug = _resolveCategorySlug(categorySlug);
      final catRes = await _client
          .from('categories')
          .select('id')
          .eq('slug', resolvedSlug)
          .maybeSingle();
      catId = catRes?['id'] as String?;
    }
    if (catId != null && catId.isNotEmpty) {
      query = query.eq('category_id', catId);
    }
    final res = await query.order('is_featured', ascending: false).limit(limit);
    return (res as List).map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Produits de la section "tenues-africaines" (produits africains).
  Future<List<ProductModel>> getTenuesAfricainesProducts({
    int limit = 10,
    String? categorySlug,
    String? categoryId,
  }) async {
    var query = _client.from(_table).select().eq('section', 'tenues-africaines');
    String? catId = categoryId;
    if (catId == null &&
        categorySlug != null &&
        categorySlug.isNotEmpty &&
        categorySlug.toLowerCase() != 'all') {
      final resolvedSlug = _resolveCategorySlug(categorySlug);
      final catRes = await _client
          .from('categories')
          .select('id')
          .eq('slug', resolvedSlug)
          .maybeSingle();
      catId = catRes?['id'] as String?;
    }
    if (catId != null && catId.isNotEmpty) {
      query = query.eq('category_id', catId);
    }
    final res = await query.order('is_featured', ascending: false).limit(limit);
    return (res as List).map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Produits d'une section quelconque (clé dynamique depuis product_sections).
  Future<List<ProductModel>> getProductsBySection(
    String sectionKey, {
    int limit = 10,
    String? categorySlug,
    String? categoryId,
  }) async {
    var query = _client.from(_table).select().eq('section', sectionKey);
    String? catId = categoryId;
    if (catId == null &&
        categorySlug != null &&
        categorySlug.isNotEmpty &&
        categorySlug.toLowerCase() != 'all') {
      final resolvedSlug = _resolveCategorySlug(categorySlug);
      final catRes = await _client
          .from('categories')
          .select('id')
          .eq('slug', resolvedSlug)
          .maybeSingle();
      catId = catRes?['id'] as String?;
    }
    if (catId != null && catId.isNotEmpty) {
      query = query.eq('category_id', catId);
    }
    final res = await query.order('is_featured', ascending: false).limit(limit);
    return (res as List).map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Produits de la section "sports" (filtrés par categoryId ou categorySlug).
  Future<List<ProductModel>> getSportsProducts({
    int limit = 10,
    String? categorySlug,
    String? categoryId,
  }) async {
    var query = _client.from(_table).select().eq('section', 'sports');
    String? catId = categoryId;
    if (catId == null &&
        categorySlug != null &&
        categorySlug.isNotEmpty &&
        categorySlug.toLowerCase() != 'all') {
      final resolvedSlug = _resolveCategorySlug(categorySlug);
      final catRes = await _client
          .from('categories')
          .select('id')
          .eq('slug', resolvedSlug)
          .maybeSingle();
      catId = catRes?['id'] as String?;
    }
    if (catId != null && catId.isNotEmpty) {
      query = query.eq('category_id', catId);
    }
    final res = await query.limit(limit);
    return (res as List).map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Un produit par ID
  Future<ProductModel?> getProductById(String id) async {
    final res = await _client.from(_table).select().eq('id', id).maybeSingle();
    if (res == null) return null;
    return ProductModel.fromJson(res);
  }

  /// Recherche par nom : recherche partielle insensible à la casse.
  /// Sanitize les caractères spéciaux SQL LIKE (%, _).
  Future<List<ProductModel>> searchProducts(String query, {int limit = 30}) async {
    final q = sanitizeLikeQuery(query.trim());
    if (q.isEmpty) return [];
    final res = await _client
        .from(_table)
        .select()
        .ilike('name', '%$q%')
        .limit(limit);
    return (res as List).map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Tous les produits avec pagination.
  /// Retourne un [PaginatedResult] avec les items et un indicateur hasMore.
  /// Filtre strict par category_id : si une catégorie est demandée et non trouvée, retourne [].
  Future<PaginatedResult<ProductModel>> getProductsPaginated({
    String? categorySlug,
    int limit = 20,
    int offset = 0,
  }) async {
    if (categorySlug != null &&
        categorySlug.trim().toLowerCase() != 'all' &&
        categorySlug.trim().isNotEmpty) {
      final resolvedSlug = _resolveCategorySlug(categorySlug);
      final variants = _slugVariants[resolvedSlug] ?? [resolvedSlug];
      String? catId;
      for (final s in variants) {
        final catRes = await _client
            .from('categories')
            .select('id')
            .ilike('slug', s)
            .maybeSingle();
        if (catRes != null) {
          catId = catRes['id'] as String?;
          if (catId != null && catId.isNotEmpty) break;
        }
      }
      if (catId == null || catId.isEmpty) {
        return const PaginatedResult(items: [], hasMore: false);
      }
      final res = await _client
          .from(_table)
          .select()
          .eq('category_id', catId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit + 1);
      final items = (res as List)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final hasMore = items.length > limit;
      if (hasMore) items.removeLast();
      return PaginatedResult(items: items, hasMore: hasMore);
    }
    final res = await _client
        .from(_table)
        .select()
        .order('created_at', ascending: false)
        .range(offset, offset + limit + 1);
    final items = (res as List)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final hasMore = items.length > limit;
    if (hasMore) items.removeLast();
    return PaginatedResult(items: items, hasMore: hasMore);
  }

  /// Ancien getter sans pagination (rétro-compatibilité).
  Future<List<ProductModel>> getProducts({
    String? categorySlug,
    int limit = 50,
    int offset = 0,
  }) async {
    final result = await getProductsPaginated(
      categorySlug: categorySlug,
      limit: limit,
      offset: offset,
    );
    return result.items;
  }

  /// Sanitize les caractères spéciaux SQL LIKE.
  @visibleForTesting
  static String sanitizeLikeQuery(String input) {
    return input
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }
}
