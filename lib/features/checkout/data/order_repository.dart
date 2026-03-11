import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.total,
    this.shippingAddress,
    required this.createdAt,
    this.items = const [],
  });

  final String id;
  final String userId;
  final String status;
  final double total;
  final Map<String, dynamic>? shippingAddress;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String? ?? 'pending',
      total: (json['total'] as num).toDouble(),
      shippingAddress: json['shipping_address'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: [],
    );
  }
}

class OrderItemModel {
  const OrderItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.size,
    this.color,
  });

  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? size;
  final String? color;
}

class OrderRepository {
  OrderRepository([SupabaseClient? client]) : _client = client ?? supabaseClient;

  final SupabaseClient _client;
  static const String _ordersTable = 'orders';
  static const String _itemsTable = 'order_items';

  /// Récupère une commande par son ID (pour les détails depuis une notification).
  Future<OrderModel?> getOrderById(String orderId, String userId) async {
    final res = await _client
        .from(_ordersTable)
        .select()
        .eq('id', orderId)
        .eq('user_id', userId)
        .maybeSingle();
    if (res == null) return null;
    final order = OrderModel.fromJson(res);
    final itemsRes = await _client
        .from(_itemsTable)
        .select()
        .eq('order_id', orderId);
    final items = (itemsRes as List).map((e) {
      final m = e as Map<String, dynamic>;
      return OrderItemModel(
        productId: m['product_id'] as String,
        name: m['name'] as String,
        price: (m['price'] as num).toDouble(),
        quantity: (m['quantity'] as num).toInt(),
        size: m['size'] as String?,
        color: m['color'] as String?,
      );
    }).toList();
    return OrderModel(
      id: order.id,
      userId: order.userId,
      status: order.status,
      total: order.total,
      shippingAddress: order.shippingAddress,
      createdAt: order.createdAt,
      items: items,
    );
  }

  Future<List<OrderModel>> getOrders(String userId) async {
    final res = await _client
        .from(_ordersTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    final orders = <OrderModel>[];
    for (final e in res as List) {
      final order = OrderModel.fromJson(e as Map<String, dynamic>);
      final itemsRes = await _client
          .from(_itemsTable)
          .select()
          .eq('order_id', order.id);
      final items = (itemsRes as List).map((e) {
        final m = e as Map<String, dynamic>;
        return OrderItemModel(
          productId: m['product_id'] as String,
          name: m['name'] as String,
          price: (m['price'] as num).toDouble(),
          quantity: (m['quantity'] as num).toInt(),
          size: m['size'] as String?,
          color: m['color'] as String?,
        );
      }).toList();
      orders.add(OrderModel(
        id: order.id,
        userId: order.userId,
        status: order.status,
        total: order.total,
        shippingAddress: order.shippingAddress,
        createdAt: order.createdAt,
        items: items,
      ));
    }
    return orders;
  }

  /// Crée une commande et ses lignes. Retourne l'id de la commande.
  Future<String> createOrder({
    required String userId,
    required double total,
    Map<String, dynamic>? shippingAddress,
    required List<OrderItemModel> items,
    String? promoCode,
    double discountAmount = 0,
  }) async {
    final orderData = <String, dynamic>{
      'user_id': userId,
      'status': 'paid',
      'total': total,
      'shipping_address': shippingAddress,
    };
    if (promoCode != null) {
      orderData['promo_code'] = promoCode;
      orderData['discount_amount'] = discountAmount;
    }
    final orderRes = await _client
        .from(_ordersTable)
        .insert(orderData)
        .select('id')
        .single();
    final orderId = orderRes['id'] as String;

    for (final item in items) {
      await _client.from(_itemsTable).insert({
        'order_id': orderId,
        'product_id': item.productId,
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
        'size': item.size,
        'color': item.color,
      });
    }
    return orderId;
  }
}

