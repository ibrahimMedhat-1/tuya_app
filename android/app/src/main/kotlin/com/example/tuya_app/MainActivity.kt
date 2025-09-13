package com.zerotechiot.eg

import android.app.Application
import com.thingclips.smart.android.user.api.ILoginCallback
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
                "initSDK" -> {
                    // SDK is already initialized in Application.onCreate()
                    result.success("Tuya SDK initialized successfully")
                }

                "isSDKInitialized" -> {
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Clean up SDK resources when app is destroyed
        ThingHomeSdk.onDestroy()
    }
}
class TuyaApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Initialize Tuya SDK - this must be done in Application.onCreate()
        ThingHomeSdk.init(this)
        // Enable debug mode for development (disable in production)
        ThingHomeSdk.setDebugMode(true)
    }
}