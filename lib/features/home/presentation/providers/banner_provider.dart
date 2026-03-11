import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/banner_model.dart';
import '../../data/banner_repository.dart';

final bannerRepositoryProvider = Provider<BannerRepository>((ref) {
  return BannerRepository();
});

/// Bannières actives depuis Supabase
final bannersProvider = FutureProvider<List<BannerModel>>((ref) async {
  return ref.read(bannerRepositoryProvider).getActiveBanners();
});
