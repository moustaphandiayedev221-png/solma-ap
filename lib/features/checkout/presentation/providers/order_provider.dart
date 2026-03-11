import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/order_repository.dart';

final orderRepositoryProvider =
    Provider<OrderRepository>((ref) => OrderRepository());

/// Commande par ID (pour deep linking).
final orderByIdProvider =
    FutureProvider.autoDispose.family<OrderModel?, ({String orderId, String userId})>(
  (ref, params) =>
      ref.read(orderRepositoryProvider).getOrderById(params.orderId, params.userId),
);

/// Commandes de l'utilisateur connecté.
final userOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(orderRepositoryProvider).getOrders(user.id);
});
