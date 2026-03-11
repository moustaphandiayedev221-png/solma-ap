import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/responsive_module.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../core/widgets/connection_elegant_placeholder.dart';
import '../providers/publicites_provider.dart';
import '../widgets/publicite_card.dart';

/// Liste toutes les publicités actives.
class PublicitesListScreen extends ConsumerWidget {
  const PublicitesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final r = context.responsive;
    final async = ref.watch(publicitesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newArrivals),
        centerTitle: true,
      ),
      body: async.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noNewArrivals,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(publicitesProvider.future),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                r.horizontalPadding,
                16,
                r.horizontalPadding,
                MediaQuery.of(context).padding.bottom + 24,
              ),
              itemCount: list.length,
              itemBuilder: (_, i) {
                return PubliciteCard(publicite: list[i]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ConnectionElegantPlaceholder(
          error: err,
          onRetry: () => ref.invalidate(publicitesProvider),
          useSliver: false,
        ),
      ),
    );
  }
}
