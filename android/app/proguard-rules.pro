# Tuya SDK ProGuard rules
-keep class com.alibaba.fastjson.**{*;}
-dontwarn com.alibaba.fastjson.**

# MQTT
-keep class com.thingclips.smart.mqttclient.mqttv3.** { *; }
-dontwarn com.thingclips.smart.mqttclient.mqttv3.**

# OkHttp3
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-keep class okio.** { *; }
-dontwarn okio.**

# Tuya SDK
-keep class com.thingclips.**{*;}
-dontwarn com.thingclips.**

# Matter SDK
-keep class chip.** { *; }
-dontwarn chip.**

# MINI SDK
-keep class com.gzl.smart.** { *; }
-dontwarn com.gzl.smart.**

# ═══════════════════════════════════════════════════════════════════
# React Native and BizBundle ProGuard Rules
# Based on: https://github.com/tuya/tuya-ui-bizbundle-android-demo
# ═══════════════════════════════════════════════════════════════════

# React Native
-keep class com.facebook.react.** { *; }
-keep class com.facebook.hermes.** { *; }
-keep class com.facebook.jni.** { *; }
-keep class com.facebook.soloader.** { *; }
-dontwarn com.facebook.react.**
-dontwarn com.facebook.hermes.**

# BizBundle Panel (React Native-based panels)
-keep class com.thingclips.smart.panel.** { *; }
-keep class com.thingclips.smart.panelcaller.** { *; }
-keep class com.thingclips.smart.bizbundle.** { *; }
-dontwarn com.thingclips.smart.panel.**
-dontwarn com.thingclips.smart.panelcaller.**

# JSC (JavaScript Core)
-keep class org.webkit.** { *; }
-dontwarn org.webkit.**

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep React Native ViewManagers
-keep public class * extends com.facebook.react.uimanager.ViewManager {
    *;
}

# Keep React Native Modules
-keep public class * extends com.facebook.react.bridge.ReactContextBaseJavaModule {
    *;
}
-keep public class * extends com.facebook.react.bridge.JavaScriptModule {
    *;
}

# ═══════════════════════════════════════════════════════════════════
# CRITICAL: Compression/Decompression Libraries for BizBundle Extraction
# ═══════════════════════════════════════════════════════════════════

# Keep all compression/decompression classes (needed for panel bundle extraction)
-keep class java.util.zip.** { *; }
-keep class org.apache.commons.compress.** { *; }
-dontwarn org.apache.commons.compress.**

# Keep file I/O classes
-keep class java.io.** { *; }
-keep class java.nio.** { *; }

# Keep Apache Commons IO (used for file operations)
-keep class org.apache.commons.io.** { *; }
-dontwarn org.apache.commons.io.**

# Keep Tuya download and panel extraction classes
-keep class com.thingclips.smart.android.common.download.** { *; }
-keep class com.thingclips.smart.panel.download.** { *; }
-keep class com.thingclips.smart.panel.react_native.** { *; }
-dontwarn com.thingclips.smart.android.common.download.**
-dontwarn com.thingclips.smart.panel.download.**

# ═══════════════════════════════════════════════════════════════════
# Missing classes - ignore warnings for optional dependencies
# ═══════════════════════════════════════════════════════════════════

# Alibaba FastJSON optional dependencies
-dontwarn com.alibaba.fastjson2.support.odps.**
-dontwarn com.alibaba.fastjson2.support.AwtRederModule**
-dontwarn com.alibaba.fastjson2.support.redission.**
-dontwarn com.alibaba.fastjson2.support.retrofit.**

# Google Play Core (optional for split installs)
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Huawei HMS (optional)
-dontwarn com.huawei.**
-dontwarn com.huawei.hms.**
-dontwarn com.huawei.hianalytics.**
-dontwarn com.huawei.libcore.io.**

# Java AWT (not available on Android)
-dontwarn java.awt.**

# Redisson (optional)
-dontwarn org.redisson.**

# Retrofit (optional)
-dontwarn retrofit2.**