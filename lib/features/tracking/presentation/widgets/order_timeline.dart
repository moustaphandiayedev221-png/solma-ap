import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../data/tracking_model.dart';
import '../providers/tracking_provider.dart';

/// Timeline visuelle du suivi de commande.
class OrderTimeline extends ConsumerWidget {
  const OrderTimeline({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final trackingAsync = ref.watch(trackingEventsProvider(orderId));

    return trackingAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              l10n.noTrackingInfo,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        // Les étapes définies dans l'ordre
        final allSteps = TrackingStatus.values;
        // Trouver la dernière étape atteinte
        final reachedStatuses = events.map((e) => e.status).toSet();
        final eventsByStatus = <String, TrackingModel>{};
        for (final event in events) {
          eventsByStatus[event.status] = event;
        }

        return Column(
          children: List.generate(allSteps.length, (index) {
            final step = allSteps[index];
            final isReached = reachedStatuses.contains(step.value);
            final event = eventsByStatus[step.value];
            final isLast = index == allSteps.length - 1;

            return _TimelineStep(
              title: _statusTitle(l10n, step),
              description: event?.description,
              location: event?.location,
              dateTime: event?.createdAt,
              icon: _statusIcon(step),
              isReached: isReached,
              isLast: isLast,
              isCurrent: isReached &&
                  (index == allSteps.length - 1 ||
                      !reachedStatuses
                          .contains(allSteps[index + 1].value)),
            );
          }),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  String _statusTitle(AppLocalizations l10n, TrackingStatus status) {
    switch (status) {
      case TrackingStatus.paid:
        return l10n.trackingOrdered;
      case TrackingStatus.confirmed:
        return l10n.trackingConfirmed;
      case TrackingStatus.preparing:
        return l10n.trackingPreparing;
      case TrackingStatus.shipped:
        return l10n.trackingShipped;
      case TrackingStatus.delivering:
        return l10n.trackingInDelivery;
      case TrackingStatus.delivered:
        return l10n.trackingDelivered;
    }
  }

  IconData _statusIcon(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.paid:
        return Icons.receipt_long_rounded;
      case TrackingStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case TrackingStatus.preparing:
        return Icons.inventory_2_outlined;
      case TrackingStatus.shipped:
        return Icons.local_shipping_outlined;
      case TrackingStatus.delivering:
        return Icons.delivery_dining_rounded;
      case TrackingStatus.delivered:
        return Icons.done_all_rounded;
    }
  }
}

/// Tuile individuelle d'une étape de la timeline.
class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    this.description,
    this.location,
    this.dateTime,
    required this.icon,
    required this.isReached,
    required this.isLast,
    required this.isCurrent,
  });

  final String title;
  final String? description;
  final String? location;
  final DateTime? dateTime;
  final IconData icon;
  final bool isReached;
  final bool isLast;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = dateTime != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(dateTime!)
        : null;

    final activeColor =
        isCurrent ? theme.colorScheme.primary : Colors.green;
    final inactiveColor =
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colonne timeline (cercle + ligne)
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Cercle avec icône
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isReached
                        ? activeColor.withValues(alpha: 0.15)
                        : inactiveColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: isReached ? activeColor : inactiveColor,
                      width: isCurrent ? 2 : 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isReached ? activeColor : inactiveColor,
                  ),
                ),
                // Ligne verticale
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isReached
                          ? activeColor.withValues(alpha: 0.4)
                          : inactiveColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Contenu
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                      color: isReached
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (location != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (dateStr != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
