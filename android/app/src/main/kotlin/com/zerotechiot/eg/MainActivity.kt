package com.zerotechiot.eg

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.thingclips.smart.activator.core.kit.ThingActivatorCoreKit
import com.thingclips.smart.activator.core.kit.bean.ThingActivatorScanDeviceBean
import com.thingclips.smart.activator.core.kit.bean.ThingActivatorScanFailureBean
import com.thingclips.smart.activator.core.kit.builder.ThingActivatorScanBuilder
import com.thingclips.smart.activator.core.kit.callback.ThingActivatorScanCallback
import com.thingclips.smart.activator.plug.mesosphere.ThingDeviceActivatorManager
import com.thingclips.smart.android.user.api.ILoginCallback
import com.thingclips.smart.android.user.api.ILogoutCallback
import com.thingclips.smart.android.user.bean.User
import com.thingclips.smart.api.MicroContext
import com.thingclips.smart.api.service.MicroServiceManager
import com.thingclips.smart.clearcache.api.ClearCacheService
import com.thingclips.smart.commonbiz.bizbundle.family.api.AbsBizBundleFamilyService
import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.panelcaller.api.AbsPanelCallerService
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
                    try {
                        Log.d("TuyaSDK", "Starting device active action")
                        pairDevices(result)
                    } catch (e: Exception) {
                        Log.e("TuyaSDK", "Failed to pair devices: ${e.message}", e)
                        result.error("PAIR_FAILED", "Failed to pair devices: ${e.message}", null)
                    }
                }

                "openDeviceControlPanel" -> {
                    val deviceId = call.argument<String>("deviceId")
                    val homeId = call.argument<Int>("homeId")
                    val homeName = call.argument<String>("homeName")
                    if (deviceId != null && homeId != null) {
                        openDeviceControlPanel(deviceId, homeId.toLong(), homeName ?: "", result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "deviceId and homeId are required", null)
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
                        "name" to (device.name ?: "no name"),
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


    private fun openDeviceControlPanel(deviceId: String, homeId: Long, homeName: String, result: MethodChannel.Result) {
        try {
            Log.d("TuyaSDK", "════════════════════════════════════════")
            Log.d("TuyaSDK", "🚀 Opening device control panel")
            Log.d("TuyaSDK", "   Device ID: $deviceId")
            Log.d("TuyaSDK", "   Home: $homeName (ID: $homeId)")
            Log.d("TuyaSDK", "════════════════════════════════════════")
            
            // CRITICAL: Check storage permissions before opening panel
            // Panel needs to extract resources to storage
            if (!checkPermissions()) {
                Log.w("TuyaSDK", "⚠️ Storage permissions not granted, requesting now...")
                requestPermissions()
                // Note: Panel will open next time after user grants permissions
                result.error(
                    "PERMISSIONS_REQUIRED",
                    "Storage permissions are required to load device panel. Please try again.",
                    null
                )
                return
            }
            
            try {
                // Clear cache first
                val cacheService = MicroContext.getServiceManager()
                    .findServiceByInterface(ClearCacheService::class.java.name) as? ClearCacheService
                cacheService?.clearCache(this)
                
                // 1. Initialize home service first
                val serviceManager = MicroServiceManager.getInstance()
                if (serviceManager == null) {
                    Log.e("TuyaSDK", "❌ MicroServiceManager is null - services not initialized")
                    result.error("SERVICE_MANAGER_NULL", "MicroServiceManager is not initialized", null)
                    return
                }
                
                val familyService = serviceManager.findServiceByInterface(AbsBizBundleFamilyService::class.java.name) as? AbsBizBundleFamilyService
                if (familyService == null) {
                    Log.e("TuyaSDK", "❌ AbsBizBundleFamilyService not found - family BizBundle not properly initialized")
                    result.error("FAMILY_SERVICE_NOT_FOUND", "Family service not available - check BizBundle initialization", null)
                    return
                }
                
                Log.d("TuyaSDK", "✅ AbsBizBundleFamilyService found, switching to home: $homeId")
                familyService.shiftCurrentFamily(homeId, homeName)

                // 2. Then open panel
                val panelService = MicroContext.getServiceManager()
                    .findServiceByInterface(AbsPanelCallerService::class.java.name) as? AbsPanelCallerService
                if (panelService == null) {
                    Log.e("TuyaSDK", "❌ AbsPanelCallerService not found")
                    result.error("PANEL_SERVICE_NOT_FOUND", "Panel service not available", null)
                    return
                }
                
                Log.d("TuyaSDK", "✅ AbsPanelCallerService found, opening panel for device: $deviceId")
                panelService.goPanelWithCheckAndTip(this, deviceId)
                
            } catch (panelException: Exception) {
                Log.e("TuyaSDK", "❌ Failed to open panel: ${panelException.message}", panelException)
                result.error(
                    "PANEL_FAILED",
                    "Failed to open device panel: ${panelException.message}",
                    null
                )
            }
            
        } catch (e: Exception) {
            Log.e("TuyaSDK", "❌ Unexpected error: ${e.message}", e)
            result.error(
                "UNEXPECTED_ERROR",
                "Unexpected error: ${e.message}",
                null
            )
        }
    }


    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        when (requestCode) {
            1001 -> {
                if (grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                    Log.d("TuyaSDK", "All permissions granted, can now start device pairing")
                    // Permissions granted, you can now start device pairing
                } else {
                    Log.e("TuyaSDK", "Permissions denied, cannot start device pairing")
                    // Permissions denied, inform the user
                }
            }
        }
    }

    private fun pairDevices(result: MethodChannel.Result) {
        try {
            Log.d("TuyaSDK", "Starting device active action")

            // Check if the user is logged in before starting device pairing
            val user = ThingHomeSdk.getUserInstance().user
            if (user == null) {
                Log.e("TuyaSDK", "User not logged in, cannot start device pairing")
                result.error("USER_NOT_LOGGED_IN", "User must be logged in to pair devices", null)
                return
            }

            Log.d("TuyaSDK", "User is logged in, checking permissions")

            // Check and request necessary permissions
            if (!checkPermissions()) {
                Log.d("TuyaSDK", "Requesting permissions for device pairing")
                requestPermissions()
                result.success("Permissions requested for device pairing")
                return
            }

            Log.d("TuyaSDK", "All permissions granted, starting device activator")

            try {
                // Check if we have a valid context
                Log.d("TuyaSDK", "Context: $this")
                Log.d("TuyaSDK", "Context class: ${this.javaClass.name}")
                // Try the BizBundle UI approach now that theme is properly configured
                Log.d("TuyaSDK", "Attempting to start BizBundle device pairing UI")

                try {
                    // Start the device activator UI using ThingDeviceActivatorManager
                    ThingDeviceActivatorManager.startDeviceActiveAction(this)
                    Log.d("TuyaSDK", "BizBundle device pairing UI started successfully")
                    result.success("Device pairing UI started successfully")
                } catch (uiException: Exception) {
                    Log.e(
                        "TuyaSDK",
                        "BizBundle UI failed, falling back to core scanning: ${uiException.message}"
                    )

                    // Fallback to core activator scanning if UI fails
                    Log.d("TuyaSDK", "Using core activator approach as fallback")

                    val scanBuilder = ThingActivatorScanBuilder()


                    ThingActivatorCoreKit.getScanDeviceManager()
                        .startScan(scanBuilder, object : ThingActivatorScanCallback {
                            override fun deviceFound(deviceBean: ThingActivatorScanDeviceBean) {
                                Log.d("TuyaSDK", "Device found: ${deviceBean.name}")
                            }

                            override fun deviceRepeat(deviceBean: ThingActivatorScanDeviceBean) {
                                Log.d("TuyaSDK", "Device repeat: ${deviceBean.name}")
                            }

                            override fun deviceUpdate(deviceBean: ThingActivatorScanDeviceBean) {
                                Log.d("TuyaSDK", "Device update: ${deviceBean.name}")
                            }

                            override fun scanFailure(failureBean: ThingActivatorScanFailureBean) {
                                Log.e("TuyaSDK", "Scan failed: ${failureBean.errorMsg}")
                            }

                            override fun scanFinish() {
                                Log.d("TuyaSDK", "Scan finished")
                            }
                        })

                    Log.d("TuyaSDK", "Core device scanning started as fallback")
                    result.success("Device scanning started as fallback")
                }

            } catch (e: Exception) {
                Log.e("TuyaSDK", "Failed to start device scanning: ${e.message}", e)
                Log.e("TuyaSDK", "Exception type: ${e.javaClass.simpleName}")
                Log.e("TuyaSDK", "Stack trace: ${e.stackTrace.joinToString("\n")}")

                result.error("SCAN_FAILED", "Failed to start device scanning: ${e.message}", null)
            }

        } catch (e: Exception) {
            Log.e("TuyaSDK", "Failed to start device pairing: ${e.message}", e)
            result.error("PAIR_FAILED", "Failed to start device pairing: ${e.message}", null)
        }
    }

    private fun checkPermissions(): Boolean {
        val permissions = mutableListOf<String>()

        // Check location permission
        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            permissions.add(Manifest.permission.ACCESS_FINE_LOCATION)
        }

        // Check Bluetooth permissions for Android 12+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.BLUETOOTH_SCAN
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                permissions.add(Manifest.permission.BLUETOOTH_SCAN)
            }
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.BLUETOOTH_CONNECT
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                permissions.add(Manifest.permission.BLUETOOTH_CONNECT)
            }
        }

        // CRITICAL: Check storage permissions for BizBundle panel extraction
        // For Android 6-12 (API 23-32)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && Build.VERSION.SDK_INT <= Build.VERSION_CODES.S_V2) {
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE)
            }
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.READ_EXTERNAL_STORAGE
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE)
            }
        }

        return permissions.isEmpty()
    }

    private fun requestPermissions() {
        val permissions = mutableListOf<String>()

        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            permissions.add(Manifest.permission.ACCESS_FINE_LOCATION)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.BLUETOOTH_SCAN
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                permissions.add(Manifest.permission.BLUETOOTH_SCAN)
            }
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.BLUETOOTH_CONNECT
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                permissions.add(Manifest.permission.BLUETOOTH_CONNECT)
            }
        }

        // CRITICAL: Request storage permissions for BizBundle panel extraction
        // For Android 6-12 (API 23-32)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && Build.VERSION.SDK_INT <= Build.VERSION_CODES.S_V2) {
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE)
            }
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.READ_EXTERNAL_STORAGE
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE)
            }
        }

        if (permissions.isNotEmpty()) {
            Log.d("TuyaSDK", "Requesting permissions: ${permissions.joinToString(", ")}")
            ActivityCompat.requestPermissions(this, permissions.toTypedArray(), 1001)
        }
    }


    override fun onDestroy() {
        super.onDestroy()
        // Clean up SDK resources when app is destroyed
        ThingHomeSdk.onDestroy()
    }
}