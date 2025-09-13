package com.zerotechiot.eg

import android.app.Application
import com.thingclips.smart.home.sdk.ThingHomeSdk
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "com.zerotechiot.eg/tuya_sdk"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "initSDK" -> TuyaMethods().initTuyaSdk(   result)
                else -> result.notImplemented()
            }
        }
    }
}

class TuyaMethods : Application() {
    fun initTuyaSdk(  result: MethodChannel.Result) {
        val appKey = "xxft3fqw93d375ucppkn"
        val appSecret = "k8u9edtefgrwcmkqaesra9gmgmpuh8uy"

        try {
            // Get the Application context from the activity

            ThingHomeSdk.init(this, appKey, appSecret)
            result.success("Tuya SDK initialized successfully.")
        } catch (e: Exception) {
            result.error(
                "SDK_INIT_ERROR",
                "Failed to initialize Tuya SDK",
                e.message
            )
        }
    }
}