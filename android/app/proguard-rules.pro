# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Tuya SDK v6.4.0
-keep class com.thingclips.**{*;}
-keep class com.tuya.**{*;}
-keep class com.tuyasmart.**{*;}
-keep class com.thing.**{*;}

# OkHttp
-dontwarn okhttp3.**
-keep class okhttp3.**{*;}

# Okio
-dontwarn okio.**
-keep class okio.**{*;}

# FastJson
-dontwarn com.alibaba.fastjson.**
-keep class com.alibaba.fastjson.**{*;}

# Keep methods that are accessed via reflection
-keepclassmembers class * {
    public <methods>;
}

# MQTT
-keep class org.eclipse.paho.client.mqttv3.** { *; }
-dontwarn org.eclipse.paho.client.mqttv3.**

# Weaver
-keep class androidx.appcompat.widget.** { *; }

# Protobuf
-keep class com.google.protobuf.** { *; }

# Keep the custom application class
-keep class com.zerotechiot.smart_home_tuya.TuyaSmartApplication { *; }
-keep class com.zerotechiot.smart_home_tuya.MainActivity { *; }

# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /usr/local/Cellar/android-sdk/24.3.3/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Keep R classes that will be referenced from native code
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Tuya Smart SDK specific rules
-keep class com.thingclips.** { *; }
-keep class com.tuyasmart.** { *; }
-keep class com.tuya.** { *; }

# OkHttp
-dontwarn okhttp3.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# FastJSON
-dontwarn com.alibaba.fastjson.**
-keep class com.alibaba.fastjson.** { *; }

# Network and image loading libraries
-dontwarn okio.**
-keep class okio.** { *; }

# Tuya security algorithm
-keep class com.thingclips.security.** { *; }

# Flutter specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Required by Flutter method channels
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
} 