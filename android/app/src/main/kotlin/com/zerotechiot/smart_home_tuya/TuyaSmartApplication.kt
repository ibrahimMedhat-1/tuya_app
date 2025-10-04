package com.zerotechiot.smart_home_tuya

import android.util.Log
import androidx.multidex.MultiDexApplication
import com.tuya.smart.home.sdk.TuyaHomeSdk
import com.tuya.smart.sdk.api.INeedLoginListener

/**
 * Custom Application class for initializing Tuya SDK
 * This follows the official Tuya SDK v3.25.0 documentation and sample
 */
class TuyaSmartApplication : MultiDexApplication() {
    private val TAG = "TuyaSmartApplication"
    
    // App key and secret from Tuya Developer Platform
    private val APP_KEY = "xvtf3fqw93d37sucppkn"
    private val APP_SECRET = "k8u9edtefgrwcmxqaesra9gmmpuh8uy"

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "TuyaSmartApplication onCreate()")
        
        // TODO: Tuya SDK initialization is temporarily disabled due to native library issues
        // The app will run without Tuya functionality for now
        // To enable Tuya SDK, uncomment the code below and ensure proper security algorithm integration
        
        Log.d(TAG, "Tuya SDK initialization temporarily disabled - app will run without Tuya functionality")
        
        /*
        // Initialize Tuya SDK in a separate thread to avoid blocking the main thread
        Thread {
            try {
                Log.d(TAG, "Starting Tuya SDK v3.25.0 initialization in background...")
                
                // Enable debug mode during development
                TuyaHomeSdk.setDebugMode(true)
                Log.d(TAG, "Debug mode enabled")
                
                // Initialize the SDK with application context, appKey and appSecret
                TuyaHomeSdk.init(this@TuyaSmartApplication, APP_KEY, APP_SECRET)
                Log.d(TAG, "Tuya SDK init called")
                
                // Set callback for login requirement
                TuyaHomeSdk.setOnNeedLoginListener(INeedLoginListener {
                    Log.d(TAG, "Need login callback triggered")
                    // Here we could navigate user to login screen
                })
                
                Log.d(TAG, "Tuya SDK v3.25.0 initialization complete")
            } catch (e: Exception) {
                Log.e(TAG, "Error during Tuya SDK initialization: ${e.message}")
                Log.e(TAG, "Stack trace: ${e.stackTraceToString()}")
                // Continue app initialization even if Tuya SDK fails
                // This allows the app to run and show the UI for testing
            }
        }.start()
        */
    }
} 