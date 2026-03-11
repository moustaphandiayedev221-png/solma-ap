import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_provider.dart';
import 'tracking_model.dart';

/// Repository pour le suivi des commandes.
class TrackingRepository {
  TrackingRepository([SupabaseClient? client])
      : _client = client ?? supabaseClient;

  final SupabaseClient _client;
  static const String _table = 'order_tracking';

  /// Récupère tous les événements de tracking d'une commande, triés par date.
  Future<List<TrackingModel>> getTrackingEvents(String orderId) async {
    final res = await _client
        .from(_table)
        .select()
        .eq('order_id', orderId)
        .order('created_at', ascending: true);

    return (res as List)
        .map((e) => TrackingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
