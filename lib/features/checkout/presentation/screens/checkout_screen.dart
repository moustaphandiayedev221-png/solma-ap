import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/error/app_failure.dart';
import '../../../../core/widgets/error_retry_widget.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../main_navigation/providers/main_nav_index_provider.dart';
import '../../../profile/data/profile_repository.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../../core/config/support_config.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/order_repository.dart';
import '../providers/order_provider.dart';
import '../../../profile/data/address_model.dart';
import '../../../profile/presentation/providers/address_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../data/delivery_zone_repository.dart';
import '../providers/delivery_provider.dart';
import '../../../promo/presentation/providers/promo_provider.dart';

const double _bottomBarButtonHeight = 56.0;
const double _bottomBarVerticalPadding = 14.0;
const double _bottomBarHorizontalPadding = 24.0;

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isLoading = false;

  Future<void> _placeOrder() async {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final cartNotifier = ref.read(cartProvider.notifier);
    final itemsAsync = ref.read(cartItemsWithProductsProvider);
    final items = itemsAsync.valueOrNull ?? [];
    if (items.isEmpty) {
      if (!mounted) return;
      AppToast.show(context, message: l10n.noProducts);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final subtotal = items.fold<double>(
        0,
        (sum, line) => sum + line.lineTotal,
      );
      final shipping = await ref.read(shippingAmountProvider.future);
      final promoState = ref.read(promoProvider);
      final discountAmount =
          promoState is PromoApplied ? promoState.discountAmount : 0.0;
      final promoCode =
          promoState is PromoApplied ? promoState.promo.code : null;
      final total =
          (subtotal + shipping - discountAmount).clamp(0.0, double.infinity);
      final orderItems = items
          .map(
            (e) => OrderItemModel(
              productId: e.product.id,
              name: e.product.name,
              price: e.product.price,
              quantity: e.quantity,
            ),
          )
          .toList();
      final defaultAddr = ref.read(defaultAddressProvider);

      // Bloquer la commande si aucune adresse n'est définie
      if (defaultAddr == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        AppToast.show(context, message: l10n.noAddresses);
        return;
      }

      final address = {
        'full_name': defaultAddr.fullName,
        'line1': defaultAddr.line1,
        'line2': defaultAddr.line2,
        'city': defaultAddr.city,
        'postal_code': defaultAddr.postalCode,
        'country': defaultAddr.country,
        if (defaultAddr.region != null) 'region': defaultAddr.region,
        if (defaultAddr.countryCode != null) 'country_code': defaultAddr.countryCode,
        'phone': defaultAddr.phone,
      };

      final orderId = await ref.read(orderRepositoryProvider).createOrder(
            userId: user.id,
            total: total.toDouble(),
            shippingAddress: address,
            items: orderItems,
            promoCode: promoCode,
            discountAmount: discountAmount,
          );

      if (!mounted) return;
      ref.read(suppressOrderConfirmationBannerProvider.notifier).state = true;
      try {
        final locale = Localizations.localeOf(context);
        await ref
            .read(notificationsRepositoryProvider)
            .notifyOrderPlaced(
              userId: user.id,
              orderId: orderId,
              total: total.toDouble(),
              itemsCount: orderItems.length,
              languageCode: locale.languageCode,
            );
      } catch (e, st) {
        AppLogger.warn(
          'CheckoutScreen',
          'Order notification failed (non-blocking): $e',
        );
        if (kDebugMode) {
          debugPrint('  Stack: $st');
        }
      }
      if (!mounted) return;
      // Incrémenter l'usage du code promo si appliqué
      final appliedPromo = ref.read(promoProvider);
      if (appliedPromo is PromoApplied) {
        try {
          await ref.read(promoRepositoryProvider).incrementUses(
                appliedPromo.promo.id,
                userId: user.id,
                orderId: orderId, // orderId from createOrder above
              );
        } catch (e) {
          AppLogger.warn(
            'CheckoutScreen',
            'Promo increment uses failed: $e',
          );
        }
        ref.read(promoProvider.notifier).clear();
      }
      cartNotifier.clear();
      ref.invalidate(userOrdersProvider);
      ref.invalidate(myNotificationsProvider);
      ref.read(mainNavIndexProvider.notifier).state = 0;
      setState(() => _isLoading = false);
      if (!mounted) return;
      context.go(AppRoutes.main);
      final refToClear = ref;
      Future.delayed(const Duration(seconds: 3), () {
        try {
          refToClear.read(suppressOrderConfirmationBannerProvider.notifier).state = false;
        } catch (_) {}
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final failure = e is AppFailure ? e : e.toAppFailure();
      AppToast.show(context, message: failure.message, isError: true);
    }
  }

  Future<void> _openWhatsAppOrder(
    List<CartItemWithProduct> items,
    double subtotal,
    double shipping,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final formatter = ref.read(currencyFormatterProvider);
    final defaultAddr = ref.read(defaultAddressProvider);
    final total = (subtotal + shipping).clamp(0.0, double.infinity);

    final message = _buildWhatsAppOrderText(
      l10n, formatter, defaultAddr, items, subtotal, shipping, total,
    );
    final uri = Uri.parse(
      'https://wa.me/${SupportConfig.whatsAppNumber}?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _buildWhatsAppOrderText(
    AppLocalizations l10n,
    CurrencyFormatter formatter,
    dynamic defaultAddr,
    List<CartItemWithProduct> items,
    double subtotal,
    double shipping,
    double total,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('*SOLMA*');
    buffer.writeln(l10n.orderRecapSubtitle);
    buffer.writeln('');
    buffer.writeln('📍 *${l10n.shippingAddress}*');
    if (defaultAddr != null) {
      buffer.writeln('${defaultAddr.fullName}');
      buffer.writeln(defaultAddr.line1);
      if ((defaultAddr.line2 ?? '').isNotEmpty) {
        buffer.writeln(defaultAddr.line2);
      }
      buffer.writeln(
        '${defaultAddr.postalCode ?? ''} ${defaultAddr.city}'.trim(),
      );
      buffer.writeln(defaultAddr.country);
    } else {
      buffer.writeln(l10n.noAddresses);
    }
    buffer.writeln('');
    buffer.writeln('💳 *${l10n.payment}*');
    buffer.writeln(l10n.paymentOnDelivery);
    buffer.writeln(l10n.paymentOnDeliveryDescription);
    buffer.writeln('');
    buffer.writeln('📦 *${l10n.orderItems}*');
    for (final line in items) {
      buffer.writeln('*${line.product.name}*');
      final details = <String>[];
      if (line.size.isNotEmpty) details.add('${l10n.size(line.size)}');
      if (line.color.isNotEmpty) details.add('${l10n.colour}: ${line.color}');
      if (details.isNotEmpty) buffer.writeln(details.join(' • '));
      buffer.writeln(
        '${l10n.quantity(line.quantity)} × ${formatter.format(line.product.price)} = ${formatter.format(line.lineTotal)}',
      );
      buffer.writeln('');
    }
    buffer.writeln('${l10n.subtotal}: ${formatter.format(subtotal)}');
    buffer.writeln('${l10n.shipping}: ${formatter.format(shipping)}');
    buffer.writeln('*${l10n.total}: ${formatter.format(total)}*');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final itemsAsync = ref.watch(cartItemsWithProductsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.checkout),
      ),
      body: itemsAsync.when(
        data: (items) {
          final subtotal = items.fold<double>(
            0,
            (sum, line) => sum + line.lineTotal,
          );
          return Consumer(
            builder: (context, ref, _) {
              final shippingAsync = ref.watch(shippingAmountProvider);
              final shipping = shippingAsync.valueOrNull ?? defaultShippingAmount;
              final isEmpty = items.isEmpty;
              final bottomBarHeight =
                  _bottomBarButtonHeight +
                  _bottomBarVerticalPadding * 2 +
                  MediaQuery.of(context).padding.bottom;

              return Stack(
            key: const ValueKey('checkout_stack'),
            children: [
              SingleChildScrollView(
                key: const ValueKey('checkout_scroll'),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Consumer(
                      builder: (context, ref, _) {
                        final formatter = ref.watch(currencyFormatterProvider);
                        final promoState = ref.watch(promoProvider);
                        final discountAmt = promoState is PromoApplied
                            ? promoState.discountAmount
                            : 0.0;
                        return _CheckoutUnifiedReceipt(
                          items: items,
                          subtotal: subtotal,
                          shipping: shipping,
                          discountAmount: discountAmt,
                          total: (subtotal + shipping - discountAmt)
                              .clamp(0.0, double.infinity),
                          l10n: l10n,
                          formatter: formatter,
                          defaultAddress: ref.watch(defaultAddressProvider),
                          profileAsync: ref.watch(profileProvider),
                          user: ref.watch(currentUserProvider),
                          onAddressTap: () =>
                              context.push(AppRoutes.addressNew),
                        );
                      },
                    ),
                    SizedBox(height: bottomBarHeight + 24),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _CheckoutBottomBar(
                  onPay: _placeOrder,
                  onWhatsApp: () =>
                    _openWhatsAppOrder(items, subtotal, shipping),
                  isLoading: _isLoading,
                  isEmpty: isEmpty,
                  whatsAppTooltip: l10n.orderViaWhatsApp,
                ),
              ),
            ],
          );
            },
          );
        },
        loading: () => const AppPageLoader(),
        error: (err, _) => ErrorRetryWidget(
          error: err,
          onRetry: () => ref.invalidate(cartItemsWithProductsProvider),
          compact: true,
        ),
      ),
    );
  }
}

