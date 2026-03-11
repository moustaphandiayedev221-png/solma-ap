import 'dart:convert';

import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import 'notification_model.dart';

/// Gère la navigation selon le deep link d'une notification
class NotificationDeepLinkHandler {
  NotificationDeepLinkHandler._();

  /// Navigue selon le payload (JSON) ou le deep_link.
  static void navigate(GoRouter router, String payload) {
    final parsed = NotificationModel.fromTapPayload(payload);
    String? deepLink = parsed?.effectiveDeepLink;
    String? orderId = parsed?.data['order_id'] as String?;
    String? productId = parsed?.data['product_id'] as String?;

    if (deepLink == null || deepLink.isEmpty) {
      try {
        final map = jsonDecode(payload) as Map<String, dynamic>?;
        deepLink = map?['deep_link'] as String?;
        orderId ??= map?['order_id'] as String?;
        productId ??= map?['product_id'] as String?;
      } catch (_) {}
    }

    if (deepLink == null || deepLink.isEmpty) {
      if (orderId != null && orderId.isNotEmpty) {
        router.push('${AppRoutes.orderDetail}/$orderId');
        return;
      }
      router.push(AppRoutes.notifications);
      return;
    }

    final uri = Uri.tryParse(deepLink);
    if (uri == null) {
      router.push(AppRoutes.notifications);
      return;
    }

    final path = uri.path;
    final segments = uri.pathSegments;

    if (path.contains('order') && orderId != null && orderId.isNotEmpty) {
      router.push('${AppRoutes.orderDetail}/$orderId');
      return;
    }
    if (path == '/orders' || path.endsWith('/orders')) {
      router.push(AppRoutes.orderHistory);
      return;
    }
    if (path.contains('product') && (productId != null || segments.isNotEmpty)) {
      final id = productId ?? segments.last;
      router.push('${AppRoutes.product}/$id');
      return;
    }
    if (path.contains('publicites')) {
      router.push(AppRoutes.publicites);
      return;
    }
    if (path == '/main' || path.contains('cart')) {
      router.go(AppRoutes.main);
      return;
    }
    if (path.contains('notifications')) {
      router.push(AppRoutes.notifications);
      return;
    }
    if (path.contains('checkout')) {
      router.push(AppRoutes.checkout);
      return;
    }

    router.push(AppRoutes.notifications);
  }
}
