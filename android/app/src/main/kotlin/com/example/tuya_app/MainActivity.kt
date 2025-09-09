package com.example.tuya_app

import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.home.sdk.bean.HomeBean
import com.thingclips.smart.home.sdk.callback.IThingGetHomeListCallback
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(){
    private val channel = "com.example.tuya/sdk"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "initSDK" -> {
                    val appKey = "xxft3fqw93d375ucppkn"
                    val appSecret = "k8u9edtefgrwcmkqaesra9gmgmpuh8uy"
                    try {
                        ThingHomeSdk.init(application, appKey, appSecret)
                        result.success("Tuya SDK Initialized")
                    } catch (e: Exception) {
                        result.error("SDK_INIT_ERROR", "Failed to initialize Tuya SDK", e.localizedMessage)
                    }
                }

                "getHomeList" -> {
                    ThingHomeSdk.getHomeManagerInstance().queryHomeList(  object:IThingGetHomeListCallback {
                        override fun onSuccess(homes: List<HomeBean>?) {
                            val homeList = homes?.map { home ->
                                mapOf("homeId" to home.homeId, "name" to home.name)
                            }
                            result.success(homeList)
                        }

                        override fun onError(errorCode: String?, errorMsg: String?) {
                            result.error(errorCode ?: "HOME_LIST_ERROR", errorMsg ?: "Failed to get home list", null)
                        }
                    })
                }
                else -> result.notImplemented()
            }
        }
    }
}
