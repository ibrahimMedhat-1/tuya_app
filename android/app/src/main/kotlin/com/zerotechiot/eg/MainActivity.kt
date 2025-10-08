package com.zerotechiot.eg

import android.util.Log
import com.thingclips.smart.activator.core.kit.ThingActivatorCoreKit
import com.thingclips.smart.activator.core.kit.bean.ThingActivatorScanDeviceBean
import com.thingclips.smart.activator.core.kit.bean.ThingActivatorScanFailureBean
import com.thingclips.smart.activator.core.kit.callback.ThingActivatorScanCallback
import com.thingclips.smart.android.ble.api.ScanType
import com.thingclips.smart.android.user.api.ILoginCallback
import com.thingclips.smart.android.user.api.ILogoutCallback
import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.android.user.bean.User
import com.thingclips.smart.home.sdk.bean.HomeBean
import com.thingclips.smart.home.sdk.callback.IThingGetHomeListCallback
import com.thingclips.smart.home.sdk.callback.IThingHomeResultCallback
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
                "logout" -> {
                     // Use the Tuya SDK v3.25.0 logout method
                    ThingHomeSdk.getUserInstance().logout(object : ILogoutCallback {
                        override fun onSuccess() {
                            result.success(null)
                        }

                        override fun onError(code: String, error: String) {
                             result.error(code, error, null)
                        }
                    })
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

                "pairDevices" -> {
                    val deviceId = call.argument<String>("deviceId")
                    if (deviceId != null) {
                        pairDevices(result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "deviceId is required", null)
                    }
                }





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

    private fun pairDevices(  result: MethodChannel.Result) {
        try {
            ThingActivatorCoreKit.getScanDeviceManager()
                .startBlueToothDeviceSearch(
                    25 * 1000L,
                    arrayListOf(ScanType.MESH, ScanType.SIG_MESH, ScanType.SINGLE, ScanType.THING_BEACON),
                    object : ThingActivatorScanCallback {
                        override fun deviceFound(deviceBean: ThingActivatorScanDeviceBean) {
                            // Device discovery
                        }

                        override fun deviceRepeat(deviceBean: ThingActivatorScanDeviceBean) {
                            // Repeated discovery
                        }

                        override fun deviceUpdate(deviceBean: ThingActivatorScanDeviceBean) {
                            // Device capability update. This method will not be called back during a scan for a single Bluetooth device.
                        }

                        override fun scanFailure(failureBean: ThingActivatorScanFailureBean) {
                            // Device discovery failed
                        }

                        override fun scanFinish() {
                            // Search finished
                        }

                    })
            result.success(null)
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Failed to open device control panel: ${e.message}")
            result.error("OPEN_PANEL_FAILED", "Failed to open device control panel: ${e.message}", null)
        }
    }


    override fun onDestroy() {
        super.onDestroy()
        // Clean up SDK resources when app is destroyed
        ThingHomeSdk.onDestroy()
    }
}
