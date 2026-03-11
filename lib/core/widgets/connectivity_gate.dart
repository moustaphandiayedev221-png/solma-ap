import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/connectivity_provider.dart';

/// Passe le contenu tel quel. Pas de toast d'erreur de connexion.
class ConnectivityGate extends ConsumerWidget {
  const ConnectivityGate({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(connectivityProvider); // garde le provider actif
    return child;
  }
}
