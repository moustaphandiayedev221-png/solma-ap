import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/utils/app_logger.dart';

String _platformName() {
  if (kIsWeb) return 'web';
  return 'mobile'; // ios/android selon build
}

/// Enregistre le token FCM dans Supabase pour recevoir les push en arrière-plan.
class FcmTokenRepository {
  FcmTokenRepository([SupabaseClient? client]) : _client = client ?? supabaseClient;

  final SupabaseClient _client;
  static const String _table = 'user_fcm_tokens';

  Future<String?> getToken() async {
    if (kIsWeb) return null;
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      return null;
    }
    return messaging.getToken();
  }

  Future<void> saveToken(String userId, String token) async {
    final platform = _platformName();
    await _client.from(_table).upsert({
      'user_id': userId,
      'token': token,
      'platform': platform,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,platform');
  }

  Future<void> saveTokenIfPossible(String userId) async {
    try {
      final token = await getToken();
      if (token != null) await saveToken(userId, token);
    } catch (e, st) {
      // Erreur réseau attendue hors ligne — ignorer silencieusement
      final msg = e.toString();
      final isNetworkError = msg.contains('SocketException') ||
          msg.contains('ClientException') ||
          msg.contains('Failed host lookup');
      if (!isNetworkError) {
        AppLogger.error('FcmTokenRepository', 'saveTokenIfPossible failed', e, st);
      }
    }
  }

  Future<void> removeToken(String userId) async {
    await _client.from(_table).delete().eq('user_id', userId);
  }
}
