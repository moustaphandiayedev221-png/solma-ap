import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

/// Modèle notification reçue dans l'app SOLMA (payload riche type Amazon)
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.data = const {},
    required this.targetType,
    this.targetUserId,
    required this.createdAt,
    this.readAt,
    this.deepLink,
    this.imageUrl,
    this.category,
    this.priority = 'normal',
    this.expiresAt,
  });

  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String targetType;
  final String? targetUserId;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? deepLink;
  final String? imageUrl;
  final String? category;
  final String priority;
  final DateTime? expiresAt;

  bool get isRead => readAt != null;

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Deep link effectif : colonne ou data['deep_link']
  String? get effectiveDeepLink => deepLink ?? data['deep_link'] as String?;

  /// Type pour filtrer onglets : order, promo, system
  String? get notificationType {
    final c = category ?? data['category'] as String? ?? data['type'] as String?;
    if (c == null) return null;
    final lower = c.toString().toLowerCase();
    if (lower.contains('order') || lower.contains('commande') || lower.contains('shipped') || lower.contains('delivered')) return 'order';
    if (lower.contains('promo') || lower.contains('ad') || lower.contains('publicité') || lower.contains('cart')) return 'promo';
    if (lower.contains('system')) return 'system';
    return lower;
  }

  /// Payload JSON pour navigation au tap (cold start)
  String toTapPayload() {
    return jsonEncode({
      'id': id,
      'deep_link': effectiveDeepLink,
      'type': notificationType,
      'order_id': data['order_id'],
      'product_id': data['product_id'],
      'promo_code': data['promo_code'],
    });
  }

  static NotificationModel? fromTapPayload(String payload) {
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final id = map['id'] as String? ?? '';
      final deepLink = map['deep_link'] as String?;
      return NotificationModel(
        id: id,
        title: '',
        body: '',
        data: map,
        targetType: 'all',
        targetUserId: null,
        createdAt: DateTime.now(),
        readAt: null,
        deepLink: deepLink,
      );
    } catch (_) {
      return null;
    }
  }

  /// Créé à partir d'un message FCM (push reçu en premier plan).
  factory NotificationModel.fromRemoteMessage(RemoteMessage message) {
    final id = message.messageId ?? 'fcm-${DateTime.now().millisecondsSinceEpoch}';
    final title = message.notification?.title ?? message.data['title'] as String? ?? '';
    final body = message.notification?.body ?? message.data['body'] as String? ?? '';
    final data = Map<String, dynamic>.from(message.data);
    final imageUrl = message.notification?.android?.imageUrl ?? message.data['image_url'] as String?;
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      data: data,
      targetType: 'all',
      targetUserId: null,
      createdAt: DateTime.now(),
      readAt: null,
      deepLink: data['deep_link'] as String?,
      imageUrl: imageUrl,
      category: data['category'] as String?,
      priority: data['priority'] as String? ?? 'normal',
      expiresAt: data['expires_at'] != null ? DateTime.tryParse(data['expires_at'] as String) : null,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : {},
      targetType: json['target_type'] as String,
      targetUserId: json['target_user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'] as String)
          : null,
      deepLink: json['deep_link'] as String?,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
      priority: json['priority'] as String? ?? 'normal',
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'] as String) : null,
    );
  }
}
