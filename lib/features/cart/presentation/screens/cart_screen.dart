import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/responsive/responsive_module.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../product/presentation/providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../promo/data/promo_repository.dart';
import '../../../promo/presentation/providers/promo_provider.dart';

/// Écran panier avec les vraies données du provider
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _promoCodeController = TextEditingController();

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _applyPromoCode() async {
    final items = ref.read(cartItemsWithProductsProvider).valueOrNull ?? [];
    final subtotal = items.fold<double>(0, (sum, line) => sum + line.lineTotal);
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) return;
    final userId = ref.read(currentUserProvider)?.id;
    await ref.read(promoProvider.notifier).applyCode(code, subtotal, userId: userId);
    if (!mounted) return;
    final promoState = ref.read(promoProvider);
    if (promoState is PromoError) {
      AppToast.show(
        context,
        message: _promoErrorMessage(AppLocalizations.of(context)!, promoState.errorCode),
        isError: true,
      );
    }
  }

  String _promoErrorMessage(AppLocalizations l10n, PromoErrorCode code) {
    return switch (code) {
      PromoErrorCode.notFound => l10n.promoNotFound,
      PromoErrorCode.inactive => l10n.promoNotFound,
      PromoErrorCode.expired => l10n.promoExpired,
      PromoErrorCode.notStarted => l10n.promoNotFound,
      PromoErrorCode.maxUsesReached => l10n.promoMaxUsed,
      PromoErrorCode.maxUsesPerUserReached => l10n.promoMaxUsed,
      PromoErrorCode.minOrderNotMet => l10n.promoMinOrder,
    };
  }

  void _confirmClear(BuildContext ctx, CartNotifier cartNotifier) {
    final theme = Theme.of(ctx);
    final l10n = AppLocalizations.of(ctx)!;
    showDialog<void>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.myCart),
        content: Text('${l10n.clear} le panier ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              ref.read(promoProvider.notifier).clear();
              cartNotifier.clear();
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final r = context.responsive;
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myCart),
        actions: [
          TextButton(
            onPressed: () => _confirmClear(context, cartNotifier),
            child: Text(l10n.clear),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final lineIds = ref.watch(cartLineIdsProvider);
          if (lineIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noProducts,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  key: const ValueKey('cart_list'),
                  padding: EdgeInsets.symmetric(
                    horizontal: r.horizontalPadding,
                    vertical: r.verticalPadding,
                  ),
                  itemCount: lineIds.length,
                  itemBuilder: (context, i) {
                    final line = lineIds[i];
                    return _CartLineItem(
                      key: ValueKey(line.key),
                      itemKey: line.key,
                    );
                  },
                ),
              ),
              _CartBottomBar(
                promoCodeController: _promoCodeController,
                onApplyPromo: _applyPromoCode,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Ligne du panier : dépend de la clé composite (produit + variante).
class _CartLineItem extends ConsumerWidget {
  const _CartLineItem({super.key, required this.itemKey});

  final CartItemKey itemKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final r = context.responsive;
    final thumbSize = r.isCompactSmall ? 72.0 : 90.0;
    final productAsync = ref.watch(productByIdProvider(itemKey.productId));
    final quantity = ref.watch(
      cartProvider.select((s) => s.items[itemKey] ?? 0),
    );
    final cartNotifier = ref.read(cartProvider.notifier);

    return productAsync.when(
      data: (product) {
        if (product == null) return const SizedBox.shrink();
        final sizeLabel = itemKey.size.isNotEmpty
            ? itemKey.size
            : (product.sizes.isNotEmpty ? product.sizes.first : '—');
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SoftCard(
            onTap: () => context.push('${AppRoutes.product}/${product.id}'),
            child: Row(
              children: [
                Container(
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: product.firstImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: product.firstImageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Icon(
                            Icons.shopping_bag_outlined,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                        )
                      : Icon(
                          Icons.shopping_bag_outlined,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                ),
                SizedBox(width: r.gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          final formatter = ref.watch(currencyFormatterProvider);
                          return Text(
                            'Size $sizeLabel • ${formatter.format(product.price)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 22,
                            ),
                            onPressed: () => cartNotifier.removeItem(
                              product.id,
                              size: itemKey.size,
                              color: itemKey.color,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '$quantity',
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 22,
                            ),
                            onPressed: () => cartNotifier.addItem(
                              product.id,
                              size: itemKey.size,
                              color: itemKey.color,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => cartNotifier.removeAll(
                    product.id,
                    size: itemKey.size,
                    color: itemKey.color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SoftCard(
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 120,
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 80,
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

/// Barre du bas : code promo + total.
class _CartBottomBar extends ConsumerWidget {
  const _CartBottomBar({
    required this.promoCodeController,
    required this.onApplyPromo,
  });

  final TextEditingController promoCodeController;
  final VoidCallback onApplyPromo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final r = context.responsive;
    final itemsAsync = ref.watch(cartItemsWithProductsProvider);
    final promoState = ref.watch(promoProvider);
    final discountAmount = ref.watch(promoDiscountProvider);
    final isPromoLoading = promoState is PromoLoading;
    final appliedPromo = promoState is PromoApplied ? promoState : null;

    final subtotal =
        itemsAsync.valueOrNull?.fold<double>(
          0,
          (sum, line) => sum + line.lineTotal,
        ) ??
        0.0;
    final total = (subtotal - discountAmount).clamp(0.0, double.infinity);
    final isLoadingTotal =
        itemsAsync.valueOrNull == null &&
        (itemsAsync.isLoading || itemsAsync.hasError);

    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: AppShadows.card(context),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(r.verticalPadding + 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: promoCodeController,
                    enabled: appliedPromo == null && !isPromoLoading,
                    decoration: InputDecoration(
                      hintText: l10n.promoCode,
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => onApplyPromo(),
                  ),
                ),
                const SizedBox(width: 12),
                if (isPromoLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  TextButton(
                    onPressed: appliedPromo == null ? onApplyPromo : null,
                    child: Text(l10n.apply),
                  ),
              ],
            ),
            if (appliedPromo != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.promoCodeApplied} (${appliedPromo.promo.code})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Row(
                    children: [
                      Consumer(
                        builder: (context, ref, _) {
                          final formatter = ref.watch(currencyFormatterProvider);
                          return Text(
                            '-${formatter.format(appliedPromo.discountAmount)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => ref.read(promoProvider.notifier).clear(),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.total,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final formatter = ref.watch(currencyFormatterProvider);
                    return Text(
                      isLoadingTotal ? '...' : formatter.format(total),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: l10n.proceedToCheckout,
              onPressed: () => context.push(AppRoutes.checkout),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
