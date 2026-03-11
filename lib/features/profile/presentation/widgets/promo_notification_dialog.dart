import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_shadows.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../notifications/data/notification_deep_link_handler.dart';
import '../../../notifications/data/notification_model.dart';

/// Dialogue moderne et élégant pour afficher le contenu des notifications publicitaires.
class PromoNotificationDialog extends StatelessWidget {
  const PromoNotificationDialog({
    super.key,
    required this.notification,
  });

  final NotificationModel notification;

  static Future<void> show(BuildContext context, NotificationModel notification) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => PromoNotificationDialog(notification: notification),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final imageUrl = notification.data['image_url'] as String?;
    final linkUrl = notification.data['link'] as String? ?? notification.data['url'] as String?;
    final deepLink = notification.effectiveDeepLink;
    final hasExternalLink = linkUrl != null && linkUrl.isNotEmpty;
    final hasInAppLink = deepLink != null && deepLink.isNotEmpty && (deepLink.startsWith('/') || !deepLink.contains(':'));
    final hasAnyLink = hasExternalLink || hasInAppLink;
    final dateStr = DateFormat('dd MMM yyyy • HH:mm', l10n.localeName).format(notification.createdAt);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        color: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.card(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // En-tête avec dégradé
              Container(
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            theme.colorScheme.primary.withValues(alpha: 0.4),
                            theme.colorScheme.primary.withValues(alpha: 0.2),
                          ]
                        : [
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            theme.colorScheme.primary.withValues(alpha: 0.06),
                          ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.chip(context),
                      ),
                      child: Icon(
                        Icons.local_offer_rounded,
                        size: 36,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      notification.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Image optionnelle
              if (imageUrl != null && imageUrl.isNotEmpty) ...[
                ClipRect(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => const SizedBox.shrink(),
                  ),
                ),
              ],

              // Contenu — style message / bulle de chat
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_rounded,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(
                                alpha: isDark ? 0.3 : 0.4,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(18),
                              ),
                              boxShadow: AppShadows.chip(context),
                            ),
                            child: Text(
                              notification.body,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.55,
                                letterSpacing: 0.15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Boutons
                    if (hasAnyLink)
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                if (hasExternalLink) {
                                  final uri = Uri.tryParse(linkUrl);
                                  if (uri != null && await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                } else if (hasInAppLink) {
                                  final router = GoRouter.of(context);
                                  NotificationDeepLinkHandler.navigate(
                                    router,
                                    notification.toTapPayload(),
                                  );
                                }
                              },
                              icon: Icon(
                                hasExternalLink ? Icons.open_in_new_rounded : Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                              label: Text(
                                hasExternalLink ? l10n.bannerDiscover : l10n.orderReceiptSeeDetails,
                              ),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(l10n.close),
                            ),
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(l10n.close),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
