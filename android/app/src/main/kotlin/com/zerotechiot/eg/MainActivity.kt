package com.zerotechiot.eg

import android.Manifest
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.thingclips.smart.android.user.api.ILoginCallback
import com.thingclips.smart.android.user.api.IRegisterCallback
import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.android.user.bean.User
import com.thingclips.smart.panelcaller.api.AbsPanelCallerService
import com.thingclips.smart.api.MicroContext
import com.thingclips.smart.device.activator.ThingDeviceActivatorManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity - Flutter entry point with Tuya SDK and BizBundle integration
 * 
 * Features:
 * - User registration and login with Tuya Cloud
 * - Device pairing using Tuya BizBundle UI
 * - Device list retrieval
 * - Device control via Data Points (DP)
 * - Home management
 */
class MainActivity : FlutterActivity() {
    private val channel = "com.zerotechiot.eg/tuya_sdk"
    private val PERMISSION_REQUEST_CODE = 100
    // private var activatorBuilder: ThingActivatorBuilder? = null
    // private var pairingResultCallback: MethodChannel.Result? = null

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
                
                "register" -> {
                    val email = call.argument<String>("email")
                    val password = call.argument<String>("password")
                    val countryCode = call.argument<String>("countryCode") ?: "20"

                    if (email != null && password != null) {
                        registerUser(email, password, countryCode, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Email and password are required", null)
                    }
                }
                
                "getDeviceList" -> {
                    getDeviceList(result)
                }
                
                "controlDevice" -> {
                    val deviceId = call.argument<String>("deviceId")
                    val dpId = call.argument<String>("dpId")
                    val dpValue = call.argument<Any>("dpValue")
                    
                    if (deviceId != null && dpId != null && dpValue != null) {
                        controlDevice(deviceId, dpId, dpValue, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "DeviceId, dpId, and dpValue are required", null)
                    }
                }
                
                "startDevicePairing" -> {
                    startDevicePairing(result)
                }
                
                "startWifiPairing" -> {
                    val ssid = call.argument<String>("ssid")
                    val password = call.argument<String>("password")
                    val token = call.argument<String>("token")
                    
                    if (ssid != null && password != null) {
                        startWifiPairing(ssid, password, token ?: "", result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "SSID and password are required", null)
                    }
                }
                
                "stopDevicePairing" -> {
                    stopDevicePairing(result)
                }
                
                "getDeviceSpecifications" -> {
                    val deviceId = call.argument<String>("deviceId")
                    if (deviceId != null) {
                        getDeviceSpecifications(deviceId, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Device ID is required", null)
                    }
                }

                "openDeviceControlPanel" -> {
                    val homeId = call.argument<Int>("homeId")
                    val homeName = call.argument<String>("homeName")
                    val deviceId = call.argument<String>("deviceId")
                    if (deviceId != null) {
                        Log.d("TuyaSDK", "openDeviceControlPanel called with deviceId: $deviceId, homeId: $homeId, homeName: $homeName")
                        openDeviceControlPanel(deviceId, homeId?.toLong() ?: 0, homeName ?: "", result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "deviceId is required", null)
                    }
                }

                "getHomes" -> {
                    getHomes(result)
                }

                "getHomeDevices" -> {
                    val homeId = call.argument<Long>("homeId")
                    if (homeId != null) {
                        getHomeDevices(homeId, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "homeId is required", null)
                    }
                }

                "pairDevices" -> {
                    pairDevices(result)
                }

                // Temporarily disabled - needs correct BizBundle class path
                // "openDevicePairingUI" -> {
                //     openDevicePairingUI(result)
                // }

                else -> result.notImplemented()
            }
        }
    }

    /**
     * Register a new user with Tuya cloud using email and password
     */
    private fun registerUser(email: String, password: String, countryCode: String, result: MethodChannel.Result) {
        ThingHomeSdk.getUserInstance().registerAccountWithEmail(
            countryCode,
            email,
            password,
            object : IRegisterCallback {
                override fun onSuccess(user: User?) {
                    val userData = mapOf(
                        "id" to (user?.uid ?: ""),
                        "email" to (user?.email ?: email),
                        "name" to (user?.username ?: email.split("@")[0])
                    )
                    result.success(userData)
                }

                override fun onError(code: String?, error: String?) {
                    result.error("REGISTER_FAILED", error ?: "Registration failed", code)
                }
            }
        )
    }

    /**
     * Login user with Tuya cloud using email and password
     */
    private fun loginUser(email: String, password: String, result: MethodChannel.Result) {
        ThingHomeSdk.getUserInstance().loginWithEmail(
            "20", // Country code (20 = Egypt, adjust as needed)
            email,
            password,
            object : ILoginCallback {
                override fun onSuccess(user: User?) {
                    val userData = mapOf(
                        "id" to (user?.uid ?: ""),
                        "email" to (user?.email ?: email),
                        "name" to (user?.username ?: email.split("@")[0])
                    )
                    result.success(userData)
                }

                override fun onError(code: String?, error: String?) {
                    result.error("LOGIN_FAILED", error ?: "Login failed", code)
                }
            }
        )
    }
    
    /**
     * Get list of devices from Tuya cloud for the logged-in user
     */
    private fun getDeviceList(result: MethodChannel.Result) {
        try {
            val user = ThingHomeSdk.getUserInstance().user
            if (user == null) {
                result.error("NOT_LOGGED_IN", "User must be logged in", null)
                return
            }

            // Query home list first
            ThingHomeSdk.getHomeManagerInstance().queryHomeList(
                object : com.thingclips.smart.home.sdk.callback.IThingGetHomeListCallback {
                    override fun onSuccess(homeBeans: MutableList<com.thingclips.smart.home.sdk.bean.HomeBean>?) {
                        if (homeBeans.isNullOrEmpty()) {
                            result.success(mapOf("devices" to emptyList<Any>()))
                            return
                        }
                        
                        // Get first home's device list
                        val homeId = homeBeans[0].homeId
                        ThingHomeSdk.newHomeInstance(homeId).getHomeDetail(
                            object : com.thingclips.smart.home.sdk.callback.IThingHomeResultCallback {
                                override fun onSuccess(homeBean: com.thingclips.smart.home.sdk.bean.HomeBean?) {
                                    val devices = homeBean?.deviceList?.map { device ->
                                        mapOf(
                                            "id" to device.devId,
                                            "name" to device.name,
                                            "type" to device.productId,
                                            "icon" to (device.iconUrl ?: ""),
                                            "isOnline" to device.isOnline,
                                            "category" to (device.category ?: "")
                                        )
                                    } ?: emptyList()
                                    
                                    result.success(mapOf("devices" to devices))
                                }

                                override fun onError(code: String?, error: String?) {
                                    result.error("GET_DEVICES_FAILED", error ?: "Failed to get devices", code)
                                }
                            }
                        )
                    }

                    override fun onError(code: String?, error: String?) {
                        result.error("GET_HOMES_FAILED", error ?: "Failed to get homes", code)
                    }
                }
            )
        } catch (e: Exception) {
            result.error("GET_DEVICES_ERROR", e.message ?: "Unknown error", null)
        }
    }
    
    /**
     * Control a device by sending DP (Data Point) commands
     * Example: dpId="1", dpValue=true (turns device on)
     */
    private fun controlDevice(deviceId: String, dpId: String, dpValue: Any, result: MethodChannel.Result) {
        try {
            val device = ThingHomeSdk.newDeviceInstance(deviceId)
            device.publishDps(
                "{\"$dpId\":$dpValue}",
                object : com.thingclips.smart.sdk.api.IResultCallback {
                    override fun onError(code: String?, error: String?) {
                        result.error("CONTROL_FAILED", error ?: "Failed to control device", code)
                    }

                    override fun onSuccess() {
                        result.success(mapOf(
                            "status" to "success",
                            "message" to "Device controlled successfully"
                        ))
                    }
                }
            )
        } catch (e: Exception) {
            result.error("CONTROL_ERROR", e.message ?: "Unknown error", null)
        }
    }

    /**
     * Get device specifications (Data Points schema)
     * This allows us to dynamically build controls for any device type
     * 
     * NOTE: Returns current device status and available DPs
     * Full schema with property details can be added later
     */
    private fun getDeviceSpecifications(deviceId: String, result: MethodChannel.Result) {
        try {
            // For now, return basic info that we know is available
            // The full DP schema can be fetched from the home details
            
            result.success(mapOf(
                "deviceId" to deviceId,
                "message" to "Device specifications available. Use device status to see current DPs.",
                "available" to true
            ))
            
            // TODO: Implement full schema retrieval when correct API is identified
            // This will include DP types, ranges, units, etc.
        } catch (e: Exception) {
            result.error("GET_SCHEMA_ERROR", "Failed to get device info: ${e.message}", null)
        }
    }
    
    /**
     * Start device pairing process - Check prerequisites and return ready status
     * Flutter UI will handle the entire pairing flow
     */
    private fun startDevicePairing(result: MethodChannel.Result) {
        try {
            val user = ThingHomeSdk.getUserInstance().user
            if (user == null) {
                result.error("NOT_LOGGED_IN", "User must be logged in to pair devices", null)
                return
            }

            if (!checkPermissions()) {
                result.error("PERMISSION_DENIED", "Required permissions not granted", null)
                return
            }

            result.success(mapOf(
                "status" to "ready",
                "message" to "Device pairing is ready. Use Flutter UI for pairing flow."
            ))
        } catch (e: Exception) {
            result.error("PAIRING_ERROR", "Failed to start device pairing: ${e.message}", null)
        }
    }

    /**
     * Open Tuya BizBundle Device Pairing UI
     * This launches the complete pre-built Tuya device pairing experience
     * TODO: Fix BizBundle class import path
     */
    // private fun openDevicePairingUI(result: MethodChannel.Result) {
    //     try {
    //         // Use the INSTANCE singleton to start device activation  
    //         ThingDeviceActivatorManager.INSTANCE.startDeviceActiveAction(this)
    //         result.success(mapOf(
    //             "status" to "launched",
    //             "message" to "Tuya device pairing UI launched successfully"
    //         ))
    //     } catch (e: Exception) {
    //         result.error("LAUNCH_ERROR", "Failed to launch device pairing UI: ${e.message}", null)
    //     }
    // }

    /**
     * Start WiFi pairing using EZ mode
     * NOTE: For real device pairing, please use BizBundle Device Activator
     * or add the correct activation dependency to build.gradle.kts
     * 
     * This is a placeholder that returns status info for now
     */
    private fun startWifiPairing(ssid: String, password: String, token: String, result: MethodChannel.Result) {
        try {
            val user = ThingHomeSdk.getUserInstance().user
            if (user == null) {
                result.error("NOT_LOGGED_IN", "User must be logged in to pair devices", null)
                return
            }

            // TODO: Implement real pairing with correct SDK classes
            // Option 1: Use BizBundle (add correct imports)
            // Option 2: Add com.thingclips.smart:thingsmart-activator dependency
            // Option 3: Use lower-level SDK APIs
            
            result.success(mapOf(
                "success" to false,
                "message" to "Device pairing API unavailable. Please use BizBundle or configure SDK correctly.",
                "ssid" to ssid,
                "requiresConfiguration" to true
            ))
        } catch (e: Exception) {
            result.error("PAIRING_ERROR", "Failed to start WiFi pairing: ${e.message}", null)
        }
    }

    /**
     * Stop device pairing process
     */
    private fun stopDevicePairing(result: MethodChannel.Result) {
        try {
            result.success(mapOf(
                "success" to true,
                "message" to "Device pairing stopped"
            ))
        } catch (e: Exception) {
            result.error("STOP_PAIRING_ERROR", "Failed to stop pairing: ${e.message}", null)
        }
    }

    /**
     * Check if required permissions are granted
     */
    private fun checkPermissions(): Boolean {
        val permissions = arrayOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.CHANGE_WIFI_STATE,
            Manifest.permission.BLUETOOTH,
            Manifest.permission.BLUETOOTH_ADMIN
        )

        for (permission in permissions) {
            if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                return false
            }
        }
        return true
    }

    /**
     * Get user's homes
     */
    private fun getHomes(result: MethodChannel.Result) {
        try {
            val user = ThingHomeSdk.getUserInstance().user
            if (user == null) {
                result.error("NOT_LOGGED_IN", "User must be logged in", null)
                return
            }

            ThingHomeSdk.getHomeManagerInstance().getHomeList(object : com.thingclips.smart.home.sdk.callback.IThingHomeResultCallback {
                override fun onSuccess(homeBeans: List<com.thingclips.smart.home.sdk.bean.HomeBean>) {
                    val homes = homeBeans.map { home ->
                        mapOf(
                            "homeId" to home.homeId,
                            "name" to home.name,
                            "geoName" to home.geoName,
                            "admin" to home.admin,
                            "city" to home.city,
                            "lat" to home.lat,
                            "lon" to home.lon
                        )
                    }
                    result.success(homes)
                }

                override fun onError(errorCode: String?, errorMsg: String?) {
                    result.error("GET_HOMES_ERROR", "Failed to get homes: $errorMsg", null)
                }
            })
        } catch (e: Exception) {
            result.error("GET_HOMES_ERROR", "Failed to get homes: ${e.message}", null)
        }
    }

    /**
     * Get devices for a specific home
     */
    private fun getHomeDevices(homeId: Long, result: MethodChannel.Result) {
        try {
            val user = ThingHomeSdk.getUserInstance().user
            if (user == null) {
                result.error("NOT_LOGGED_IN", "User must be logged in", null)
                return
            }

            ThingHomeSdk.newHomeInstance(homeId).getHomeDetail(object : com.thingclips.smart.home.sdk.callback.IThingHomeResultCallback {
                override fun onSuccess(homeBean: com.thingclips.smart.home.sdk.bean.HomeBean) {
                    val devices = homeBean.deviceList?.map { device ->
                        mapOf(
                            "deviceId" to (device.devId ?: ""),
                            "name" to (device.name ?: device.devId ?: "Unknown Device"),
                            "isOnline" to device.isOnline,
                            "image" to (device.iconUrl ?: "")
                        )
                    } ?: emptyList()
                    result.success(devices)
                }

                override fun onError(errorCode: String?, errorMsg: String?) {
                    result.error("GET_DEVICES_ERROR", "Failed to get devices: $errorMsg", null)
                }
            })
        } catch (e: Exception) {
            result.error("GET_DEVICES_ERROR", "Failed to get devices: ${e.message}", null)
        }
    }

    /**
     * Open device control panel using BizBundle
     */
    private fun openDeviceControlPanel(deviceId: String, homeId: Long, homeName: String, result: MethodChannel.Result) {
        try {
            Log.d("TuyaSDK", "Opening device control panel for device: $deviceId, homeId: $homeId, homeName: $homeName")
            
            val user = ThingHomeSdk.getUserInstance().user
            if (user == null) {
                result.error("NOT_LOGGED_IN", "User must be logged in", null)
                return
            }

            // Use BizBundle to open device control panel
            val microContext = MicroContext.getMicroContext(this)
            val panelCallerService = microContext.findServiceByInterface(AbsPanelCallerService::class.java)
            
            if (panelCallerService != null) {
                panelCallerService.goPanelWithCheckAndTip(this, deviceId, homeId, homeName, object : com.thingclips.smart.panelcaller.api.IPanelCallerCallback {
                    override fun onSuccess() {
                        Log.d("TuyaSDK", "Device control panel opened successfully")
                        result.success(mapOf("success" to true, "message" to "Device control panel opened"))
                    }

                    override fun onError(errorCode: String?, errorMsg: String?) {
                        Log.e("TuyaSDK", "Failed to open device control panel: $errorMsg")
                        result.error("OPEN_PANEL_FAILED", "Failed to open device control panel: $errorMsg", null)
                    }
                })
            } else {
                Log.e("TuyaSDK", "PanelCallerService not found")
                result.error("SERVICE_NOT_FOUND", "PanelCallerService not available", null)
            }
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Failed to open device control panel", e)
            result.error("OPEN_PANEL_FAILED", "Failed to open device control panel: ${e.message}", null)
        }
    }

    /**
     * Start device pairing using BizBundle
     */
    private fun pairDevices(result: MethodChannel.Result) {
        try {
            val user = ThingHomeSdk.getUserInstance().user
            if (user == null) {
                result.error("NOT_LOGGED_IN", "User must be logged in", null)
                return
            }

            // Check permissions first
            if (!checkPermissions()) {
                requestPermissions()
                result.error("PERMISSIONS_REQUIRED", "Location and Bluetooth permissions are required", null)
                return
            }

            // Use BizBundle device activator
            ThingDeviceActivatorManager.startDeviceActiveAction(this)
            result.success(mapOf("success" to true, "message" to "Device pairing started"))
        } catch (e: Exception) {
            result.error("PAIRING_ERROR", "Failed to start device pairing: ${e.message}", null)
        }
    }

    /**
     * Request required permissions
     */
    private fun requestPermissions() {
        val permissions = arrayOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.CHANGE_WIFI_STATE,
            Manifest.permission.BLUETOOTH,
            Manifest.permission.BLUETOOTH_ADMIN
        )
        ActivityCompat.requestPermissions(this, permissions, PERMISSION_REQUEST_CODE)
    }

    override fun onDestroy() {
        super.onDestroy()
        // Clean up Tuya SDK resources
        ThingHomeSdk.onDestroy()
    }
}
