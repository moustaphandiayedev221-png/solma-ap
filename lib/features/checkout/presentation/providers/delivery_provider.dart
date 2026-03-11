import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/presentation/providers/address_provider.dart';
import '../../data/delivery_zone_repository.dart';

final deliveryZoneRepositoryProvider =
    Provider<DeliveryZoneRepository>((ref) => DeliveryZoneRepository());

/// Montant de livraison calculé selon l'adresse (pays + région).
/// Si region est vide, utilise la ville comme fallback pour les anciennes adresses.
final shippingAmountProvider = FutureProvider<double>((ref) async {
  final defaultAddr = ref.watch(defaultAddressProvider);
  if (defaultAddr == null) return defaultShippingAmount;

  final countryCode = defaultAddr.countryCode ??
      _countryNameToCode(defaultAddr.country);
  if (countryCode == null) return defaultShippingAmount;

  // Priorité : region > city (pour adresses créées avant l'ajout du champ region)
  final regionOrCity = defaultAddr.region?.trim().isNotEmpty == true
      ? defaultAddr.region!.trim()
      : defaultAddr.city.trim().isNotEmpty
          ? defaultAddr.city.trim()
          : null;

  return ref.read(deliveryZoneRepositoryProvider).getShippingAmount(
        countryCode: countryCode,
        region: regionOrCity,
      );
});

/// Mapping pays (nom) -> code ISO approximatif pour adresses sans country_code.
String? _countryNameToCode(String name) {
  if (name.isEmpty) return null;
  final lower = name.toLowerCase().trim();
  final map = <String, String>{
    'senegal': 'SN', 'sénégal': 'SN',
    'france': 'FR', 'mali': 'ML', 'mauritanie': 'MR',
    'côte d\'ivoire': 'CI', 'cote d\'ivoire': 'CI', 'ivory coast': 'CI',
    'burkina faso': 'BF', 'burkina': 'BF',
    'togo': 'TG', 'benin': 'BJ', 'bénin': 'BJ',
    'guinée': 'GN', 'guinee': 'GN', 'guinea': 'GN',
    'niger': 'NE', 'gambie': 'GM', 'guinée-bissau': 'GW',
  };
  return map[lower] ?? map[lower.replaceAll(RegExp(r'[éèêë]'), 'e')];
}
