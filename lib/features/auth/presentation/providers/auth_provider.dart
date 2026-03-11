import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.session?.user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Provider qui filtre les événements d'auth pertinents pour la session.
/// Émet uniquement sur tokenRefreshed et signedOut.
final sessionAuthEventProvider = StreamProvider<AuthChangeEvent>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges
      .where((state) =>
          state.event == AuthChangeEvent.tokenRefreshed ||
          state.event == AuthChangeEvent.signedOut)
      .map((state) => state.event);
});
