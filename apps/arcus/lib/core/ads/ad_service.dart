import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Abstraction so AdMob can be enabled later without refactoring screens.
class AdService {
  AdService._();
  static final instance = AdService._();

  /// Feature flag — keep false until production IDs + consent flow are ready.
  static const adsEnabled = false;

  bool _ready = false;

  Future<void> initialize() async {
    if (!adsEnabled) return;
    await MobileAds.instance.initialize();
    _ready = true;
  }

  bool get isReady => adsEnabled && _ready;

  /// Google sample banner unit for debug builds only.
  String get bannerAdUnitId {
    if (kReleaseMode) {
      // Replace when real AdMob IDs are supplied.
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx';
    }
    return 'ca-app-pub-3940256099942544/6300978111';
  }
}
