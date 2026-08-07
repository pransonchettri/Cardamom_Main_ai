# iOS configuration additions for CardamomAI

You don't have an `ios/` folder yet, and I can't generate a complete
one myself (that requires the Flutter SDK, which isn't available in
my environment). Here's exactly how to get one, and what to add to it.

## Step 1 — Generate the iOS folder (Windows is fine for this)

From your project root:

    flutter create --platforms=ios .

This only *scaffolds* the standard iOS project files — it does not
compile anything, so it works fine on Windows. Compiling/testing it
for real requires a Mac with Xcode, or the `build-ios` job already
added to your GitHub Actions workflow (which builds on a free macOS
runner, but produces an unsigned build — see the comment in that
workflow file for why an installable .ipa additionally needs an Apple
Developer Program membership).

## Step 2 — Add these permission descriptions

Open `ios/Runner/Info.plist` and add these keys inside the outermost
`<dict>` (anywhere alongside the other `<key>...</key>` pairs already
there). Without these, iOS kills the app the instant it tries to use
the camera or photo library — these strings are what iOS shows the
user in the permission prompt.

```xml
<key>NSCameraUsageDescription</key>
<string>CardamomAI needs camera access to scan cardamom leaves for disease detection.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>CardamomAI needs photo library access so you can choose an existing photo of a leaf to scan.</string>
```

## Step 3 — Add Google Sign-In's URL scheme

This only applies once you've run `flutterfire configure` (see the
Firebase Console steps from earlier) and have a real
`GoogleService-Info.plist`. Open that file, find the key
`REVERSED_CLIENT_ID`, copy its value, and add this block to
`ios/Runner/Info.plist` (replace the placeholder string with what you
copied):

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>REPLACE_WITH_YOUR_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

Also add the plain (non-reversed) `CLIENT_ID` value as its own key:

```xml
<key>GIDClientID</key>
<string>REPLACE_WITH_YOUR_CLIENT_ID</string>
```

## Step 4 — Bump the minimum iOS version

Open `ios/Podfile`, find the commented-out line near the top that
looks like `# platform :ios, '13.0'`, uncomment it, and change the
version to at least 15.0 (Firebase's current SDKs require this):

```ruby
platform :ios, '15.0'
```

## Step 5 — Add GoogleService-Info.plist

From the Firebase Console, download `GoogleService-Info.plist` for
your iOS app and place it directly in `ios/Runner/` (the actual file,
not a copy elsewhere) — Xcode/CocoaPods expects it exactly there.

## Step 6 — Add the AdMob App ID

This one is required or **the app crashes on launch** — not just "no
ads show," an actual crash, per Google's own docs. Add this to
`ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
```

That's Google's official test App ID — safe to leave in during
development. Before a real release, replace it with your own from
your AdMob account, and swap the matching test ad unit ID in
`lib/services/ad_service.dart` (marked with a TODO comment) too.

---

None of this can be verified by me without a real Mac, so if
something doesn't look right once you have Xcode access, the exact
error message is the fastest way for me to help.
