plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.plant_ai"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.plant_ai"
        // Firebase Auth's Android AAR declares minSdkVersion 23 in its own
        // manifest. Gradle's manifest merger hard-fails the build if the
        // app's effective minSdk is lower, so this must be pinned explicitly
        // rather than left at Flutter's own default (currently lower).
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// Fixes: "class file for androidx.concurrent.futures.CallbackToFutureAdapter
// not found" during camera_android_camerax compilation. camera-core's own
// Maven POM declares this as a runtime-scope dependency, which isn't always
// enough for the compiler to resolve JSpecify type annotations at compile
// time - declaring it explicitly here (verified fix, confirmed via a real
// minimal-reproduction build) closes that gap.
dependencies {
    implementation("androidx.concurrent:concurrent-futures:1.2.0")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
