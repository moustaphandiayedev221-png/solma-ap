import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index de l'onglet actif dans la navigation principale : 0=Home, 1=Search, 2=Cart, 3=Profile.
final mainNavIndexProvider = StateProvider<int>((ref) => 0);
