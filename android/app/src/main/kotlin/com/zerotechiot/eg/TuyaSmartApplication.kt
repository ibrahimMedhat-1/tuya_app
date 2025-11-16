package com.zerotechiot.eg

import android.app.Application
import android.content.Context
import android.util.Log
import androidx.multidex.MultiDex
import com.facebook.soloader.SoLoader
import com.thingclips.smart.api.MicroContext
import com.thingclips.smart.api.router.UrlBuilder
import com.thingclips.smart.api.service.RedirectService
import com.thingclips.smart.api.service.RouteEventListener
import com.thingclips.smart.api.service.ServiceEventListener
import com.thingclips.smart.bizbundle.initializer.BizBundleInitializer
import com.thingclips.smart.commonbiz.bizbundle.family.api.AbsBizBundleFamilyService
import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.thingpackconfig.PackConfig
import dagger.hilt.android.HiltAndroidApp

/**
 * Tuya Smart Application
 * Based on working ZeroTech project implementation
 * 
 * CRITICAL COMPONENTS:
 * 1. Direct SDK init with AppKey/Secret (not metadata)
 * 2. PackConfig delegation for BizBundle configuration
 * 3. Custom FamilyService registration (stores home context)
 * 4. RedirectService URL interceptor
 * 5. Hilt for dependency injection (required for UI BizBundle)
 */
@HiltAndroidApp
class TuyaSmartApplication : Application() {
    
    companion object {
        private const val TAG = "TuyaSDK"
        
        // Tuya App Credentials
        private const val APP_KEY = "xxft3fqw93d375ucppkn"
        private const val APP_SECRET = "k8u9edtefgrwcmkqaesra9gmgmpuh8uy"
    }
    
    override fun onCreate() {
        super.onCreate()
        SoLoader.init(this, false)
        
        // Initialize Tuya SDK
        com.thingclips.smart.api.start.LauncherApplicationAgent.getInstance().onCreate(this)
        ThingHomeSdk.setDebugMode(true)
        
        // Initialize BizBundle with proper service event listener
        BizBundleInitializer.init(
            this,
            null,  // RouteEventListener
            null   // ServiceEventListener
        )
        BizBundleInitializer.registerService<AbsBizBundleFamilyService?, AbsBizBundleFamilyService?>(
            AbsBizBundleFamilyService::class.java,
            BizBundleFamilyServiceImpl()
        )


    }
    private fun initializeDatabase() {
        try {
            // Clear any corrupted database files
            val databaseFiles = listOf(
                "tuya_smart.db",
                "tuya_smart.db-journal",
                "tuya_smart.db-wal",
                "tuya_smart.db-shm"
            )

            databaseFiles.forEach { dbFile ->
                try {
                    val file = getDatabasePath(dbFile)
                    if (file.exists() && file.length() == 0L) {
                        file.delete()
                        Log.d(TAG, "   Deleted corrupted database file: $dbFile")
                    }
                } catch (e: Exception) {
                    Log.w(TAG, "   Could not check/delete database file: $dbFile", e)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "   Error during database initialization", e)
        }}
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        Log.d(TAG, "Installing MultiDex...")
        MultiDex.install(this)
    }
}
