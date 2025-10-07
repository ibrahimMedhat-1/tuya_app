package com.zerotechiot.eg

import android.app.Application
import android.util.Log
import com.facebook.drawee.backends.pipeline.Fresco
import com.thingclips.smart.home.sdk.ThingHomeSdk

/**
 * Custom Application class for initializing Tuya SDK and BizBundle
 * Based on stable working app structure
 */
class TuyaSmartApplication : Application() {
    private val TAG = "TuyaSmartApplication"

    // App key and secret from Tuya Developer Platform
    private val APP_KEY = "xxft3fqw93d375ucppkn"
    private val APP_SECRET = "k8u9edtefgrwcmkqaesra9gmgmpuh8uy"

    fun initSdk() {
        Log.d(TAG, "Initializing Tuya SDK and BizBundle")

        // Initialize Fresco (required by BizBundle UI components)
        Fresco.initialize(this)
        Log.d(TAG, "Fresco initialized")

        // Enable debug mode during development
        ThingHomeSdk.setDebugMode(true)

        // Initialize the SDK with application context, appKey and appSecret
        ThingHomeSdk.init(this, APP_KEY, APP_SECRET)

        Log.d(TAG, "Tuya SDK initialized successfully")
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "TuyaSmartApplication's own onCreate() called")
        initSdk()
    }
}