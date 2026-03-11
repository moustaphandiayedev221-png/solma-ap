import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/onboarding_repository.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository();
});

/// Indique si l'onboarding a déjà été vu.
final isOnboardingDoneProvider = FutureProvider<bool>((ref) async {
  return ref.read(onboardingRepositoryProvider).isOnboardingDone();
});
