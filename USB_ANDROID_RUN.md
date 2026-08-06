# Run on an Android phone over USB

## What was corrected

`android/gradle.properties` contained two `org.gradle.jvmargs` values. The
second value overrode the first, removing the intended memory settings. The
file now has one complete setting and compiles Kotlin in Gradle's process,
which avoids the cancelled Kotlin compiler daemon recorded by prior builds.

No Dart UI, features, assets, model, or package dependencies were removed or
redesigned.

## One-time Windows setup

This project uses Gradle 9.1, which requires Java 17 or newer. In a new
PowerShell window, point this session at Android Studio's bundled runtime:

```powershell
$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
java -version
```

Do not use Java 8 for this project. The output must show Java 17 or newer.

If Gradle reports `PKIX path building failed` while downloading from Google or
Maven, your network is intercepting HTTPS with a certificate that this Java
runtime does not trust. Install your organisation/proxy root certificate into
the Java runtime's trust store (ask the network administrator for the
certificate), or use an unrestricted home/mobile network. Do not disable TLS
verification.

## USB debugging and running

1. On the phone, enable **Developer options** (tap *Build number* seven times),
   then enable **USB debugging**.
2. Connect with a data-capable USB-A-to-C cable, select **File transfer** if
   Android asks, and accept the phone's **Allow USB debugging** fingerprint
   prompt.
3. From this project folder, run:

   ```powershell
   adb devices
   flutter pub get
   flutter run
   ```

   The device must appear as `device`, not `unauthorized` or `offline`. If it
   is `unauthorized`, unlock the phone and accept the prompt; if it does not
   appear, try another data cable/USB port and install the phone maker's USB
   driver.

4. The app will ask for camera access when the scanner is opened. Allow it in
   Android settings if it was denied previously.
