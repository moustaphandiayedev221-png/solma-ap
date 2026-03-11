import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/product/data/product_model.dart';

/// Cache en mémoire des listes de produits pour affichage hors ligne / reconnexion.
/// Évite d'afficher les erreurs réseau lorsque des données sont déjà disponibles.
class ProductCacheNotifier extends Notifier<Map<String, List<ProductModel>>> {
  @override
  Map<String, List<ProductModel>> build() => {};

  void set(String key, List<ProductModel> list) {
    state = {...state, key: list};
  }

  List<ProductModel>? get(String key) => state[key];
}

final productCacheProvider =
    NotifierProvider<ProductCacheNotifier, Map<String, List<ProductModel>>>(
  ProductCacheNotifier.new,
);
