import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/tracking_model.dart';
import '../../data/tracking_repository.dart';

/// Repository provider pour le tracking.
final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepository();
});

/// Événements de tracking pour une commande donnée.
final trackingEventsProvider =
    FutureProvider.family<List<TrackingModel>, String>((ref, orderId) async {
  final repo = ref.watch(trackingRepositoryProvider);
  return repo.getTrackingEvents(orderId);
});
