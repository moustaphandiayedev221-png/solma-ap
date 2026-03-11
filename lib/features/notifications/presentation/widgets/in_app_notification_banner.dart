import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../data/notification_deep_link_handler.dart';
import '../../data/notification_model.dart';
import '../providers/notifications_provider.dart';

/// Bandeau in-app type Amazon affiché en haut quand une notification arrive.
class InAppNotificationBanner extends ConsumerStatefulWidget {
  const InAppNotificationBanner({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<InAppNotificationBanner> createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends ConsumerState<InAppNotificationBanner> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final lastNotif = ref.watch(lastReceivedNotificationProvider);

    return Stack(
      children: [
        widget.child,
        if (lastNotif != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _BannerCard(
              notification: lastNotif,
              onTap: () {
                ref.read(lastReceivedNotificationProvider.notifier).state = null;
                NotificationDeepLinkHandler.navigate(
                  ref.read(goRouterProvider),
                  lastNotif.toTapPayload(),
                );
              },
              onDismiss: () {
                ref.read(lastReceivedNotificationProvider.notifier).state = null;
              },
            ),
          ),
      ],
    );
  }
}

class _BannerCard extends StatefulWidget {
  const _BannerCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  State<_BannerCard> createState() => _BannerCardState();
}

class _BannerCardState extends State<_BannerCard> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeTop = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, safeTop + 8, 12, 0),
      child: Material(
        elevation: 8,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.notification.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.notification.body.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.notification.body,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onDismiss,
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
