/// Abstraction so AdMob can be enabled later without refactoring screens.
///
/// The google_mobile_ads package is intentionally not linked in this build so
/// APK generation stays reliable. Wire the official SDK here when you supply
/// production AdMob IDs and consent (UMP/ATT) flow.
class AdService {
  AdService._();
  static final instance = AdService._();

  /// Feature flag — keep false until production IDs + consent flow are ready.
  static const adsEnabled = false;

  Future<void> initialize() async {
    // No-op while ads are disabled / SDK not linked.
  }

  bool get isReady => false;

  String get bannerAdUnitId => 'ca-app-pub-3940256099942544/6300978111';
}
