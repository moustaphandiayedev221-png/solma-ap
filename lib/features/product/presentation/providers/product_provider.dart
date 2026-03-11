import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/services/product_cache_service.dart';
import '../../data/product_model.dart';
import '../../data/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

Future<List<ProductModel>> _fetchWithCache(
  ProductRepository repo,
  ProductCacheNotifier cache,
  String cacheKey,
  Future<List<ProductModel>> Function() fetch,
) async {
  try {
    final list = await fetch();
    cache.set(cacheKey, list);
    return list;
  } catch (e) {
    final failure = e is AppFailure ? e : e.toAppFailure();
    if (failure.type == AppFailureType.connection ||
        failure.type == AppFailureType.timeout) {
      final cached = cache.get(cacheKey);
      if (cached != null && cached.isNotEmpty) return cached;
    }
    rethrow;
  }
}

final popularProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  final cache = ref.read(productCacheProvider.notifier);
  return _fetchWithCache(
    repo,
    cache,
    'popular_all',
    () => repo.getPopularProducts(limit: 12),
  );
});

final sportsProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  final cache = ref.read(productCacheProvider.notifier);
  return _fetchWithCache(
    repo,
    cache,
    'sports_all',
    () => repo.getSportsProducts(limit: 12),
  );
});

/// Produits populaires filtrés par catégorie.
/// [categoryFilter] = 'all' pour tous les produits, sinon l'UUID de la catégorie.
final popularProductsByCategoryProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, categoryFilter) async {
  final repo = ref.read(productRepositoryProvider);
  final cache = ref.read(productCacheProvider.notifier);
  final catId = categoryFilter.isEmpty ||
          categoryFilter == 'All' ||
          categoryFilter.toLowerCase() == 'all'
      ? null
      : categoryFilter;
  final cacheKey = 'popular_${categoryFilter}_$catId';
  return _fetchWithCache(
    repo,
    cache,
    cacheKey,
    () => repo.getPopularProducts(limit: 12, categoryId: catId),
  );
});

/// Produits Sacs à Main filtrés par catégorie.
/// [categoryFilter] = 'all' pour tous les produits, sinon l'UUID de la catégorie.
final sacsAMainByCategoryProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, categoryFilter) async {
  final repo = ref.read(productRepositoryProvider);
  final cache = ref.read(productCacheProvider.notifier);
  final catId = categoryFilter.isEmpty ||
          categoryFilter == 'All' ||
          categoryFilter.toLowerCase() == 'all'
      ? null
      : categoryFilter;
  final cacheKey = 'sacs_a_main_${categoryFilter}_$catId';
  return _fetchWithCache(
    repo,
    cache,
    cacheKey,
    () => repo.getSacsAMainProducts(limit: 12, categoryId: catId),
  );
});

/// Produits Tenues Africaines filtrés par catégorie.
/// [categoryFilter] = 'all' pour tous les produits, sinon l'UUID de la catégorie.
final tenuesAfricainesByCategoryProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, categoryFilter) async {
  final repo = ref.read(productRepositoryProvider);
  final cache = ref.read(productCacheProvider.notifier);
  final catId = categoryFilter.isEmpty ||
          categoryFilter == 'All' ||
          categoryFilter.toLowerCase() == 'all'
      ? null
      : categoryFilter;
  final cacheKey = 'tenues_africaines_${categoryFilter}_$catId';
  return _fetchWithCache(
    repo,
    cache,
    cacheKey,
    () => repo.getTenuesAfricainesProducts(limit: 12, categoryId: catId),
  );
});

/// Produits sports filtrés par catégorie.
/// [categoryFilter] = 'all' pour tous les produits, sinon l'UUID de la catégorie.
final sportsProductsByCategoryProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, categoryFilter) async {
  final repo = ref.read(productRepositoryProvider);
  final cache = ref.read(productCacheProvider.notifier);
  final catId = categoryFilter.isEmpty ||
          categoryFilter == 'All' ||
          categoryFilter.toLowerCase() == 'all'
      ? null
      : categoryFilter;
  final cacheKey = 'sports_${categoryFilter}_$catId';
  return _fetchWithCache(
    repo,
    cache,
    cacheKey,
    () => repo.getSportsProducts(limit: 12, categoryId: catId),
  );
});

/// Tous les produits d'une section (pour "Tout voir").
final productsBySectionProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, section) async {
  final repo = ref.read(productRepositoryProvider);
  final cache = ref.read(productCacheProvider.notifier);
  final cacheKey = 'section_$section';
  return _fetchWithCache(
    repo,
    cache,
    cacheKey,
    () async {
      if (section == 'popular') return repo.getPopularProducts(limit: 50);
      if (section == 'sports') return repo.getSportsProducts(limit: 50);
      if (section == 'new') return repo.getNewProducts(limit: 50);
      if (section == 'tenues-africaines') return repo.getTenuesAfricainesProducts(limit: 50);
      if (section == 'sacs-a-main') return repo.getSacsAMainProducts(limit: 50);
      return repo.getProductsBySection(section, limit: 50);
    },
  );
});

/// Produits d'une section filtrés par catégorie (sections dynamiques).
final sectionProductsByCategoryProvider =
    FutureProvider.family<List<ProductModel>, (String, String)>((ref, params) async {
  final (sectionKey, categoryFilter) = params;
  final repo = ref.read(productRepositoryProvider);
  final cache = ref.read(productCacheProvider.notifier);
  final catId = categoryFilter.isEmpty ||
          categoryFilter == 'All' ||
          categoryFilter.toLowerCase() == 'all'
      ? null
      : categoryFilter;
  final cacheKey = 'section_${sectionKey}_$categoryFilter';
  return _fetchWithCache(
    repo,
    cache,
    cacheKey,
    () async {
      if (sectionKey == 'popular') {
        return repo.getPopularProducts(limit: 12, categoryId: catId);
      }
      return repo.getProductsBySection(sectionKey, limit: 12, categoryId: catId);
    },
  );
});

final productByIdProvider = FutureProvider.family<ProductModel?, String>((ref, id) async {
  return ref.read(productRepositoryProvider).getProductById(id);
});

/// Tous les produits (pour la page recherche quand le champ est vide).
final allProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  return ref.read(productRepositoryProvider).getProducts(limit: 80);
});

/// Recherche produits par nom (query vide = liste vide, pas d'appel API).
final searchProductsProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  return ref.read(productRepositoryProvider).searchProducts(query, limit: 30);
});

/// Produits filtrés par slug de catégorie (ex. men, women, kids). Si slug == "All", retourne [] (pas d'appel API).
final productsByCategoryProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, categorySlug) async {
  if (categorySlug.isEmpty || categorySlug == 'All') return [];
  return ref.read(productRepositoryProvider).getProducts(
        categorySlug: categorySlug,
        limit: 50,
      );
});
