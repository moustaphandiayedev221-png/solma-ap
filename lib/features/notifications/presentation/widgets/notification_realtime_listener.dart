import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/fcm_token_repository.dart';
import '../../data/local_notification_service.dart';
import '../../data/notification_deep_link_handler.dart';
import '../../data/notification_model.dart';
import '../../data/notifications_repository.dart';
import '../providers/notifications_provider.dart';

/// Écoute FCM + Realtime, affiche les notifications, gère le deep linking au tap.
class NotificationRealtimeListener extends ConsumerStatefulWidget {
  const NotificationRealtimeListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<NotificationRealtimeListener> createState() =>
      _NotificationRealtimeListenerState();
}

class _NotificationRealtimeListenerState
    extends ConsumerState<NotificationRealtimeListener> {
  bool _subscribed = false;
  StreamSubscription<String>? _tapSubscription;
  NotificationsRepository? _repo;
  String? _subscribedUserId;

  bool _shouldShowNotification(NotificationModel n) {
    final prefs = ref.read(notificationPreferencesProvider).valueOrNull;
    if (prefs == null) return true;
    if (!prefs.pushEnabled) return false;
    if (prefs.isQuietTime) return false;
    final type = n.notificationType;
    if (type == 'promo' && !prefs.promoEnabled) return false;
    return true;
  }

  /// Ne pas afficher le bandeau pour les confirmations de commande qu'on vient
  /// de créer (évite doublon toast + bandeau).
  bool _shouldSkipBanner(NotificationModel n) {
    if (n.notificationType != 'order') return false;
    return ref.read(suppressOrderConfirmationBannerProvider);
  }

  void _onNotificationTap(String payload) {
    if (!mounted) return;
    final router = ref.read(goRouterProvider);
    NotificationDeepLinkHandler.navigate(router, payload);
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!mounted) return;
      final n = NotificationModel.fromRemoteMessage(message);
      ref.invalidate(myNotificationsProvider);
      if (!_shouldSkipBanner(n)) {
        ref.read(lastReceivedNotificationProvider.notifier).state = n;
      }
      if (_shouldShowNotification(n)) {
        LocalNotificationService.showNotification(n);
      }
    });
    _tapSubscription =
        LocalNotificationService.onNotificationTap.listen(_onNotificationTap);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocalNotificationService.handleLaunchFromNotification();
    });
  }

  @override
  void dispose() {
    _tapSubscription?.cancel();
    if (_repo != null && _subscribedUserId != null) {
      _repo!.unsubscribe(_subscribedUserId!);
    }
    super.dispose();
  }

  void _subscribe(String userId) {
    if (_subscribed) return;
    _subscribed = true;
    _subscribedUserId = userId;
    _repo = ref.read(notificationsRepositoryProvider);
    FcmTokenRepository().saveTokenIfPossible(userId);
    _repo!.subscribeToNewNotifications(
      userId,
      (NotificationModel n) {
        ref.invalidate(myNotificationsProvider);
        if (!_shouldSkipBanner(n)) {
          ref.read(lastReceivedNotificationProvider.notifier).state = n;
        }
        if (_shouldShowNotification(n)) {
          LocalNotificationService.showNotification(n);
        }
      },
    );
  }

  void _unsubscribe(String? userId) {
    if (!_subscribed) return;
    _subscribed = false;
    _repo?.unsubscribe(userId ?? '');
    _repo = null;
    _subscribedUserId = null;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user != null && !_subscribed) _subscribe(user.id);
    if (user == null && _subscribed) _unsubscribe(user?.id);

    ref.listen(currentUserProvider, (prev, next) {
      if (next != null && !_subscribed) _subscribe(next.id);
      if (next == null && _subscribed) _unsubscribe(prev?.id);
    });

    return widget.child;
  }
}
