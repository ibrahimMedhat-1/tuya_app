package com.zerotechiot.eg

import android.app.Application
import android.util.Log
import com.thingclips.smart.api.start.LauncherApplicationAgent
import com.thingclips.smart.bizbundle.initializer.BizBundleInitializer
import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.optimus.sdk.ThingOptimusSdk
import com.thingclips.smart.theme.ThingThemeInitializer
import com.thingclips.smart.theme.config.ThemeConfig
import com.thingclips.smart.theme.core.extension.AppUiMode
import com.thingclips.smart.theme.util.NightModeUtil
import com.thingclips.smart.utils.FrescoManager

class TuyaSmartApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        ThingHomeSdk.init(this, "xxft3fqw93d375ucppkn", "k8u9edtefgrwcmkqaesra9gmgmpuh8uy")
         LauncherApplicationAgent.getInstance().onCreate(this)
         FrescoManager.initFresco(this);        // Initialize Tuya SDK with proper callback to ensure theme initialization happens AFTER SDK is ready
            NightModeUtil.setAppNightMode(AppUiMode.MODE_LIGHT)
            ThemeConfig.setTheme(true)
        ThingThemeInitializer.init(this)
        ThingOptimusSdk.init(this);
    }
}