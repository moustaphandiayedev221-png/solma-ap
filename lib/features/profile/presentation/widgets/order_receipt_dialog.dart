import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/currency_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../checkout/data/order_repository.dart';
import '../../../checkout/presentation/providers/order_provider.dart';

/// Dialogue type étiquette guichet : reçu de commande propre et professionnel.
class OrderReceiptDialog extends ConsumerWidget {
  const OrderReceiptDialog({
    super.key,
    required this.orderId,
    required this.userId,
    this.fallbackTotal,
    this.fallbackItemsCount,
  });

  final String orderId;
  final String userId;
  final double? fallbackTotal;
  final int? fallbackItemsCount;

  static Future<void> show(
    BuildContext context, {
    required String orderId,
    required String userId,
    double? total,
    int? itemsCount,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => OrderReceiptDialog(
        orderId: orderId,
        userId: userId,
        fallbackTotal: total?.toDouble(),
        fallbackItemsCount: itemsCount,
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'pending':
        return l10n.orderStatusPending;
      case 'paid':
        return l10n.orderStatusPaid;
      case 'shipped':
        return l10n.orderStatusShipped;
      case 'delivered':
        return l10n.orderStatusDelivered;
      case 'cancelled':
        return l10n.orderStatusCancelled;
      default:
        return status;
    }
  }

  Color _statusColor(ThemeData theme, String status) {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return theme.colorScheme.error;
      case 'shipped':
        return Colors.blue;
      case 'paid':
        return Colors.orange;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final orderAsync = ref.watch(orderByIdProvider((orderId: orderId, userId: userId)));

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: orderAsync.when(
        data: (order) => _ReceiptContent(
          order: order,
          fallbackTotal: fallbackTotal,
          fallbackItemsCount: fallbackItemsCount,
          orderId: orderId,
          statusLabel: _statusLabel,
          statusColor: _statusColor,
          onViewDetails: () {
            Navigator.of(context).pop();
            context.push('${AppRoutes.orderDetail}/$orderId');
          },
        ),
        loading: () => _ReceiptSkeleton(theme: theme, loadingText: l10n.loading),
        error: (error, stackTrace) => _ReceiptContent(
          order: null,
          fallbackTotal: fallbackTotal,
          fallbackItemsCount: fallbackItemsCount,
          orderId: orderId,
          statusLabel: _statusLabel,
          statusColor: _statusColor,
          onViewDetails: () {
            Navigator.of(context).pop();
            context.push('${AppRoutes.orderDetail}/$orderId');
          },
        ),
      ),
    );
  }
}

class _ReceiptContent extends ConsumerWidget {
  const _ReceiptContent({
    required this.order,
    required this.fallbackTotal,
    required this.fallbackItemsCount,
    required this.orderId,
    required this.statusLabel,
    required this.statusColor,
    required this.onViewDetails,
  });

  final OrderModel? order;
  final double? fallbackTotal;
  final int? fallbackItemsCount;
  final String orderId;
  final String Function(AppLocalizations, String) statusLabel;
  final Color Function(ThemeData, String) statusColor;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final formatter = ref.watch(currencyFormatterProvider);
    final isDark = theme.brightness == Brightness.dark;

    final shortId = orderId.length >= 8 ? orderId.substring(0, 8) : orderId;
    final total = order?.total ?? fallbackTotal ?? 0.0;
    final itemCount = order?.items.fold<int>(0, (s, i) => s + i.quantity) ??
        fallbackItemsCount ??
        0;
    final dateStr = order != null
        ? DateFormat('dd/MM/yyyy HH:mm', l10n.localeName).format(order!.createdAt)
        : '';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.dialog(context),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // En-tête type ticket
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : theme.colorScheme.primary.withValues(alpha: 0.08),
            ),
            child: Column(
              children: [
                Text(
                  'COLWAYS',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.orderConfirmed,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Ligne pointillée décorative
          _DashedDivider(theme: theme),

          // Contenu du reçu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // N° commande + statut
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.orderNumber(shortId),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (order != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor(theme, order!.status)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel(l10n, order!.status),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: statusColor(theme, order!.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                if (dateStr.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Liste des articles (si disponible)
                if (order != null && order!.items.isNotEmpty) ...[
                  _DashedDivider(theme: theme, short: true),
                  const SizedBox(height: 12),
                  ...order!.items.map((item) {
                    final subtotal = item.price * item.quantity;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${l10n.quantity(item.quantity)} × ${formatter.format(item.price)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatter.format(subtotal),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  _DashedDivider(theme: theme, short: true),
                  const SizedBox(height: 12),
                ] else ...[
                  Text(
                    l10n.itemsCount(itemCount),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Total
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.total,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        formatter.format(total),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                _DashedDivider(theme: theme),

                Text(
                  l10n.orderReceiptThankYou,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 20),

                // Bouton voir détails
                if (order != null)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onViewDetails,
                      icon: const Icon(Icons.receipt_long_outlined, size: 20),
                      label: Text(l10n.orderReceiptSeeDetails),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onViewDetails,
                      child: Text(l10n.cancel),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({required this.theme, this.short = false});

  final ThemeData theme;
  final bool short;

  @override
  Widget build(BuildContext context) {
    final color = theme.colorScheme.outlineVariant.withValues(alpha: 0.6);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: short ? 8 : 0),
      child: CustomPaint(
        size: Size(short ? 200 : double.infinity, 1),
        painter: _DashedLinePainter(color: color),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashWidth = 6;
    const dashSpace = 4;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReceiptSkeleton extends StatelessWidget {
  const _ReceiptSkeleton({required this.theme, required this.loadingText});

  final ThemeData theme;
  final String loadingText;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              loadingText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
