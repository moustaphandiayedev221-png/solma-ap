import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';

/// Une ligne panier côté Supabase (sans détail produit).
class CartRow {
  const CartRow({
    required this.productId,
    required this.quantity,
    this.size = '',
    this.color = '',
  });

  final String productId;
  final int quantity;
  final String size;
  final String color;
}

class CartRepository {
  CartRepository([SupabaseClient? client]) : _client = client ?? supabaseClient;

  final SupabaseClient _client;
  static const String _table = 'cart';

  /// Utiliser une valeur fixe pour size/color quand non choisi pour respecter UNIQUE.
  static const String _defaultVariant = '';

  Future<List<CartRow>> getCart(String userId) async {
    final res = await _client
        .from(_table)
        .select('product_id, quantity, size, color')
        .eq('user_id', userId);
    return (res as List)
        .map((e) {
          final m = e as Map<String, dynamic>;
          return CartRow(
            productId: m['product_id'] as String,
            quantity: (m['quantity'] as num).toInt(),
            size: (m['size'] as String?) ?? _defaultVariant,
            color: (m['color'] as String?) ?? _defaultVariant,
          );
        })
        .toList();
  }

  Future<void> addItem(
    String userId, {
    required String productId,
    int quantity = 1,
    String size = _defaultVariant,
    String color = _defaultVariant,
  }) async {
    final existing = await _client
        .from(_table)
        .select('id, quantity')
        .eq('user_id', userId)
        .eq('product_id', productId)
        .eq('size', size)
        .eq('color', color)
        .maybeSingle();

    if (existing != null) {
      final newQty = (existing['quantity'] as num).toInt() + quantity;
      await _client.from(_table).update({'quantity': newQty}).eq('id', existing['id']);
    } else {
      await _client.from(_table).insert({
        'user_id': userId,
        'product_id': productId,
        'size': size,
        'color': color,
        'quantity': quantity,
      });
    }
  }

  Future<void> removeItem(
    String userId, {
    required String productId,
    String size = _defaultVariant,
    String color = _defaultVariant,
  }) async {
    await _client
        .from(_table)
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId)
        .eq('size', size)
        .eq('color', color);
  }

  Future<void> setQuantity(
    String userId, {
    required String productId,
    required int quantity,
    String size = _defaultVariant,
    String color = _defaultVariant,
  }) async {
    if (quantity <= 0) {
      await removeItem(userId, productId: productId, size: size, color: color);
      return;
    }
    final existing = await _client
        .from(_table)
        .select('id')
        .eq('user_id', userId)
        .eq('product_id', productId)
        .eq('size', size)
        .eq('color', color)
        .maybeSingle();
    if (existing != null) {
      await _client.from(_table).update({'quantity': quantity}).eq('id', existing['id']);
    } else {
      await addItem(userId, productId: productId, quantity: quantity, size: size, color: color);
    }
  }

  Future<void> clear(String userId) async {
    await _client.from(_table).delete().eq('user_id', userId);
  }
}
