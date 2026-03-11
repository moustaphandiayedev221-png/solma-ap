import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/debouncer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../product/data/product_model.dart';
import '../../../product/presentation/providers/product_provider.dart';
import '../../data/cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) => CartRepository());

/// Clé composite identifiant une ligne panier (produit + variante).
@immutable
class CartItemKey {
  const CartItemKey({
    required this.productId,
    this.size = '',
    this.color = '',
  });

  final String productId;
  final String size;
  final String color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemKey &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          size == other.size &&
          color == other.color;

  @override
  int get hashCode => Object.hash(productId, size, color);

  @override
  String toString() => 'CartItemKey($productId, size=$size, color=$color)';
}

/// Ligne panier avec produit chargé depuis Supabase
class CartItemWithProduct {
  const CartItemWithProduct({
    required this.product,
    required this.quantity,
    this.size = '',
    this.color = '',
  });
  final ProductModel product;
  final int quantity;
  final String size;
  final String color;
  double get lineTotal => product.price * quantity;

  CartItemKey get key => CartItemKey(
        productId: product.id,
        size: size,
        color: color,
      );
}

/// État du panier : CartItemKey -> quantité.
/// Supporte les variantes (size/color) pour un même produit.
class CartState {
  const CartState([this._items = const {}]);
  final Map<CartItemKey, int> _items;

  Map<CartItemKey, int> get items => Map.unmodifiable(_items);

  int get itemCount =>
      _items.values.fold(0, (int sum, int qty) => sum + qty);

  /// Quantité totale pour un productId (toutes variantes confondues).
  int quantityForProduct(String productId) {
    return _items.entries
        .where((e) => e.key.productId == productId)
        .fold(0, (sum, e) => sum + e.value);
  }

  CartState addItem(CartItemKey key) {
    final next = Map<CartItemKey, int>.from(_items);
    next[key] = (next[key] ?? 0) + 1;
    return CartState(next);
  }

  CartState removeItem(CartItemKey key) {
    final next = Map<CartItemKey, int>.from(_items);
    final qty = next[key] ?? 0;
    if (qty <= 1) {
      next.remove(key);
    } else {
      next[key] = qty - 1;
    }
    return CartState(next);
  }

  CartState removeAll(CartItemKey key) {
    final next = Map<CartItemKey, int>.from(_items);
    next.remove(key);
    return CartState(next);
  }

  CartState clear() => const CartState();
}

class CartNotifier extends Notifier<CartState> {
  /// Debouncers par clé pour grouper les +/- rapides en un seul appel setQuantity.
  final Map<CartItemKey, Debouncer> _debouncers = {};
  /// État avant la première modification d'une série debounced (pour rollback).
  final Map<CartItemKey, CartState> _rollbackStates = {};

  @override
  CartState build() {
    ref.listen(currentUserProvider, (_, user) {
      if (user != null) loadFromBackend(user.id);
    });
    final user = ref.read(currentUserProvider);
    if (user != null) {
      Future.microtask(() => loadFromBackend(user.id));
    }
    return const CartState();
  }

  Future<void> loadFromBackend(String userId) async {
    try {
      final rows = await ref.read(cartRepositoryProvider).getCart(userId);
      state = CartState(Map.fromEntries(
        rows.map((r) => MapEntry(
          CartItemKey(productId: r.productId, size: r.size, color: r.color),
          r.quantity,
        )),
      ));
    } catch (e, st) {
      debugPrint('[CartNotifier] loadFromBackend error: $e\n$st');
    }
  }

  /// Ajoute un article avec optimistic update + debounce backend.
  void addItem(String productId, {String size = '', String color = ''}) {
    final key = CartItemKey(productId: productId, size: size, color: color);
    _saveRollbackIfNew(key);
    state = state.addItem(key);
    _debouncedSync(key);
  }

