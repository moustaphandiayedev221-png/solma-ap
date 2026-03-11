import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

import 'notification_model.dart';
import '../../../gen_l10n/app_localizations.dart';

/// Canaux Android pour types de notifications (priorité, son distinct)
class NotificationChannels {
  static const String orders = 'colways_orders';
  static const String promos = 'colways_promos';
  static const String system = 'colways_notifications';
}

/// Affiche des notifications système (foreground). En background, FCM s'en charge.
class LocalNotificationService {
  LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static final StreamController<String> _tapController =
      StreamController<String>.broadcast();

  static Stream<String> get onNotificationTap => _tapController.stream;

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final locale = PlatformDispatcher.instance.locale;
      final l10n = lookupAppLocalizations(locale);
      final channelName = l10n.notificationChannelName;
      final channelDesc = l10n.notificationChannelDesc;

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationChannels.orders,
          'Commandes',
          description: 'Notifications de commandes et livraisons',
          importance: Importance.high,
          playSound: true,
          showBadge: true,
        ),
      );
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationChannels.promos,
          'Offres et promos',
          description: 'Promotions et codes promo',
          importance: Importance.defaultImportance,
          playSound: true,
          showBadge: true,
        ),
      );
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          NotificationChannels.system,
          channelName,
          description: channelDesc,
          importance: Importance.high,
          playSound: true,
          showBadge: true,
        ),
      );
    }

    _initialized = true;
  }

  static void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      _tapController.add(payload);
    }
  }

  static String _channelForCategory(String? category) {
    if (category == null) return NotificationChannels.system;
    final c = category.toLowerCase();
    if (c.contains('order') || c.contains('shipped') || c.contains('delivered')) {
      return NotificationChannels.orders;
    }
    if (c.contains('promo') || c.contains('cart')) return NotificationChannels.promos;
    return NotificationChannels.system;
  }

  static Future<void> showNotification(NotificationModel notification) async {
    if (!_initialized) return;

    final id = (notification.id.hashCode & 0x7FFFFFFF) == 0
        ? 1
        : (notification.id.hashCode & 0x7FFFFFFF);

    final channelId = _channelForCategory(notification.category);

    // Note: BigPictureStyle pour image_url nécessite un téléchargement préalable (FilePathAndroidBitmap)
    final androidDetails = AndroidNotificationDetails(
        channelId,
        channelId == NotificationChannels.orders ? 'Commandes' : 'Notifications',
        channelDescription: 'Notifications SOLMA',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    final payload = notification.toTapPayload();

    await _plugin.show(
      id,
      notification.title,
      notification.body.isEmpty ? null : notification.body,
      details,
      payload: payload,
    );
  }

  static Future<bool> handleLaunchFromNotification() async {
    if (!_initialized) return false;
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      final payload = launch!.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        _tapController.add(payload);
      }
      return true;
    }
    return false;
  }
}
