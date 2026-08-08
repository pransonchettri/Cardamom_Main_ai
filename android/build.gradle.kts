import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Force every plugin module (everything except :app, which is already
// correctly configured and gets evaluated too early for afterEvaluate to
// be safe on it) to match Java 17 / Kotlin 17 AFTER each plugin's own
// build script has finished running — so our value is the final word,
// not something the plugin's own script can silently overwrite.
subprojects {
    if (project.name != "app") {
        afterEvaluate {
            extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
            tasks.withType<KotlinCompile>().configureEach {
                compilerOptions {
                    jvmTarget.set(JvmTarget.JVM_17)
                }
            }
        }
    }
}

// camera_android_camerax fails to compile on its own without this:
// "Cannot attach type annotations @org.jspecify.annotations.NonNull to
// SurfaceRequest.mSurfaceRecreationCompleter: class file for
// androidx.concurrent.futures.CallbackToFutureAdapter not found".
// camera-core's Maven POM declares concurrent-futures as runtime-scope only,
// which isn't enough for javac to resolve JSpecify type annotations at
// compile time for THIS module's own build. A previous fix added this same
// dependency to android/app/build.gradle.kts instead - that has no effect
// here, since :app's dependencies don't reach backward into how a separate
// Gradle subproject compiles its own sources. It has to be declared on the
// subproject that actually fails to compile.
subprojects {
    if (project.name == "camera_android_camerax") {
        afterEvaluate {
            dependencies.add("implementation", "androidx.concurrent:concurrent-futures:1.2.0")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
