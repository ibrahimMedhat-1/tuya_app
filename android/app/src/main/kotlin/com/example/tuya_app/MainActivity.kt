package com.zerotechiot.eg // Updated package name

// Removed: import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AppCompatActivity
import com.thingclips.smart.android.user.api.ILoginCallback
import com.thingclips.smart.android.user.bean.User
import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.home.sdk.bean.HomeBean
import com.thingclips.smart.home.sdk.callback.IThingGetHomeListCallback
// import com.thingclips.smart.sdk.api.IResultCallback // Not directly used in the provided snippet
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() { // Now extends only FlutterActivity
    private val channel = "com.zerotechiot.eg/tuya_sdk"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channel
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                "initSDK" -> TuyaMethods().initTuyaSdk(result) // Calling method from TuyaMethods class

                else -> result.notImplemented()
            }
        }
    }
}

class TuyaMethods  : AppCompatActivity()  {
      fun initTuyaSdk(result: MethodChannel.Result) {
        val appKey = "xxft3fqw93d375ucppkn"
        val appSecret = "k8u9edtefgrwcmkqaesra9gmgmpuh8uy"
        try {
            // Ensure ThingHomeSdk.init has access to the Application context
            // In a FlutterActivity, 'application' is available.
            ThingHomeSdk.init(application, appKey, appSecret)
            // The SDK init is synchronous, so we can assume success if no exception is thrown.
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
