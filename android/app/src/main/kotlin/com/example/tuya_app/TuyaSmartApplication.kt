package com.zerotechiot.eg

import android.app.Application
import android.util.Log
 import com.thingclips.smart.home.sdk.ThingHomeSdk

/**
 * Custom Application class for initializing Tuya SDK
 * This follows the official Tuya SDK v3.25.0 documentation and sample
 */
class TuyaSmartApplication : Application() {
    private val TAG = "TuyaSmartApplication"

    // App key and secret from Tuya Developer Platform
    private val APP_KEY = "xxft3fqw93d375ucppkn"
    private val APP_SECRET = "k8u9edtefgrwcmkqaesra9gmgmpuh8uy"

      fun initSdk() { // Add savedInstanceState parameter

        Log.d(TAG, "TuyaSmartApplication onCreate()")

        // Enable debug mode during development
        ThingHomeSdk.setDebugMode(true)

        // Initialize the SDK with application context, appKey and appSecret
        ThingHomeSdk.init(this, APP_KEY, APP_SECRET)

        // Set callback for login requirement
        Log.d(TAG, "Tuya SDK pre-initialization complete")
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "TuyaSmartApplication's own onCreate() called")
        initSdk() // <<---- CORRECT PLACE TO CALL THIS
    }
}