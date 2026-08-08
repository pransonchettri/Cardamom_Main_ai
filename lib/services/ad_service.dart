import 'dart:async' show unawaited;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Central place for AdMob configuration.
///
/// Android is wired to CardamomAI's real AdMob app + banner ad unit —
/// real ads, real revenue, once Google's "up to an hour" activation
/// window for a newly-created ad unit has passed. iOS still uses
/// Google's official *test* ad unit ID (no iOS app/ad unit has been
/// created in AdMob yet) — create one there and swap the iOS branch
/// below the same way before an iOS release. See the AndroidManifest.xml
/// / Info.plist requirements this needs too — those aren't optional,
/// the app crashes on launch without them (see README / IOS_SETUP.md).
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

  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    // TODO(iOS release): still Google's test ID - create a real iOS app
    // + banner ad unit in AdMob and replace it, the same way Android's
    // real ID was swapped in below.
    return Platform.isAndroid
        ? 'ca-app-pub-2289058620170250/1152327341'
        : 'ca-app-pub-3940256099942544/2934735716';
  }
}