  /// Retire un article (décrémente) avec optimistic update + debounce backend.
  void removeItem(String productId, {String size = '', String color = ''}) {
    final key = CartItemKey(productId: productId, size: size, color: color);
    _saveRollbackIfNew(key);
    state = state.removeItem(key);
    _debouncedSync(key);
  }

  /// Retire toutes les unités d'une variante (immédiat, pas de debounce).
  void removeAll(String productId, {String size = '', String color = ''}) {
    final key = CartItemKey(productId: productId, size: size, color: color);
    _cancelDebouncer(key);
    final previous = state;
    state = state.removeAll(key);
    _syncBackend(
      action: () => ref.read(cartRepositoryProvider).removeItem(
            ref.read(currentUserProvider)!.id,
            productId: productId,
            size: size,
            color: color,
          ),
      rollback: previous,
      label: 'removeAll',
    );
  }

  /// Vide le panier (immédiat, pas de debounce).
  void clear() {
    _cancelAllDebouncers();
    final previous = state;
    state = state.clear();
    _syncBackend(
      action: () => ref.read(cartRepositoryProvider).clear(
            ref.read(currentUserProvider)!.id,
          ),
      rollback: previous,
      label: 'clear',
    );
  }

  /// Sauvegarde l'état de rollback au début d'une série de modifications rapides.
  void _saveRollbackIfNew(CartItemKey key) {
    if (!(_debouncers[key]?.isActive ?? false)) {
      _rollbackStates[key] = state;
    }
  }

  /// Debounce le sync backend pour une clé : attend 500ms d'inactivité avant de synchroniser.
  void _debouncedSync(CartItemKey key) {
    _debouncers[key] ??= Debouncer(milliseconds: 500);
    _debouncers[key]!.run(() {
      final rollback = _rollbackStates.remove(key) ?? state;
      final currentQty = state.items[key] ?? 0;
      _syncBackend(
        action: () => ref.read(cartRepositoryProvider).setQuantity(
              ref.read(currentUserProvider)!.id,
              productId: key.productId,
              quantity: currentQty,
              size: key.size,
              color: key.color,
            ),
        rollback: rollback,
        label: 'debouncedSync(${key.productId})',
      );
    });
  }

  void _cancelDebouncer(CartItemKey key) {
    _debouncers[key]?.dispose();
    _debouncers.remove(key);
    _rollbackStates.remove(key);
  }

  void _cancelAllDebouncers() {
    for (final d in _debouncers.values) {
      d.dispose();
    }
    _debouncers.clear();
    _rollbackStates.clear();
  }

  Future<void> _syncBackend({
    required Future<void> Function() action,
    required CartState rollback,
    required String label,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await action();
    } catch (e, st) {
      debugPrint('[CartNotifier] $label sync failed, rolling back: $e\n$st');
      state = rollback;
    }
  }
}

final cartProvider =
    NotifierProvider<CartNotifier, CartState>(CartNotifier.new);

/// Nombre total d'articles dans le panier (pour le badge).
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).itemCount;
});

/// Liste synchrone des lignes du panier (clé + quantité).
final cartLineIdsProvider = Provider<List<({CartItemKey key, int quantity})>>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.items.entries
      .map((e) => (key: e.key, quantity: e.value))
      .toList();
});

/// Liste des lignes du panier avec les détails produit (nom, prix, image).
/// Toutes les requêtes produit sont lancées en parallèle via Future.wait().
final cartItemsWithProductsProvider =
    FutureProvider<List<CartItemWithProduct>>((ref) async {
  final cart = ref.watch(cartProvider);
  if (cart.items.isEmpty) return const [];

  final futures = cart.items.entries.map(
    (entry) => ref
        .read(productByIdProvider(entry.key.productId).future)
        .then((product) => product != null
            ? CartItemWithProduct(
                product: product,
                quantity: entry.value,
                size: entry.key.size,
                color: entry.key.color,
              )
            : null),
  );

  final results = await Future.wait(futures);
  return results.whereType<CartItemWithProduct>().toList();
});
