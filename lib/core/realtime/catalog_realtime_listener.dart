import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/supabase_provider.dart';
import '../../features/home/presentation/providers/banner_provider.dart';
import '../../features/product/presentation/providers/product_provider.dart';
import '../../core/services/product_cache_service.dart';
import '../../features/publicites/presentation/providers/publicites_provider.dart';
import '../../features/sections/presentation/providers/sections_provider.dart';

/// Écoute les changements Realtime sur products, product_sections, banners, publicites.
/// Invalide les providers pour que l'UI affiche automatiquement les nouveaux contenus
/// sans fermer/réouvrir l'app (comportement pro comme les grandes applications).
class CatalogRealtimeListener extends ConsumerStatefulWidget {
  const CatalogRealtimeListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<CatalogRealtimeListener> createState() =>
      _CatalogRealtimeListenerState();
}

class _CatalogRealtimeListenerState extends ConsumerState<CatalogRealtimeListener> {
  RealtimeChannel? _channel;
  bool _subscribed = false;
  DateTime? _lastInvalidation;

  void _invalidateCatalog() {
    // Debounce : évite les rafales d'invalidations (ex. import bulk)
    final now = DateTime.now();
    if (_lastInvalidation != null &&
        now.difference(_lastInvalidation!).inMilliseconds < 500) {
      return;
    }
    _lastInvalidation = now;
    if (!mounted) return;
    ref.invalidate(bannersProvider);
    ref.invalidate(sectionsProvider);
    ref.invalidate(productCacheProvider);
    ref.invalidate(sectionProductsByCategoryProvider);
    ref.invalidate(productsBySectionProvider);
    ref.invalidate(popularProductsProvider);
    ref.invalidate(popularProductsByCategoryProvider);
    ref.invalidate(sportsProductsProvider);
    ref.invalidate(sportsProductsByCategoryProvider);
    ref.invalidate(sacsAMainByCategoryProvider);
    ref.invalidate(tenuesAfricainesByCategoryProvider);
    ref.invalidate(allProductsProvider);
    ref.invalidate(publicitesProvider);
    ref.invalidate(publicitesBySectionProvider);
  }

  void _subscribe() {
    if (_subscribed) return;
    _subscribed = true;
    final client = supabaseClient;

    _channel = client.channel('catalog-realtime').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'products',
      callback: (_) => _invalidateCatalog(),
    ).onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'product_sections',
      callback: (_) => _invalidateCatalog(),
    ).onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'banners',
      callback: (_) => _invalidateCatalog(),
    ).onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'publicites',
      callback: (_) => _invalidateCatalog(),
    ).subscribe();
  }

  void _unsubscribe() {
    if (!_subscribed) return;
    _subscribed = false;
    if (_channel != null) {
      supabaseClient.removeChannel(_channel!);
      _channel = null;
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _subscribe();
    return widget.child;
  }
}
