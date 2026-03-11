import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/error_retry_widget.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/address_model.dart';
import '../providers/address_provider.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final addressesAsync = ref.watch(userAddressesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.addresses),
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return ListView(
              key: const ValueKey('addresses_empty'),
              padding: const EdgeInsets.all(20),
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noAddresses,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: l10n.addAddress,
                  onPressed: () => context.push(AppRoutes.addressNew),
                ),
              ],
            );
          }
          return ListView(
            key: const ValueKey('addresses_list'),
            padding: const EdgeInsets.all(20),
            children: [
              ...addresses.map((a) => KeyedSubtree(
                    key: ValueKey(a.id),
                    child: _AddressTile(
                      address: a,
                      onTap: () => context.push('${AppRoutes.addressEdit}/${a.id}'),
                      onSetDefault: () async {
                        final user = ref.read(currentUserProvider);
                        if (user != null) {
                          await ref.read(addressRepositoryProvider).setDefault(user.id, a.id);
                          ref.invalidate(userAddressesProvider);
                          ref.invalidate(defaultAddressProvider);
                        }
                      },
                    ),
                  )),
              const SizedBox(height: 16),
              PrimaryButton(
                label: l10n.addAddress,
                onPressed: () => context.push(AppRoutes.addressNew),
              ),
            ],
          );
        },
        loading: () => AppPageLoader(
          key: const ValueKey('addresses_loading'),
          minHeight: 180,
        ),
        error: (err, _) => ErrorRetryWidget(
          error: err,
          onRetry: () => ref.invalidate(userAddressesProvider),
          compact: true,
        ),
      ),
    );
  }
}

class _AddressTile extends ConsumerWidget {
  const _AddressTile({
    required this.address,
    required this.onTap,
    required this.onSetDefault,
  });

  final AddressModel address;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (address.label != null && address.label!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      address.label!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (address.isDefault) ...[
                  if (address.label != null && address.label!.isNotEmpty)
                    const SizedBox(width: 8),
                  Text(
                    '• ${l10n.setAsDefault}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
            if (!address.isDefault)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: TextButton(
                  onPressed: onSetDefault,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(l10n.setAsDefault),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              address.fullName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              address.singleLine,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (address.phone != null && address.phone!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                address.phone!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
