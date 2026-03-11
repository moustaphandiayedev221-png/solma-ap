import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_labels_repository.dart';

final appLabelsRepositoryProvider = Provider<AppLabelsRepository>((ref) {
  return AppLabelsRepository();
});

/// Libellés UI chargés depuis Supabase (table app_labels) pour la locale donnée.
/// Clé = identifiant (ex. categoryAll, seeAll), valeur = texte affiché.
/// Utiliser avec [AppLocalizations] en fallback si la clé n'existe pas en base.
final appLabelsProvider =
    FutureProvider.family<Map<String, String>, String>((ref, locale) async {
  final repo = ref.read(appLabelsRepositoryProvider);
  return repo.getLabels(locale);
});
