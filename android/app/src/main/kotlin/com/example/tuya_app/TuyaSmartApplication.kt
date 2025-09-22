package com.zerotechiot.eg

import android.app.Application
import com.thingclips.smart.home.sdk.ThingHomeSdk

class TuyaSmartApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        ThingHomeSdk.init(this, "xxft3fqw93d375ucppkn", "k8u9edtefgrwcmkqaesra9gmgmpuh8uy")
        ThingHomeSdk.setDebugMode(true)
    }
}