/// Barre fixe en bas : bouton "Payer en toute sécurité" + icône WhatsApp.
class _CheckoutBottomBar extends StatelessWidget {
  const _CheckoutBottomBar({
    required this.onPay,
    required this.onWhatsApp,
    required this.isLoading,
    required this.isEmpty,
    required this.whatsAppTooltip,
  });

  final VoidCallback onPay;
  final VoidCallback onWhatsApp;
  final bool isLoading;
  final bool isEmpty;
  final String whatsAppTooltip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(
        _bottomBarHorizontalPadding,
        _bottomBarVerticalPadding,
        _bottomBarHorizontalPadding,
        bottomPadding + _bottomBarVerticalPadding,
      ),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              label: l10n.paySecurely,
              onPressed: isEmpty ? null : onPay,
              isLoading: isLoading,
            ),
          ),
          const SizedBox(width: 12),
          Tooltip(
            message: whatsAppTooltip,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isEmpty ? null : onWhatsApp,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 72,
                  height: _bottomBarButtonHeight,
                  alignment: Alignment.center,

                  child: Image.asset(
                    'assets/icons/whatsapp_icon.png',
                    fit: BoxFit.contain,
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Conteneur unique : adresse + paiement + articles.
class _CheckoutUnifiedReceipt extends StatelessWidget {
  const _CheckoutUnifiedReceipt({
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.discountAmount,
    required this.total,
    required this.l10n,
    required this.formatter,
    required this.defaultAddress,
    required this.profileAsync,
    required this.user,
    required this.onAddressTap,
  });

  final List<CartItemWithProduct> items;
  final double subtotal;
  final double shipping;
  final double discountAmount;
  final double total;
  final AppLocalizations l10n;
  final CurrencyFormatter formatter;
  final AddressModel? defaultAddress;
  final AsyncValue<ProfileModel?> profileAsync;
  final User? user;
  final VoidCallback onAddressTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête type ticket
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 70),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.primary.withValues(alpha: 0.2)
                    : theme.colorScheme.primary.withValues(alpha: 0.08),
              ),
              child: Column(
                children: [
                  Text(
                    'SOLMA',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.orderRecapSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _DashedDivider(theme: theme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section Adresse : titre + lien vert (changer/créer)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _SectionLabel(theme: theme, label: l10n.shippingAddress),
                    InkWell(
                      onTap: onAddressTap,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Text(
                          defaultAddress != null
                              ? l10n.editAddress
                              : l10n.addAddress,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: onAddressTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: defaultAddress != null
        ? _buildAddressContent(theme, defaultAddress!)
                        : _buildNoAddressContent(theme),
                  ),
                ),
                _DashedDivider(theme: theme, short: true),
                const SizedBox(height: 16),
                // Section Paiement
                _SectionLabel(theme: theme, label: l10n.payment),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.paymentOnDelivery,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.paymentOnDeliveryDescription,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _DashedDivider(theme: theme, short: true),
                const SizedBox(height: 16),
                // Section Articles
                _SectionLabel(theme: theme, label: l10n.orderItems),
                const SizedBox(height: 8),
                ...items.map(
                  (line) {
                    final imageUrl = line.product.firstImageUrl;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: imageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.shopping_bag_outlined,
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                  )
                                : Icon(
                                    Icons.shopping_bag_outlined,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line.product.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${l10n.quantity(line.quantity)} × ${formatter.format(line.product.price)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatter.format(line.lineTotal),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _DashedDivider(theme: theme, short: true),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.subtotal, style: theme.textTheme.bodyMedium),
                    Text(
                      formatter.format(subtotal),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.shipping, style: theme.textTheme.bodyMedium),
                    Text(
                      formatter.format(shipping),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                if (discountAmount > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.discountLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        '-${formatter.format(discountAmount)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.total,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        formatter.format(total),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _DashedDivider(theme: theme),
                const SizedBox(height: 12),
                Text(
                  l10n.checkoutRecapFooter,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressContent(ThemeData theme, AddressModel addr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          addr.fullName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          addr.line1,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if ((addr.line2)?.isNotEmpty ?? false) ...[
          const SizedBox(height: 2),
          Text(
            addr.line2!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 2),
        Text(
          '${addr.postalCode ?? ''} ${addr.city}'.trim(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          addr.country,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNoAddressContent(ThemeData theme) {
    final name =
        profileAsync.valueOrNull?.fullName ??
        user?.userMetadata?['full_name'] as String? ??
        user?.email?.split('@').first ??
        '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.noAddresses,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.theme, required this.label});

  final ThemeData theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
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
