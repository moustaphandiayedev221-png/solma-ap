import '../providers/supabase_provider.dart';
import '../utils/app_logger.dart';

/// Repository des libellés UI stockés en base (table Supabase `app_labels`).
/// Permet de faire venir tous les textes (ex. "Tout", "Tout voir") depuis la base.
class AppLabelsRepository {
  AppLabelsRepository();

  static const String _table = 'app_labels';
  static const String _tag = 'AppLabelsRepository';

  /// Récupère tous les libellés pour une locale donnée.
  /// Retourne une map [key] -> [value]. Clés ex. : categoryAll, seeAll, welcomeBack...
  /// Si la table n'existe pas ou est vide, retourne {}.
  Future<Map<String, String>> getLabels(String locale) async {
    try {
      final res = await supabaseClient
          .from(_table)
          .select('key, value')
          .eq('locale', locale);
      final list = res as List;
      final map = <String, String>{};
      for (final e in list) {
        final row = e as Map<String, dynamic>;
        final key = row['key'] as String?;
        final value = row['value'] as String?;
        if (key != null && value != null) map[key] = value;
      }
      return map;
    } catch (e, st) {
      AppLogger.error(_tag, 'getLabels($locale) failed', e, st);
      return {};
    }
  }
}
