import 'dart:async' show unawaited;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Central place for AdMob configuration.
///
/// Currently wired to Google's own official *test* ad unit IDs — safe
/// to ship and run today, but they show placeholder test creatives
/// and earn nothing. Before a real release, create ad units in your
/// own AdMob account and swap the two constants below marked TODO.
/// See the AndroidManifest.xml / Info.plist requirements this needs
/// too — those aren't optional, the app crashes on launch without
/// them (see README / IOS_SETUP.md).
class AdService {
  AdService._();

  static bool _initialized = false;

  /// Call once at startup. Safe to call multiple times.
  static Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    _initialized = true;
    // Per Google's own guidance this doesn't need to be awaited — the
    // SDK queues ad loads until initialization finishes internally.
    unawaited(MobileAds.instance.initialize());
  }

  /// TODO: replace with your own AdMob banner ad unit ID before a
  /// real release. This is Google's official test ID — always safe
  /// to leave in during development, never earns real revenue.
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-3940256099942544/2934735716';
  }
}
