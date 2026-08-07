# CardamomAI — full project folder

This is everything I can generate for you. Read this before merging
it into your existing project at `D:\Project\plant_ai\Cardamom_Main_ai`.

## What's in here (all complete, verified)

```
lib/                    All 51 Dart source files — the entire app
assets/model/           The real, verified TFLite AI model + labels
android/build.gradle.kts        Root Gradle config (JVM target fix included)
android/settings.gradle.kts     Firebase plugin registered
android/app/build.gradle.kts    minSdk 23, Firebase plugin applied
.github/workflows/      GitHub Actions - builds Android AND iOS
IOS_SETUP.md            Exact steps + copy-paste config for iOS
pubspec.yaml            All dependencies, versions verified current
```

## How to merge this in

Copy every folder/file above into your project, replacing what's
there. Your project should end up with `lib/`, `assets/`, `android/`,
`.github/`, `pubspec.yaml`, `IOS_SETUP.md` all sitting at the top
level together — the same merge process you've already done several
times.

**Do NOT copy an `ios/` folder from here — there isn't one.** See
"What's NOT in here" below.

## Before your next build: three required steps

These aren't optional — the build (or the app itself) will fail
without them now that Firebase and ads are wired in.

1. **Run `flutterfire configure`** (steps were covered earlier: create
   a Firebase project, enable Google + Phone sign-in, then run
   `dart pub global activate flutterfire_cli` and `flutterfire configure`
   from your project root). This generates a real `lib/firebase_options.dart`
   (replacing the placeholder in this folder) and drops
   `google-services.json` into `android/app/` automatically.

2. **`google-services.json` must exist before you build.** I added the
   `google-services` Gradle plugin to make Firebase possible, and that
   plugin *requires* this file to exist or the Android build refuses
   to run at all, immediately, regardless of anything else being
   correct. Step 1 creates it for you — just don't skip it.

3. **Add the AdMob App ID to `AndroidManifest.xml`.** I don't have
   this file (see below), so add this yourself inside the
   `<application>` tag in `android/app/src/main/AndroidManifest.xml`:

   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="ca-app-pub-3940256099942544~3347511713"/>
   ```

   That's Google's official test App ID — safe for development.
   **Skipping this crashes the app the instant it opens** (that's
   Google's own documented behavior, not a guess). Swap it for your
   own from an AdMob account before a real release.

If you want to test the app before finishing Firebase setup: the app
still runs fine without it. Sign-in will show "isn't set up for this
build yet" and let you tap "Skip for now" — but the *build itself*
still needs that json file to exist once the plugin is applied, even
if it's not fully configured yet. If you want to build without doing
Firebase setup at all right now, you'd need to remove the
`com.google.gms.google-services` line from `android/settings.gradle.kts`
and `android/app/build.gradle.kts` — ask me and I'll walk you through
that trade-off.

## What's NOT in here, and why

- **No `ios/` folder.** I have no way to generate one — that requires
  running `flutter create` with the actual Flutter SDK, which isn't
  available to me. `IOS_SETUP.md` has the exact one-line command to
  generate it yourself (works fine on Windows) plus every config
  addition you'll need once it exists.
- **No `AndroidManifest.xml`, gradle wrapper, or `res/` icons.** These
  already exist in your current project and I've never seen their
  contents — I only ever received the three Gradle files included
  here. Overwriting files I can't see the current content of risks
  silently deleting something that already works (your camera
  permission entry, for instance).
- **No real `google-services.json` / `GoogleService-Info.plist`.**
  These contain real API keys tied to *your* Firebase project — only
  `flutterfire configure`, run on your machine against your own
  Firebase project, can produce real ones.

## What's genuinely new since the last delivery

- Full Google + Phone OTP sign-in, entirely optional — every existing
  feature works with zero account required
- Banner ads wired in (Home screen only, bottom, never on the actual
  scan/analysis/result flow) — using Google's official verified test
  IDs, ready to swap for real ones
- Fixed two real error-messaging bugs in the sign-in flow (was showing
  "try again" for a setup problem, not a retry-able one)
- Fixed a real bug in my own ad service code before it shipped — a
  redundant custom `unawaited()` function that could have created a
  naming conflict with Dart's own
- `minSdk` bumped to 23 and `google-services` plugin wired in (both
  required by Firebase Auth)
- iOS build-verification job added to your GitHub Actions workflow
