# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Tuya SDK
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