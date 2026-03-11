import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';

/// Montant de livraison par défaut si aucune zone ne correspond.
const double defaultShippingAmount = 10.0;

class DeliveryZoneRepository {
  DeliveryZoneRepository([SupabaseClient? client])
      : _client = client ?? supabaseClient;

  final SupabaseClient _client;
  static const String _table = 'delivery_zones';

  /// Récupère le montant de livraison pour un pays et une région.
  /// Ordre de priorité :
  /// 1. Zone pays + région exacte
  /// 2. Zone pays (region null = défaut pour tout le pays)
  /// 3. Zone mondiale (country_code = '*')
  /// 4. Valeur par défaut [defaultShippingAmount]
  Future<double> getShippingAmount({
    required String countryCode,
    String? region,
  }) async {
    final code = countryCode.toUpperCase().trim();
    if (code.isEmpty) return defaultShippingAmount;

    try {
      // 1. Chercher zone pays + région
      if (region != null && region.trim().isNotEmpty) {
        final zoneRegion = await _client
            .from(_table)
            .select('amount')
            .eq('country_code', code)
            .eq('region', region.trim())
            .eq('is_active', true)
            .maybeSingle();
        if (zoneRegion != null) {
          return (zoneRegion['amount'] as num).toDouble();
        }
      }

      // 2. Zone par défaut pour le pays (region null)
      final zonesCountry = await _client
          .from(_table)
          .select('region, amount')
          .eq('country_code', code)
          .eq('is_active', true);
      for (final z in zonesCountry as List) {
        final row = z as Map<String, dynamic>;
        if (row['region'] == null) {
          return (row['amount'] as num).toDouble();
        }
      }

      // 3. Zone mondiale
      final zoneGlobal = await _client
          .from(_table)
          .select('amount')
          .eq('country_code', '*')
          .eq('is_active', true)
          .maybeSingle();
      if (zoneGlobal != null) {
        return (zoneGlobal['amount'] as num).toDouble();
      }
    } catch (_) {
      // En cas d'erreur (table absente, etc.), retourner le défaut
    }
    return defaultShippingAmount;
  }
}
