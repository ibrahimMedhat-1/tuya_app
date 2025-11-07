pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.13.0" apply false
    // Kotlin 2.0.21 - stable version with good Hilt support
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
    // Hilt 2.50 plugin for dependency injection (required for UI BizBundle)
    id("com.google.dagger.hilt.android") version "2.50" apply false
    // KSP for annotation processing (works better with Kotlin 2.x than KAPT)
    id("com.google.devtools.ksp") version "2.0.21-1.0.28" apply false
}

include(":app")
