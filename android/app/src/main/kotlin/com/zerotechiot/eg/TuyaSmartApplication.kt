package com.zerotechiot.eg

import android.app.Application
import android.os.Handler
import android.os.Looper
import com.facebook.soloader.SoLoader
import com.thingclips.smart.api.start.LauncherApplicationAgent
import com.thingclips.smart.bizbundle.initializer.BizBundleInitializer
import com.thingclips.smart.home.sdk.ThingHomeSdk

class TuyaSmartApplication : Application() {
    
    override fun onCreate() {
        super.onCreate()
        SoLoader.init(this, false)
        ThingHomeSdk.init(this)
        LauncherApplicationAgent.getInstance().onCreate(this)
        BizBundleInitializer.init(
            this,
            null,  // RouteEventListener
            null   // ServiceEventListener
        )
    }
}
