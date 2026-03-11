import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../notifications/data/notification_preferences_repository.dart';
import '../../../../core/responsive/responsive_module.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/widgets/error_retry_widget.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/data/notification_model.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../widgets/order_receipt_dialog.dart';
import '../widgets/promo_notification_dialog.dart';

/// Index de l'onglet de filtre : 0 = Toutes, 1 = Commandes, 2 = Publicité, 3 = Système
final notificationTabIndexProvider = StateProvider<int>((ref) => 0);

/// Groupe de notifications par période (Aujourd'hui, Hier, etc.)
enum _NotificationGroup {
  today,
  yesterday,
  thisWeek,
  older,
}

_NotificationGroup _groupFor(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final notifDay = DateTime(date.year, date.month, date.day);
  final diff = today.difference(notifDay).inDays;
  if (diff == 0) return _NotificationGroup.today;
  if (diff == 1) return _NotificationGroup.yesterday;
  if (diff < 7) return _NotificationGroup.thisWeek;
  return _NotificationGroup.older;
}

List<NotificationModel> _filterByTab(List<NotificationModel> list, int tabIndex) {
  if (tabIndex == 0) return list;
  if (tabIndex == 1) return list.where((n) => n.notificationType == 'order').toList();
  if (tabIndex == 2) return list.where((n) => n.notificationType == 'promo').toList();
  if (tabIndex == 3) return list.where((n) => n.notificationType == 'system').toList();
  return list;
}

