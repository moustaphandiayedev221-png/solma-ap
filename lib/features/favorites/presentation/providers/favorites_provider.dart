import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../product/data/product_model.dart';
import '../../../product/presentation/providers/product_provider.dart';
import '../../data/wishlist_repository.dart';

final wishlistRepositoryProvider =
    Provider<WishlistRepository>((ref) => WishlistRepository());

/// État des favoris : ensemble d'IDs produit.
/// Connecté : Supabase wishlist. Invité : SharedPreferences.
class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    ref.listen(currentUserProvider, (_, user) {
      Future.microtask(() => load());
    });
    Future.microtask(() => load());
    return {};
  }

  static const String _key = AppConstants.keyFavorites;
  static const String _separator = ',';

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      state = {};
      return;
    }
    state = raw.split(_separator).where((s) => s.isNotEmpty).toSet();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (state.isEmpty) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, state.join(_separator));
    }
  }

  Future<void> load() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      try {
        final ids = await ref.read(wishlistRepositoryProvider).getWishlist(user.id);
        state = ids.toSet();
      } catch (e, st) {
        debugPrint('[FavoritesNotifier] load error: $e\n$st');
      }
    } else {
      await _loadFromPrefs();
    }
  }

  bool contains(String productId) => state.contains(productId);

  /// Toggle avec optimistic update + rollback en cas d'erreur backend.
  void toggle(String productId) {
    final previous = Set<String>.from(state);
    final next = Set<String>.from(state);
    if (next.contains(productId)) {
      next.remove(productId);
    } else {
      next.add(productId);
    }
    state = next;
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _syncBackend(
        action: () => ref.read(wishlistRepositoryProvider).toggle(user.id, productId),
        rollback: previous,
        label: 'toggle',
      );
    } else {
      _saveToPrefs();
    }
  }

  /// Ajoute un favori avec optimistic update + rollback.
  void add(String productId) {
    if (state.contains(productId)) return;
    final previous = Set<String>.from(state);
    state = Set<String>.from(state)..add(productId);
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _syncBackend(
        action: () => ref.read(wishlistRepositoryProvider).add(user.id, productId),
        rollback: previous,
        label: 'add',
      );
    } else {
      _saveToPrefs();
    }
  }

  /// Retire un favori avec optimistic update + rollback.
  void remove(String productId) {
    if (!state.contains(productId)) return;
    final previous = Set<String>.from(state);
    state = Set<String>.from(state)..remove(productId);
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _syncBackend(
        action: () => ref.read(wishlistRepositoryProvider).remove(user.id, productId),
        rollback: previous,
        label: 'remove',
      );
    } else {
      _saveToPrefs();
    }
  }

  /// Synchronise l'action avec le backend. Rollback en cas d'échec.
  Future<void> _syncBackend({
    required Future<void> Function() action,
    required Set<String> rollback,
    required String label,
  }) async {
    try {
      await action();
    } catch (e, st) {
      debugPrint('[FavoritesNotifier] $label sync failed, rolling back: $e\n$st');
      state = rollback;
    }
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

/// Nombre de favoris (pour badge éventuel).
final favoritesCountProvider = Provider<int>((ref) {
  return ref.watch(favoritesProvider).length;
});

/// Liste des produits favoris (pour l'écran Wishlist).
/// Toutes les requêtes sont lancées en parallèle via Future.wait().
final wishlistProductsProvider =
    FutureProvider<List<ProductModel>>((ref) async {
  final ids = ref.watch(favoritesProvider);
  if (ids.isEmpty) return [];

  final futures = ids.map(
    (id) => ref.read(productByIdProvider(id).future),
  );
  final results = await Future.wait(futures);
  return results.whereType<ProductModel>().toList();
});
