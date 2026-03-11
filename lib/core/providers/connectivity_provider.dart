import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Indique si l'app a accès à Internet (Wi‑Fi ou données mobiles).
/// Vérifie la connectivité réseau en temps réel.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield await _checkConnectivity(connectivity);
  await for (final results in connectivity.onConnectivityChanged) {
    yield results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet ||
        r == ConnectivityResult.vpn);
  }
});

Future<bool> _checkConnectivity(Connectivity connectivity) async {
  final results = await connectivity.checkConnectivity();
  return results.any((r) =>
      r == ConnectivityResult.mobile ||
      r == ConnectivityResult.wifi ||
      r == ConnectivityResult.ethernet ||
      r == ConnectivityResult.vpn);
}
