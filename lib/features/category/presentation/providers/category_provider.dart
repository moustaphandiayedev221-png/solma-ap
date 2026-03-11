import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/category_model.dart';
import '../../data/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

/// Liste des catégories depuis Supabase.
/// Pour les chips on préfixe avec "All" côté UI.
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.read(categoryRepositoryProvider).getCategories();
});
