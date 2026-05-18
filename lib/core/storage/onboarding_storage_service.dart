import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/app/app_setup.dart';
import 'package:shared_preferences/shared_preferences.dart';

final onboardingStorageServiceProvider = Provider<OnboardingStorageService>((
  ref,
) {
  return OnboardingStorageService(AppSetup.sharedPreferences);
});

class OnboardingStorageService {
  static const String _key = 'onboarding_completed';

  final SharedPreferences _prefs;

  OnboardingStorageService(this._prefs);

  bool isCompleted() => _prefs.getBool(_key) ?? false;

  Future<void> markCompleted() async {
    await _prefs.setBool(_key, true);
  }
}
