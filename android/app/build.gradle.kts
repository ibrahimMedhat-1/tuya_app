import org.jetbrains.kotlin.util.profile

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.zerotechiot.eg"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.zerotechiot.eg"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a","x86","x86_64")
        }
    }
    packagingOptions {
        jniLibs {
            pickFirsts += setOf("lib/*/liblog.so", "lib/*/libc++_shared.so", "lib/*/libyuv.so", "lib/*/libopenh264.so", "lib/*/libv8wrapper.so", "lib/*/libv8android.so")
        }
    }

    signingConfigs {
        create("release") {
            storeFile = file("C:/ZeroTech Github demo/tuya-ui-bizbundle-android-demo/sha 256.jks")
            storePassword = "abdo_Iot808"
            keyAlias = "key0"
            keyPassword = "abdo_Iot808"
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("release")
        }


        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://github.com/Kotlin/kotlinx.serialization/releases") }
        maven { url = uri("https://maven-other.tuya.com/repository/maven-releases/") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://oss.sonatype.org/content/repositories/snapshots/") }
        maven { url = uri("https://oss.sonatype.org/content/repositories/snapshots/") }
        maven { url = uri("https://maven-other.tuya.com/repository/maven-releases/") }
        maven { url = uri("https://maven-other.tuya.com/repository/maven-commercial-releases/") }
        maven { url = uri("https://jitpack.io") }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.jar", "*.aar"))))
    implementation("com.alibaba:fastjson:2.0.58")
    implementation("com.squareup.okhttp3:okhttp-urlconnection:5.1.0")
    implementation("com.thingclips.smart:thingsmart:6.7.3")
    implementation("com.thingclips.smart:thingsmart-bizbundle-family:6.7.0")
    implementation("com.thingclips.smart:thingsmart-panel-caller:6.7.0")
    implementation("com.thingclips.smart:thingsmart-bizbundle-scene:6.7.0")

    implementation("androidx.appcompat:appcompat:1.7.1")
    implementation("androidx.recyclerview:recyclerview:1.3.2")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.swiperefreshlayout:swiperefreshlayout:1.1.0")
    implementation("com.github.bumptech.glide:glide:4.16.0")
}
