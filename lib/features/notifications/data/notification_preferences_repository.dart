import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';

const String _prefsKeyPush = 'notif_pref_push_enabled';
const String _prefsKeyPromo = 'notif_pref_promo_enabled';
const String _prefsKeyQuietStart = 'notif_pref_quiet_start'; // HH:mm
const String _prefsKeyQuietEnd = 'notif_pref_quiet_end';

/// Préférences de notifications (persistées local + Supabase)
class NotificationPreferences {
  const NotificationPreferences({
    this.pushEnabled = true,
    this.promoEnabled = false,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  final bool pushEnabled;
  final bool promoEnabled;
  final String? quietHoursStart; // "22:00"
  final String? quietHoursEnd;   // "08:00"

  /// Est-on en période silencieuse ?
  bool get isQuietTime {
    if (quietHoursStart == null || quietHoursEnd == null) return false;
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final start = _parseTime(quietHoursStart!);
    final end = _parseTime(quietHoursEnd!);
    if (start == null || end == null) return false;
    if (start <= end) {
      return nowMinutes >= start && nowMinutes < end;
    }
    return nowMinutes >= start || nowMinutes < end;
  }

  static int? _parseTime(String s) {
    final parts = s.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }
}

class NotificationPreferencesRepository {
  NotificationPreferencesRepository([SupabaseClient? client])
      : _client = client ?? supabaseClient {
    _prefsFuture = SharedPreferences.getInstance();
  }

  final SupabaseClient _client;
  late final Future<SharedPreferences> _prefsFuture;

  static const String _table = 'user_notification_preferences';

  /// Charge les préférences (Supabase si connecté, sinon local)
  Future<NotificationPreferences> getPreferences(String? userId) async {
    final prefs = await _prefsFuture;
    if (userId != null) {
      try {
        final res = await _client
            .from(_table)
            .select()
            .eq('user_id', userId)
            .maybeSingle();
        if (res != null) {
          return NotificationPreferences(
            pushEnabled: res['push_enabled'] as bool? ?? true,
            promoEnabled: res['promo_enabled'] as bool? ?? false,
            quietHoursStart: res['quiet_hours_start'] as String?,
            quietHoursEnd: res['quiet_hours_end'] as String?,
          );
        }
      } catch (_) {}
    }
    return NotificationPreferences(
      pushEnabled: prefs.getBool(_prefsKeyPush) ?? true,
      promoEnabled: prefs.getBool(_prefsKeyPromo) ?? false,
      quietHoursStart: prefs.getString(_prefsKeyQuietStart),
      quietHoursEnd: prefs.getString(_prefsKeyQuietEnd),
    );
  }

  /// Sauvegarde les préférences (local + Supabase)
  Future<void> savePreferences(
    String? userId,
    NotificationPreferences prefs,
  ) async {
    final p = await _prefsFuture;
    await p.setBool(_prefsKeyPush, prefs.pushEnabled);
    await p.setBool(_prefsKeyPromo, prefs.promoEnabled);
    if (prefs.quietHoursStart != null) {
      await p.setString(_prefsKeyQuietStart, prefs.quietHoursStart!);
    } else {
      await p.remove(_prefsKeyQuietStart);
    }
    if (prefs.quietHoursEnd != null) {
      await p.setString(_prefsKeyQuietEnd, prefs.quietHoursEnd!);
    } else {
      await p.remove(_prefsKeyQuietEnd);
    }

    if (userId != null) {
      try {
        await _client.from(_table).upsert({
          'user_id': userId,
          'push_enabled': prefs.pushEnabled,
          'promo_enabled': prefs.promoEnabled,
          'quiet_hours_start': prefs.quietHoursStart,
          'quiet_hours_end': prefs.quietHoursEnd,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'user_id');
      } catch (_) {}
    }
  }
}
