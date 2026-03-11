import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/notification_model.dart';
import '../../data/notification_preferences_repository.dart';
import '../../data/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository();
});

final notificationPreferencesRepositoryProvider =
    Provider<NotificationPreferencesRepository>((ref) {
  return NotificationPreferencesRepository();
});

/// Préférences persistées (chargées depuis Supabase ou local)
class NotificationPreferencesNotifier
    extends AutoDisposeAsyncNotifier<NotificationPreferences> {
  @override
  Future<NotificationPreferences> build() async {
    final user = ref.watch(currentUserProvider);
    final repo = ref.watch(notificationPreferencesRepositoryProvider);
    return repo.getPreferences(user?.id);
  }

  Future<void> setPushEnabled(bool v) async {
    state = const AsyncValue.loading();
    final user = ref.read(currentUserProvider);
    final repo = ref.read(notificationPreferencesRepositoryProvider);
    final current = state.valueOrNull ?? const NotificationPreferences();
    final next = NotificationPreferences(
      pushEnabled: v,
      promoEnabled: current.promoEnabled,
      quietHoursStart: current.quietHoursStart,
      quietHoursEnd: current.quietHoursEnd,
    );
    await repo.savePreferences(user?.id, next);
    state = AsyncValue.data(next);
  }

  Future<void> setPromoEnabled(bool v) async {
    state = const AsyncValue.loading();
    final user = ref.read(currentUserProvider);
    final repo = ref.read(notificationPreferencesRepositoryProvider);
    final current = state.valueOrNull ?? const NotificationPreferences();
    final next = NotificationPreferences(
      pushEnabled: current.pushEnabled,
      promoEnabled: v,
      quietHoursStart: current.quietHoursStart,
      quietHoursEnd: current.quietHoursEnd,
    );
    await repo.savePreferences(user?.id, next);
    state = AsyncValue.data(next);
  }

  Future<void> setQuietHours(String? start, String? end) async {
    state = const AsyncValue.loading();
    final user = ref.read(currentUserProvider);
    final repo = ref.read(notificationPreferencesRepositoryProvider);
    final current = state.valueOrNull ?? const NotificationPreferences();
    final next = NotificationPreferences(
      pushEnabled: current.pushEnabled,
      promoEnabled: current.promoEnabled,
      quietHoursStart: start,
      quietHoursEnd: end,
    );
    await repo.savePreferences(user?.id, next);
    state = AsyncValue.data(next);
  }
}

final notificationPreferencesProvider = AsyncNotifierProvider.autoDispose<
    NotificationPreferencesNotifier, NotificationPreferences>(
  NotificationPreferencesNotifier.new,
);

final myNotificationsProvider =
    FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(notificationsRepositoryProvider);
  return repo.getMyNotificationsSimple(user.id);
});

/// Nombre de notifications non lues (pour badge)
final unreadNotificationsCountProvider =
    Provider.autoDispose<AsyncValue<int>>((ref) {
  return ref.watch(myNotificationsProvider).when(
        data: (list) => AsyncValue.data(
            list.where((n) => !n.isRead).length),
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      );
});

/// Dernière notification reçue en temps réel (pour afficher le bandeau overlay).
final lastReceivedNotificationProvider =
    StateProvider<NotificationModel?>((ref) => null);

/// Supprimer le bandeau pour les confirmations de commande qu'on vient de créer
/// (évite doublon avec un éventuel toast). Activé par CheckoutScreen avant notifyOrderPlaced.
final suppressOrderConfirmationBannerProvider =
    StateProvider<bool>((ref) => false);
