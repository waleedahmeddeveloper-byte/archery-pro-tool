import 'package:shared_preferences/shared_preferences.dart';

/// Cached onboarding flag so GoRouter redirect does not hit disk every hop.
class OnboardingGate {
  OnboardingGate._();

  static const prefsKey = 'arcus_onboarding_seen';
  static bool? _cached;

  static Future<bool> hasSeen() async {
    if (_cached != null) return _cached!;
    final prefs = await SharedPreferences.getInstance();
    _cached = prefs.getBool(prefsKey) ?? false;
    return _cached!;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKey, true);
    _cached = true;
  }

  /// Test-only reset.
  static void resetCacheForTests() => _cached = null;
}
