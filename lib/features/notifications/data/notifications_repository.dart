import 'package:flutter/material.dart' show Locale;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../gen_l10n/app_localizations.dart';
import 'notification_model.dart';

class NotificationsRepository {
  NotificationsRepository([SupabaseClient? client]) : _client = client ?? supabaseClient;

  final SupabaseClient _client;
  static const String _table = 'notifications';
  static const String _readsTable = 'notification_reads';
  final Map<String, RealtimeChannel> _channels = {};

  /// Notifications visibles par l'utilisateur (broadcast + ciblées), avec statut lu
  Future<List<NotificationModel>> getMyNotifications(String userId) async {
    final res = await _client
        .from(_table)
        .select('''
          *,
          notification_reads!left(read_at)
        ''')
        .or('target_type.eq.all,target_user_id.eq.$userId')
        .order('created_at', ascending: false)
        .limit(100);

    final list = <NotificationModel>[];
    for (final e in res as List) {
      final map = e as Map<String, dynamic>;
      final reads = map['notification_reads'];
      DateTime? readAt;
      if (reads is List && reads.isNotEmpty) {
        final first = reads.first as Map<String, dynamic>?;
        if (first != null && first['read_at'] != null) {
          readAt = DateTime.tryParse(first['read_at'] as String);
        }
      }
      list.add(NotificationModel(
        id: map['id'] as String,
        title: map['title'] as String,
        body: map['body'] as String,
        data: map['data'] is Map<String, dynamic>
            ? map['data'] as Map<String, dynamic>
            : {},
        targetType: map['target_type'] as String,
        targetUserId: map['target_user_id'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
        readAt: readAt,
      ));
    }
    return list;
  }

  /// Version simple sans join : on récupère les notifications puis les reads
  Future<List<NotificationModel>> getMyNotificationsSimple(String userId) async {
    final res = await _client
        .from(_table)
        .select()
        .or('target_type.eq.all,target_user_id.eq.$userId')
        .order('created_at', ascending: false)
        .limit(100);

    final notifications = (res as List)
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final readRes = await _client
        .from(_readsTable)
        .select('notification_id, read_at')
        .eq('user_id', userId);

    final readMap = <String, DateTime>{};
    for (final r in readRes as List) {
      final m = r as Map<String, dynamic>;
      final at = m['read_at'] != null
          ? DateTime.tryParse(m['read_at'] as String)
          : null;
      if (at != null) readMap[m['notification_id'] as String] = at;
    }

    return notifications
        .map((n) => NotificationModel(
              id: n.id,
              title: n.title,
              body: n.body,
              data: n.data,
              targetType: n.targetType,
              targetUserId: n.targetUserId,
              createdAt: n.createdAt,
              readAt: readMap[n.id],
              deepLink: n.deepLink,
              imageUrl: n.imageUrl,
              category: n.category,
              priority: n.priority,
              expiresAt: n.expiresAt,
            ))
        .toList();
  }

  static const String _sendPushFunctionName = 'send-push-notification';

  /// Insère une notification de confirmation de commande pour l'utilisateur et envoie le push.
  /// À appeler après un paiement réussi (côté client). Nécessite la policy "Users can insert own order notification".
  /// [languageCode] : code langue ('fr', 'en') pour les textes localisés. Par défaut 'fr'.
  Future<void> notifyOrderPlaced({
    required String userId,
    required String orderId,
    required double total,
    int itemsCount = 1,
    String languageCode = 'fr',
  }) async {
    final l10n = lookupAppLocalizations(Locale(languageCode));
    final shortId = orderId.length >= 8 ? orderId.substring(0, 8) : orderId;
    final totalStr = total.toStringAsFixed(2);
    final title = l10n.orderConfirmed;
    final body = itemsCount > 1
        ? l10n.orderConfirmedBodyMultiple(shortId, itemsCount, totalStr)
        : l10n.orderConfirmedBodySingle(shortId, totalStr);
    final data = {
      'type': 'order',
      'order_id': orderId,
      'total': total,
      'items_count': itemsCount,
      'deep_link': '/orders',
    };
    await _client.from(_table).insert({
      'title': title,
      'body': body,
      'data': data,
      'target_type': 'user',
      'target_user_id': userId,
      'created_by': userId,
    });
    try {
      await _client.functions.invoke(
        _sendPushFunctionName,
        body: {
          'title': title,
          'body': body,
          'target_type': 'user',
          'target_user_id': userId,
          'data': {'type': 'order', 'order_id': orderId, 'deep_link': '/orders'},
        },
      );
    } catch (e) {
      AppLogger.warn('NotificationsRepository', 'Push failed: $e');
    }
  }

  /// Marque une notification comme lue (persisté en base pour survivre à la déconnexion).
  Future<void> markAsRead(String userId, String notificationId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _client.from(_readsTable).upsert(
      {
        'notification_id': notificationId,
        'user_id': userId,
        'read_at': now,
      },
      onConflict: 'notification_id,user_id',
      ignoreDuplicates: false,
    );
  }

  /// Marque toutes les notifications comme lues pour l'utilisateur.
  Future<void> markAllAsRead(String userId, List<String> notificationIds) async {
    if (notificationIds.isEmpty) return;
    final now = DateTime.now().toUtc().toIso8601String();
    await _client.from(_readsTable).upsert(
      notificationIds
          .map((id) => {
                'notification_id': id,
                'user_id': userId,
                'read_at': now,
              })
          .toList(),
      onConflict: 'notification_id,user_id',
      ignoreDuplicates: false,
    );
  }

  /// Abonnement Realtime : nouvelles notifications
  void subscribeToNewNotifications(
    String userId,
    void Function(NotificationModel notification) onNew,
  ) {
    final channel = _client.channel('notifications:$userId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: _table,
      callback: (payload) {
        final newRecord = payload.newRecord;
        final targetType = newRecord['target_type'] as String?;
        final targetUserId = newRecord['target_user_id'] as String?;
        final isForMe = targetType == 'all' ||
            (targetUserId != null && targetUserId == userId);
        if (!isForMe) return;
        final dataMap = newRecord['data'] is Map<String, dynamic>
            ? newRecord['data'] as Map<String, dynamic>
            : <String, dynamic>{};
        onNew(NotificationModel(
          id: newRecord['id'] as String,
          title: newRecord['title'] as String,
          body: newRecord['body'] as String,
          data: dataMap,
          targetType: targetType ?? 'all',
          targetUserId: targetUserId,
          createdAt: DateTime.parse(newRecord['created_at'] as String),
          readAt: null,
          deepLink: newRecord['deep_link'] as String? ?? dataMap['deep_link'] as String?,
          imageUrl: newRecord['image_url'] as String? ?? dataMap['image_url'] as String?,
          category: newRecord['category'] as String? ?? dataMap['category'] as String?,
          priority: newRecord['priority'] as String? ?? dataMap['priority'] as String? ?? 'normal',
          expiresAt: newRecord['expires_at'] != null
              ? DateTime.tryParse(newRecord['expires_at'] as String)
              : null,
        ));
      },
    ).subscribe();
    _channels[userId] = channel;
  }

  void unsubscribe(String userId) {
    final channel = _channels.remove(userId);
    if (channel != null) {
      _client.removeChannel(channel);
    }
  }
}
