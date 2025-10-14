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

# Additional dontwarn rules for build issues
-dontwarn com.alibaba.fastjson2.support.**
-dontwarn com.google.android.play.core.**
-dontwarn com.huawei.**
-dontwarn com.google.j2objc.annotations.**
-dontwarn com.aliyun.odps.**
-dontwarn java.awt.**
-dontwarn org.redisson.**
-dontwarn retrofit2.**