import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/publicite_model.dart';
import '../../data/publicites_repository.dart';

final publicitesRepositoryProvider = Provider<PublicitesRepository>((ref) {
  return PublicitesRepository();
});

/// Publicités actives (toutes sections, pour compatibilité).
final publicitesProvider = FutureProvider<List<PubliciteModel>>((ref) async {
  return ref.read(publicitesRepositoryProvider).getPublicites(limit: 20);
});

/// Publicités pour une section produit donnée (popular, tenues-africaines, sacs-a-main, sports).
final publicitesBySectionProvider =
    FutureProvider.family<List<PubliciteModel>, String>((ref, section) async {
  return ref.read(publicitesRepositoryProvider).getPublicitesBySection(section);
});
