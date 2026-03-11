import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';

/// Persistance de l'état onboarding (vu ou non).
class OnboardingRepository {
  OnboardingRepository([SharedPreferences? prefs]) : _prefs = prefs;

  SharedPreferences? _prefs;
  static SharedPreferences? _staticPrefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= _staticPrefs ?? await SharedPreferences.getInstance();
    _staticPrefs ??= _prefs;
    return _prefs!;
  }

  /// Indique si l'onboarding a déjà été complété.
  Future<bool> isOnboardingDone() async {
    return (await _instance).getBool(AppConstants.keyOnboardingDone) ?? false;
  }

  /// Marque l'onboarding comme complété.
  Future<void> setOnboardingDone() async {
    await (await _instance).setBool(AppConstants.keyOnboardingDone, true);
  }
}
