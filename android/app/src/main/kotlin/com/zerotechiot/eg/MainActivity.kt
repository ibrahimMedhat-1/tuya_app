package com.zerotechiot.eg

import android.util.Log
import com.thingclips.smart.android.user.api.ILoginCallback
import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.android.user.bean.User
import com.thingclips.smart.home.sdk.bean.HomeBean
import com.thingclips.smart.home.sdk.callback.IThingGetHomeListCallback
import com.thingclips.smart.home.sdk.callback.IThingHomeResultCallback
import com.thingclips.smart.sdk.api.IResultCallback
import com.thingclips.smart.sdk.api.IThingDevice
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
                "login" -> {
                    val email = call.argument<String>("email")
                    val password = call.argument<String>("password")

                    if (email != null && password != null) {
                        loginUser(email, password, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Email and password are required", null)
                    }
                }

                "isLoggedIn" -> {
                    checkLoginStatus(result)
                }

                "getHomes" -> {
                    getHomes(result)
                }

                "getHomeDevices" -> {
                    // Consider changing to toLong() safely as discussed previously if issues persist
                    val homeId = call.argument<Int>("homeId")
                    if (homeId != null) {
                        getHomeDevices(homeId.toLong(), result) // Ensure this is Long
                    } else {
                        result.error("INVALID_ARGUMENTS", "homeId is required", null)
                    }
                }

                "controlDevice" -> {
                    val deviceId = call.argument<String>("deviceId")
                    // If your Flutter side sends a Map, this is fine.
                    // However, the current publishDps(dps.toString(), ...) in your controlDevice
                    // method might be an issue if publishDps expects a valid JSON string
                    // and dps.toString() doesn't produce it.
                    // Consider using iThingDevice.publishCommands(dps, callback) if dps is a Map.
                    val dps = call.argument<Map<String, Any>>("dps") // Changed to Map<String, Any> for flexibility
                    if (deviceId != null && dps != null) {
                        Log.d(
                            "TuyaSDK",
                            "control device dps: devId=${deviceId}, dps=${dps}"
                        )
                        controlDevice(deviceId, dps, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "deviceId and dps are required", null)
                    }
                }

//                "goToDevicePanel" -> { // New case added
//                    val deviceId = call.argument<String>("deviceId")
//                    if (deviceId != null) {
//                        goToDevicePanel(deviceId, result)
//                    } else {
//                        result.error("INVALID_ARGUMENTS", "deviceId is required", null)
//                    }
//                }

                else -> result.notImplemented()
            }
        }
    }

    private fun loginUser(email: String, password: String, result: MethodChannel.Result) {
        ThingHomeSdk.getUserInstance().loginWithEmail(
            "US", // Country code
            email,
            password,
            object : ILoginCallback {
                override fun onSuccess(user: User?) {
                    val userData = mapOf(
                        "id" to (user?.uid ?: ""),
                        "email" to (user?.email ?: email),
                        "name" to (user?.username ?: email.split("@")[0]),
                    )
                    result.success(userData)
                }

                override fun onError(code: String?, error: String?) {
                    result.error("LOGIN_FAILED", error ?: "Login failed", null)
                }
            }
        )
    }

    private fun getHomes(result: MethodChannel.Result) {
        ThingHomeSdk.getHomeManagerInstance().queryHomeList(object : IThingGetHomeListCallback {
            override fun onSuccess(homeBeans: List<HomeBean>?) {
                val homes = homeBeans?.map { home ->
                    mapOf(
                        "homeId" to home.homeId,
                        "name" to (home.name ?: "")
                    )
                } ?: emptyList()
                result.success(homes)
            }

            override fun onError(code: String?, error: String?) {
                result.error("GET_HOMES_FAILED", error ?: "Failed to get homes", null)
            }
        })
    }

    // Updated to accept Long for homeId as per previous discussion
    private fun getHomeDevices(homeId: Long, result: MethodChannel.Result) {
        ThingHomeSdk.newHomeInstance(homeId).getHomeDetail(object : IThingHomeResultCallback {
            override fun onSuccess(homeBean: HomeBean?) {
                val devices = homeBean?.deviceList?.map { device ->
                    mapOf(
                        "deviceId" to (device.devId ?: ""),
                        "name" to (device.uiName ?: ""),
                        "isOnline" to device.isOnline,
                        "image" to device.iconUrl
                    )
                } ?: emptyList()

                Log.d("TuyaSDK", "Devices: $devices")
                result.success(devices)
            }

            override fun onError(code: String?, error: String?) {
                result.error("GET_HOME_DEVICES_FAILED", error ?: "Failed to get home devices", null)
            }
        })
    }

    // Note on controlDevice:
    // If 'dps' is intended to be a structured map of DP commands,
    // consider using iThingDevice.publishCommands(dps, callback) instead of publishDps(dps.toString(), ...).
    // The dps.toString() might not produce a valid JSON string that publishDps (string variant) expects.
    // For now, I've changed the argument type to Map<String, Any> for better type safety.
    private fun controlDevice(deviceId: String, dps: Map<String, Any>, result: MethodChannel.Result) {
        val iThingDevice: IThingDevice = ThingHomeSdk.newDeviceInstance(deviceId)
        // This is the line that might need changing if dps is a map.
        // If publishDps requires a JSON string: You'd need to convert the Map to a JSON string here.
        // If you can use publishCommands (which takes a Map):
        // iThingDevice.publishCommands(dps, object : IResultCallback { ... }) would be more direct.
        // Convert Map to JSON string properly
        val jsonObject = org.json.JSONObject()
        for ((key, value) in dps) {
            jsonObject.put(key, value)
        }
        val dpsJsonString = jsonObject.toString()
        
        Log.d("TuyaSDK", "control device dps: devId=${deviceId}, dps=${dpsJsonString}")
        
        iThingDevice.publishDps(dpsJsonString, object : IResultCallback {
            override fun onError(code: String, error: String) {
                Log.d(
                    "TuyaSDK",
                    "control device error: devId=${deviceId}, dps=${dpsJsonString}, code=${code}, error=${error}"
                )
                result.error("CONTROL_DEVICE_FAILED", error, null)
            }

            override fun onSuccess() {
                Log.d("TuyaSDK", "control device success: devId=${deviceId}, dps=${dpsJsonString}")
                result.success(null)
            }
        })
    }

    private fun checkLoginStatus(result: MethodChannel.Result) {
        val user = ThingHomeSdk.getUserInstance().user
        if (user != null) {
            val userData = mapOf(
                "id" to (user.uid ?: ""),
                "email" to (user.email ?: ""),
                "name" to (user.username ?: "")
            )
            result.success(userData)
        } else {
            result.success(null)
        }
    }

//    // New function to navigate to the device panel
//    private fun goToDevicePanel(deviceId: String, result: MethodChannel.Result) {
//        try {
//            // Use this@MainActivity to ensure you're passing the Activity context
//            ThingHomeSdk.getBizBundleService().goToDeviceDetail(this@MainActivity, deviceId)
//            result.success(null) // Indicate that the attempt to launch was made
//        } catch (e: Exception) {
//            Log.e("TuyaSDK", "Error launching device panel for $deviceId", e)
//            result.error("GOTO_DEVICE_PANEL_FAILED", "Failed to launch device panel: ${e.message}", null)
//        }
//    }

    override fun onDestroy() {
        super.onDestroy()
        // Clean up SDK resources when app is destroyed
        ThingHomeSdk.onDestroy()
    }
}
