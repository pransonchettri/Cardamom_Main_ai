import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Android values below are pulled directly from
/// `android/app/google-services.json` (project `cardamomai`), which is
/// already real. That file and this one MUST describe the same
/// Firebase project — if they don't, the native Android SDK
/// auto-initializes the default app from `google-services.json` at
/// process start, and then Dart's `Firebase.initializeApp()` call
/// with different options throws
/// `[core/duplicate-app] A Firebase App named "[DEFAULT]" already
/// exists`. That exception has been known to crash the app before the
/// first frame even renders, rather than being reliably caught by the
/// try/catch in `main.dart` — this was the app's actual startup
/// crash. Keep these two files in sync.
///
/// iOS/web are still unconfigured placeholders — no
/// `GoogleService-Info.plist` exists yet. Run `flutterfire configure`
/// to fill those in once you're ready to support iOS/web sign-in;
/// until then `main.dart`'s try/catch correctly no-ops Firebase on
/// those platforms.
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
    apiKey: 'AIzaSyAMFdg8buB6lvfBX_oVRZmguWrUtGc32QI',
    appId: '1:707951057817:android:3c92b62816907aa8805108',
    messagingSenderId: '707951057817',
    projectId: 'cardamomai',
    storageBucket: 'cardamomai.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    iosBundleId: 'com.example.plantAi',
  );
}
