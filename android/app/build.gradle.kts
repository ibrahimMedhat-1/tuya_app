plugins {
//    id("com.thingclips.open.theme")
    id("com.android.application")
    id("kotlin-android")
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
        applicationId = "com.zerotechiot.eg"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // CRITICAL: Enable MultiDex for large app
        multiDexEnabled = true
        
        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64")
        }
        
        // Support for 16KB page size (required for Google Play and Android 15+)
        // This ensures the app works on devices with 16KB page size
        externalNativeBuild {
            cmake {
                arguments += listOf("-DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON")
            }
        }
    }

    packaging {
        jniLibs {
            pickFirsts += "lib/armeabi-v7a/liblog.so"
            pickFirsts += "lib/arm64-v8a/liblog.so"
            pickFirsts += "lib/x86/liblog.so"
            pickFirsts += "lib/x86_64/liblog.so"
            pickFirsts += "lib/*/libc++_shared.so"
            pickFirsts += "lib/*/libyuv.so"
            pickFirsts += "lib/*/libopenh264.so"
            pickFirsts += "lib/*/libv8wrapper.so"
            pickFirsts += "lib/*/libv8android.so"
            pickFirsts += "lib/*/libsqlcipher.so"
            pickFirsts += "lib/*/libwcdb.so"
        }
    }

    signingConfigs {
        create("release") {
            storeFile = file("/Users/ibrahim/StudioProjects/tuya_app/android/app/sha 256.jks")
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
        maven { url = uri("https://maven-aliyun.com/repository/public") }
        maven { url = uri("https://oss.sonatype.org/content/repositories/snapshots/") }
        maven { url = uri("https://maven-other.tuya.com/repository/maven-commercial-releases/") }
        maven { url = uri("https://maven-other.tuya.com/repository/maven-snapshots/") }
        maven { url = uri("https://jitpack.io") }
        maven { url = uri("https://central.maven.org/maven2/") }
        maven { url = uri("https://developer.huawei.com/repo/") }
        // Add repository for ImmersionBar
        maven { url = uri("https://maven.aliyun.com/repository/jcenter") }
        // Add JCenter for ImmersionBar
        maven { url = uri("https://jcenter.bintray.com/") }
    }
}

flutter {
    source = "../.."
}

configurations.all {
    exclude(group = "com.squareup.okhttp3", module = "okhttp-jvm")
    resolutionStrategy {
        force("com.squareup.okhttp3:okhttp:4.12.0")
    }
}

dependencies {
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.jar", "*.aar"))))
    implementation("com.alibaba:fastjson:2.0.59")
    
    // Force specific versions to avoid conflicts
    implementation("com.squareup.okhttp3:okhttp:5.2.0")
    implementation("com.squareup.okhttp3:okhttp-urlconnection:5.2.1")
    implementation("commons-io:commons-io:2.20.0")

    // Main Tuya SDK - use consistent version
    implementation("com.thingclips.smart:thingsmart:6.7.3") {
        exclude(module = "thingsmart-modularCampAnno")
        exclude(group = "com.squareup.okhttp3", module = "okhttp-jvm")
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }

    // Tuya expansion SDK
    implementation("com.thingclips.smart:thingsmart-expansion-sdk:6.7.0") {
        exclude(group = "com.squareup.okhttp3", module = "okhttp-jvm")
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }

    // Tuya BizBundle BOM for version management - MUST use platform()
    implementation(platform("com.thingclips.smart:thingsmart-BizBundlesBom:6.7.31"))
    
    // Device Control UI BizBundle - REQUIRED (version managed by BOM)
    implementation("com.thingclips.smart:thingsmart-bizbundle-panel") {
        exclude(group = "net.zetetic", module = "android-database-sqlcipher")
        exclude(group = "com.tencent.wcdb", module = "wcdb-android")
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }
    
    // Family BizBundle - REQUIRED for home management (version managed by BOM)
    implementation("com.thingclips.smart:thingsmart-bizbundle-family") {
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }
    
    // Scene BizBundle - for smart scenes and automation (version managed by BOM)
    implementation("com.thingclips.smart:thingsmart-bizbundle-scene") {
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }
    
    // MiniApp BizBundle
    implementation("com.thingclips.smart:thingsmart-bizbundle-miniapp") {
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }
    
    implementation("com.thingclips.smart:thingsmart-bizbundle-homekit") {
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }
    
    implementation("com.thingclips.smart:thingsmart-bizbundle-ipckit") {
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }
    
    implementation("com.thingclips.smart:thingsmart-bizbundle-p2pkit") {
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }
    
    implementation("com.thingclips.smart:thingsmart-bizbundle-camera_panel") {
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }
    
    // Map extension
    api("com.thingclips.smart:thingsmart-bizbundle-mapkit") {
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }
    
    // Media extension
    api("com.thingclips.smart:thingsmart-bizbundle-mediakit") {
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }
    
    api("com.thingclips.smart:thingsmart-ipcsdk:6.7.2") {
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }
    
    // Basic extension capabilities - REQUIRED (version managed by BOM)
    implementation("com.thingclips.smart:thingsmart-bizbundle-basekit") {
        exclude(group = "net.zetetic", module = "android-database-sqlcipher")
        exclude(group = "com.tencent.wcdb", module = "wcdb-android")
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }
    
    // Business extension capabilities - REQUIRED (version managed by BOM)
    implementation("com.thingclips.smart:thingsmart-bizbundle-bizkit") {
        exclude(group = "net.zetetic", module = "android-database-sqlcipher")
        exclude(group = "com.tencent.wcdb", module = "wcdb-android")
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }
    
    // Device control capabilities - REQUIRED (version managed by BOM)
    implementation("com.thingclips.smart:thingsmart-bizbundle-devicekit") {
        exclude(group = "net.zetetic", module = "android-database-sqlcipher")
        exclude(group = "com.tencent.wcdb", module = "wcdb-android")
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }
    
    // Device Activator BizBundle (version managed by BOM)
    implementation("com.thingclips.smart:thingsmart-bizbundle-device_activator") {
        exclude(group = "com.squareup.okhttp3", module = "okhttp-jvm")
        exclude(group = "net.zetetic", module = "android-database-sqlcipher")
        exclude(group = "com.tencent.wcdb", module = "wcdb-android")
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }
    
    // BizBundle Initializer - CRITICAL for BizBundle to work (version managed by BOM)
    implementation("com.thingclips.smart:thingsmart-bizbundle-initializer") {
        exclude(group = "com.squareup.okhttp3", module = "okhttp-jvm")
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
    }

    // Tuya theme SDK - required for BizBundle UI
    implementation("com.thingclips.smart:thingsmart-theme-open:2.0.6")
    
    // CRITICAL: MultiDex - required for large app with many dependencies
    implementation("androidx.multidex:multidex:2.0.1")

    // Android dependencies
    implementation("androidx.appcompat:appcompat:1.7.1")
    implementation("androidx.core:core-ktx:1.17.0")
    implementation("com.google.android.material:material:1.13.0")
}
