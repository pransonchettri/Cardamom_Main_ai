import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// PLACEHOLDER — this file is meant to be replaced automatically.
///
/// Run this once from your project root, after completing the
/// Firebase Console steps (creating a project, enabling Google +
/// Phone sign-in):
///
///   dart pub global activate flutterfire_cli
///   flutterfire configure
///
/// That command overwrites this entire file with your project's real
/// values and also drops `google-services.json` /
/// `GoogleService-Info.plist` into the right native folders — you
/// don't edit any of that by hand.
///
/// Until you run it, the placeholder values below are intentionally
/// invalid. `main.dart` wraps `Firebase.initializeApp()` in a
/// try/catch specifically so this doesn't crash the app — sign-in
/// will just report itself unavailable, while scanning, the library,
/// history, and everything else keeps working normally.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    iosBundleId: 'com.example.plantAi',
  );
}
