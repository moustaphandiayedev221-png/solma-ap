import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../checkout/presentation/providers/order_provider.dart';
import 'order_detail_screen.dart';

/// Écran wrapper pour la route /orders/detail/:id (deep linking).
/// Charge la commande puis affiche OrderDetailScreen.
class OrderDetailRouteScreen extends ConsumerWidget {
  const OrderDetailRouteScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go(AppRoutes.main));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final orderAsync = ref.watch(
      orderByIdProvider((orderId: orderId, userId: user.id)),
    );

    return orderAsync.when(
      data: (order) {
        if (order == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go(AppRoutes.orderHistory);
            }
          });
          return Scaffold(
            body: Center(
              child: Text(AppLocalizations.of(context)!.errorGeneric),
            ),
          );
        }
        return OrderDetailScreen(order: order);
      },
      loading: () => const Scaffold(
        body: Center(child: AppLoader()),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.errorGeneric),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(AppRoutes.orderHistory),
                child: const Text('Voir mes commandes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
