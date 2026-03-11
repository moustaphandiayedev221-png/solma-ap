import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/section_model.dart';
import '../../data/section_repository.dart';

final sectionsProvider =
    FutureProvider<List<SectionModel>>((ref) async {
  return SectionRepository().getAll();
});