/// Page Notifications : design premium, regroupement par période, « Tout marquer comme lu », empty state.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final r = context.responsive;
    final prefsAsync = ref.watch(notificationPreferencesProvider);
    final pushOn = prefsAsync.valueOrNull?.pushEnabled ?? true;
    final promoOn = prefsAsync.valueOrNull?.promoEnabled ?? false;
    final notificationsAsync = ref.watch(myNotificationsProvider);
    final user = ref.watch(currentUserProvider);
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.notifications,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: theme.colorScheme.surface,
        actions: [
          notificationsAsync.when(
            data: (list) {
              final unreadIds = list.where((n) => !n.isRead).map((n) => n.id).toList();
              if (unreadIds.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: l10n.markAllAsRead,
                icon: const Icon(Icons.done_all_rounded),
                onPressed: () async {
                  if (user == null) return;
                  try {
                    await ref.read(notificationsRepositoryProvider).markAllAsRead(user.id, unreadIds);
                    ref.invalidate(myNotificationsProvider);
                  } catch (e) {
                    if (!context.mounted) return;
                    AppToast.show(context, message: l10n.errorGeneric, isError: true);
                  }
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myNotificationsProvider);
          await ref.read(myNotificationsProvider.future);
        },
        child: ListView(
          padding: EdgeInsets.fromLTRB(r.horizontalPadding, 8, r.horizontalPadding, r.verticalPadding + 24),
          children: [
            _NotificationTabBar(l10n: l10n),
            const SizedBox(height: 20),
            Text(
              l10n.settings,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),
            SoftCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.notifications_active_outlined,
                    title: l10n.pushNotifications,
                    subtitle: l10n.ordersAndReminders,
                    value: pushOn,
                    onChanged: (v) => ref.read(notificationPreferencesProvider.notifier).setPushEnabled(v),
                  ),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  _SettingsRow(
                    icon: Icons.local_offer_outlined,
                    title: l10n.offersAndPromos,
                    subtitle: l10n.discountsAndNew,
                    value: promoOn,
                    onChanged: (v) => ref.read(notificationPreferencesProvider.notifier).setPromoEnabled(v),
                  ),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  _QuietHoursRow(
                    prefs: prefsAsync.valueOrNull,
                    onTap: () => _showQuietHoursDialog(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            notificationsAsync.when(
              data: (list) {
                if (user == null) {
                  return _EmptyState(
                    icon: Icons.notifications_off_outlined,
                    title: l10n.notifications,
                    subtitle: l10n.signInToSeeNotifications,
                  );
                }
                final tabIndex = ref.watch(notificationTabIndexProvider);
                final filtered = _filterByTab(list, tabIndex);
                if (filtered.isEmpty) {
                  return _EmptyState(
                    icon: Icons.search_off_rounded,
                    title: l10n.noNotifications,
                    subtitle: tabIndex == 0 ? l10n.noNotificationsSubtitle : l10n.noNotificationsFilterSubtitle,
                  );
                }
                final grouped = <_NotificationGroup, List<NotificationModel>>{
                  _NotificationGroup.today: [],
                  _NotificationGroup.yesterday: [],
                  _NotificationGroup.thisWeek: [],
                  _NotificationGroup.older: [],
                };
                for (final n in filtered) {
                  grouped[_groupFor(n.createdAt)]!.add(n);
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      l10n.notificationsToday,
                      grouped[_NotificationGroup.today]!,
                      timeFormat,
                      dateFormat,
                      ref,
                      user.id,
                    ),
                    _buildSection(
                      context,
                      l10n.notificationsYesterday,
                      grouped[_NotificationGroup.yesterday]!,
                      timeFormat,
                      dateFormat,
                      ref,
                      user.id,
                    ),
                    _buildSection(
                      context,
                      l10n.notificationsThisWeek,
                      grouped[_NotificationGroup.thisWeek]!,
                      timeFormat,
                      dateFormat,
                      ref,
                      user.id,
                    ),
                    _buildSection(
                      context,
                      l10n.notificationsOlder,
                      grouped[_NotificationGroup.older]!,
                      timeFormat,
                      dateFormat,
                      ref,
                      user.id,
                    ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: AppSectionLoader(minHeight: 120),
              ),
              error: (err, _) => SizedBox(
                height: 200,
                child: ErrorRetryWidget(
                  error: err,
                  onRetry: () => ref.invalidate(myNotificationsProvider),
                  compact: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String sectionTitle,
    List<NotificationModel> items,
    DateFormat timeFormat,
    DateFormat dateFormat,
    WidgetRef ref,
    String userId,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  sectionTitle,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          ...items.map(
            (n) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: _NotificationCard(
                notification: n,
                timeFormat: timeFormat,
                dateFormat: dateFormat,
                userId: userId,
                onTap: () async {
                  try {
                    await ref.read(notificationsRepositoryProvider).markAsRead(userId, n.id);
                    ref.invalidate(myNotificationsProvider);
                  } catch (e) {
                    if (!context.mounted) return;
                    AppToast.show(context, message: AppLocalizations.of(context)!.errorGeneric, isError: true);
                  }
                  if (!context.mounted) return;
                  if (n.notificationType == 'order') {
                    final orderId = n.data['order_id'] as String?;
                    if (orderId != null) {
                      final total = n.data['total'];
                      final itemsCount = n.data['items_count'];
                      OrderReceiptDialog.show(
                        context,
                        orderId: orderId,
                        userId: userId,
                        total: total is num ? (total).toDouble() : null,
                        itemsCount: itemsCount is int
                            ? itemsCount
                            : (itemsCount is num ? (itemsCount).toInt() : null),
                      );
                      return;
                    }
                  }
                  // Toutes les autres notifications (promo, système, ou sans type) : afficher le contenu
                  PromoNotificationDialog.show(context, n);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTabBar extends ConsumerWidget {
  const _NotificationTabBar({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selected = ref.watch(notificationTabIndexProvider);
    final labels = [
      l10n.notificationsTabAll,
      l10n.notificationsTabOrders,
      l10n.notificationsTabPromo,
      l10n.notificationsTabSystem,
    ];
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(4, (index) {
          final isSelected = selected == index;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Material(
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: () => ref.read(notificationTabIndexProvider.notifier).state = index,
                  borderRadius: BorderRadius.circular(18),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        labels[index],
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: theme.colorScheme.primary.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuietHoursRow extends StatelessWidget {
  const _QuietHoursRow({
    required this.prefs,
    required this.onTap,
  });

  final NotificationPreferences? prefs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasQuiet = prefs?.quietHoursStart != null && prefs?.quietHoursEnd != null;
    final subtitle = hasQuiet
        ? '${prefs!.quietHoursStart} - ${prefs!.quietHoursEnd}'
        : 'Ne pas déranger la nuit';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(Icons.nightlight_outlined, color: theme.colorScheme.primary, size: 22),
      title: Text(
        'Heures silencieuses',
        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

void _showQuietHoursDialog(BuildContext context, WidgetRef ref) {
  final prefs = ref.read(notificationPreferencesProvider).valueOrNull;
  String? start = prefs?.quietHoursStart ?? '22:00';
  String? end = prefs?.quietHoursEnd ?? '08:00';
  showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('Heures silencieuses'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Aucune notification entre ces heures'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: start ?? '22:00',
                      decoration: const InputDecoration(labelText: 'De'),
                      items: List.generate(24, (i) => '${i.toString().padLeft(2, '0')}:00')
                          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) => setState(() => start = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: end ?? '08:00',
                      decoration: const InputDecoration(labelText: 'À'),
                      items: List.generate(24, (i) => '${i.toString().padLeft(2, '0')}:00')
                          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) => setState(() => end = v),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(notificationPreferencesProvider.notifier).setQuietHours(null, null);
                Navigator.of(ctx).pop();
              },
              child: const Text('Désactiver'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(notificationPreferencesProvider.notifier).setQuietHours(start, end);
                Navigator.of(ctx).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: theme.colorScheme.primary, size: 22),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        subtitle: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.timeFormat,
    required this.dateFormat,
    required this.userId,
    required this.onTap,
  });

  final NotificationModel notification;
  final DateFormat timeFormat;
  final DateFormat dateFormat;
  final String userId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = notification.isRead;
    final bodyPreview = notification.body.length > 80
        ? '${notification.body.substring(0, 80)}…'
        : notification.body;

    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            width: 4,
            color: isRead ? Colors.transparent : theme.colorScheme.primary,
          ),
        ),
        boxShadow: AppShadows.card(context),
      ),
      child: Material(
        color: cardColor,
        elevation: 0,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isRead
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isRead ? Icons.notifications_none_rounded : Icons.notifications_rounded,
                    size: 22,
                    color: isRead
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          notification.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bodyPreview,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dateFormat.format(notification.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRead)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
