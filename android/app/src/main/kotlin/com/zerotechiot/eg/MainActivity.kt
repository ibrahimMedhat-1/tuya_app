package com.zerotechiot.eg

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.thingclips.smart.activator.core.kit.ThingActivatorCoreKit
import com.thingclips.smart.activator.core.kit.bean.ThingActivatorScanDeviceBean
import com.thingclips.smart.activator.core.kit.bean.ThingActivatorScanFailureBean
import com.thingclips.smart.activator.core.kit.builder.ThingActivatorScanBuilder
import com.thingclips.smart.activator.core.kit.callback.ThingActivatorScanCallback
import com.thingclips.smart.activator.plug.mesosphere.ThingDeviceActivatorManager
// QR Code scanning imports - using ZXing for scanning
// Note: Using reflection to access ZXing classes to avoid import issues
import com.thingclips.smart.android.user.api.ILoginCallback
import com.thingclips.smart.android.user.api.ILogoutCallback
import com.thingclips.smart.android.user.api.IRegisterCallback
import com.thingclips.smart.android.user.bean.User
import android.content.Intent
import com.thingclips.smart.api.MicroContext
import com.thingclips.smart.api.router.UrlBuilder
import com.thingclips.smart.api.service.MicroServiceManager
import com.thingclips.smart.api.service.RedirectService
import com.thingclips.smart.clearcache.api.ClearCacheService
import com.thingclips.smart.commonbiz.bizbundle.family.api.AbsBizBundleFamilyService
import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.panelcaller.api.AbsPanelCallerService
import com.thingclips.smart.home.sdk.bean.HomeBean
import com.thingclips.smart.home.sdk.bean.RoomBean
import com.thingclips.smart.home.sdk.callback.IThingGetHomeListCallback
import com.thingclips.smart.home.sdk.callback.IThingHomeResultCallback
import com.thingclips.smart.home.sdk.callback.IThingRoomResultCallback
import com.thingclips.smart.scene.business.api.IThingSceneBusinessService
import com.thingclips.smart.scene.home.SceneHomePipeLine
import com.thingclips.smart.sdk.api.IResultCallback
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val channel = "com.zerotechiot.eg/tuya_sdk"
    
    companion object {
        private var isScenePipelineInitialized = false
    }
    
    // QR Code scan request code
    private val QR_CODE_SCAN_REQUEST = 2001
    
    // QR Code Activator instance for device pairing (stored as Any to avoid import issues)
    private var qrCodeActivator: Any? = null

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

                "register" -> {
                    val email = call.argument<String>("email")
                    val password = call.argument<String>("password")
                    val verificationCode = call.argument<String>("verificationCode")
                    val countryCodeArg = call.argument<String>("countryCode")

                    if (email != null && password != null && verificationCode != null) {
                        registerUser(email, password, verificationCode, countryCodeArg, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Email, password, and verification code are required", null)
                    }
                }

                "sendVerificationCode" -> {
                    val email = call.argument<String>("email")
                    val countryCodeArg = call.argument<String>("countryCode")
                    if (email != null) {
                        sendVerificationCode(email, countryCodeArg, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Email is required", null)
                    }
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

                "scanQRCodeForPairing" -> {
                    try {
                        Log.d("TuyaSDK", "Starting QR code scan for device pairing")
                        scanQRCodeForPairing(result)
                    } catch (e: Exception) {
                        Log.e("TuyaSDK", "Failed to scan QR code: ${e.message}", e)
                        result.error("QR_SCAN_FAILED", "Failed to scan QR code: ${e.message}", null)
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

                "getHomeRooms" -> {
                    val homeId = call.argument<Int>("homeId")
                    if (homeId != null) {
                        getHomeRooms(homeId.toLong(), result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "homeId is required", null)
                    }
                }

                "getRoomDevices" -> {
                    val homeId = call.argument<Int>("homeId")
                    val roomId = call.argument<Int>("roomId")
                    if (homeId != null && roomId != null) {
                        getRoomDevices(homeId.toLong(), roomId.toLong(), result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "homeId and roomId are required", null)
                    }
                }

                "addHouse" -> {
                    val name = call.argument<String>("name")
                    val geoName = call.argument<String>("geoName")
                    val lon = call.argument<Double>("lon")
                    val lat = call.argument<Double>("lat")
                    val roomNames = call.argument<List<String>>("roomNames")?: emptyList<String>()
                    if (name != null) {
                        addHouse(name, geoName, lon, lat, roomNames, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "name is required", null)
                    }
                }

                "addRoom" -> {
                    val homeId = call.argument<Int>("homeId")
                    val name = call.argument<String>("name")
                    val iconUrl = call.argument<String>("iconUrl")
                    if (homeId != null && name != null) {
                        addRoom(homeId.toLong(), name, iconUrl, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "homeId and name are required", null)
                    }
                }

                "openScenes" -> {
                    val homeId = call.argument<Int>("homeId")
                    val homeName = call.argument<String>("homeName")
                    if (homeId != null) {
                        openScenesBizBundle(homeId.toLong(), homeName ?: "Home", result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "homeId is required", null)
                    }
                }

                "executeScene" -> {
                    val sceneId = call.argument<String>("sceneId")
                    if (sceneId != null) {
                        executeScene(sceneId, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "sceneId is required", null)
                    }
                }

                "addDeviceToRoom" -> {
                    val homeId = call.argument<Int>("homeId")
                    val roomId = call.argument<Int>("roomId")
                    val deviceId = call.argument<String>("deviceId")
                    if (homeId != null && roomId != null && deviceId != null) {
                        addDeviceToRoom(homeId.toLong(), roomId.toLong(), deviceId, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "homeId, roomId, and deviceId are required", null)
                    }
                }

                "removeDeviceFromRoom" -> {
                    val homeId = call.argument<Int>("homeId")
                    val roomId = call.argument<Int>("roomId")
                    val deviceId = call.argument<String>("deviceId")
                    if (homeId != null && roomId != null && deviceId != null) {
                        removeDeviceFromRoom(homeId.toLong(), roomId.toLong(), deviceId, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "homeId, roomId, and deviceId are required", null)
                    }
                }

                "updateRoomName" -> {
                    val homeId = call.argument<Int>("homeId")
                    val roomId = call.argument<Int>("roomId")
                    val name = call.argument<String>("name")
                    if (homeId != null && roomId != null && name != null) {
                        updateRoomName(homeId.toLong(), roomId.toLong(), name, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "homeId, roomId, and name are required", null)
                    }
                }

                "removeRoom" -> {
                    val homeId = call.argument<Int>("homeId")
                    val roomId = call.argument<Int>("roomId")
                    if (homeId != null && roomId != null) {
                        removeRoom(homeId.toLong(), roomId.toLong(), result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "homeId and roomId are required", null)
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
                    Log.d("TuyaSDK", "✅ Login successful for user: ${user?.email}")
                    
                    // Initialize SceneHomePipeLine for real-time scene data sync
                    // Should only be called once per app lifecycle after login
                    if (!isScenePipelineInitialized) {
                        try {
                            Log.d("TuyaSDK", "Initializing SceneHomePipeLine for scene data sync...")
                            SceneHomePipeLine().run()
                            isScenePipelineInitialized = true
                            Log.d("TuyaSDK", "✅ SceneHomePipeLine initialized successfully")
                        } catch (e: Exception) {
                            Log.e("TuyaSDK", "⚠️ Failed to initialize SceneHomePipeLine: ${e.message}")
                            // Non-critical error, continue with login
                        }
                    }
                    
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
                        "image" to device.iconUrl,
                        "deviceType" to device.uiType
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

    private fun getHomeRooms(homeId: Long, result: MethodChannel.Result) {
        ThingHomeSdk.newHomeInstance(homeId).getHomeDetail(object : IThingHomeResultCallback {
            override fun onSuccess(homeBean: HomeBean?) {
                val rooms = homeBean?.rooms?.map { room ->
                    mapOf(
                        "roomId" to room.roomId,
                        "name" to (room.name ?: "Unnamed Room"),
                        "deviceCount" to (room.deviceList?.size ?: 0),
                        "icon" to room.iconUrl
                    )
                } ?: emptyList()

                Log.d("TuyaSDK", "Rooms: $rooms")
                result.success(rooms)
            }

            override fun onError(code: String?, error: String?) {
                result.error("GET_HOME_ROOMS_FAILED", error ?: "Failed to get home rooms", null)
            }
        })
    }

    private fun getRoomDevices(homeId: Long, roomId: Long, result: MethodChannel.Result) {
        ThingHomeSdk.newHomeInstance(homeId).getHomeDetail(object : IThingHomeResultCallback {
            override fun onSuccess(homeBean: HomeBean?) {
                // Find the specific room
                val room = homeBean?.rooms?.find { it.roomId == roomId }
                val devices = room?.deviceList?.map { device ->
                    mapOf(
                        "deviceId" to (device.devId ?: ""),
                        "name" to (device.name ?: "no name"),
                        "isOnline" to device.isOnline,
                        "image" to device.iconUrl
                    )
                } ?: emptyList()

                Log.d("TuyaSDK", "Room devices: $devices")
                result.success(devices)
            }

            override fun onError(code: String?, error: String?) {
                result.error("GET_ROOM_DEVICES_FAILED", error ?: "Failed to get room devices", null)
            }
        })
    }

    private fun addHouse(name: String, geoName: String?, lon: Double?, lat: Double?, roomNames: List<String>, result: MethodChannel.Result) {
        try {
            Log.d("TuyaSDK", "Adding new house: $name")
            
            // Create home bean with required fields
            val homeBean = HomeBean().apply {
                this.name = name
                this.geoName = geoName ?: ""
                this.lon = lon ?: 0.0
                this.lat = lat ?: 0.0
            }
            
            ThingHomeSdk.getHomeManagerInstance().createHome(
                homeBean.name,
              homeBean.  lon,
           homeBean.     lat,
                geoName,
                roomNames,
                object : IThingHomeResultCallback {
                    override fun onSuccess(homeBean: HomeBean?) {
                        Log.d("TuyaSDK", "House created successfully: ${homeBean?.name}")
                        
                            val homeData = mapOf(
                                "homeId" to (homeBean?.homeId ?: 0),
                                "name" to (homeBean?.name ?: name)
                            )
                            result.success(homeData)
                    }

                    override fun onError(code: String?, error: String?) {
                        Log.e("TuyaSDK", "Failed to create house: $error")
                        result.error("ADD_HOUSE_FAILED", error ?: "Failed to create house", null)
                    }
                }
            )
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Exception while creating house: ${e.message}", e)
            result.error("ADD_HOUSE_EXCEPTION", "Exception while creating house: ${e.message}", null)
        }
    }

    private fun createRoomsForHome(homeId: Long, roomNames: List<String>, result: MethodChannel.Result) {
        var completedRooms = 0
        val totalRooms = roomNames.size
        val createdRooms = mutableListOf<Map<String, Any>>()
        
        roomNames.forEach { roomName ->
            ThingHomeSdk.newHomeInstance(homeId).addRoom(
                roomName,
                object : IThingRoomResultCallback {
                    override fun onSuccess(newRoom: RoomBean?) {
                        Log.d("TuyaSDK", "Room created successfully: $roomName")
                        newRoom?.let { room ->
                            createdRooms.add(mapOf(
                                "roomId" to room.roomId,
                                "name" to room.name,
                                "deviceCount" to (room.deviceList?.size ?: 0),
                                "icon" to (room.iconUrl ?: "")
                            ))
                        }
                        
                        completedRooms++
                        if (completedRooms == totalRooms) {
                            // All rooms created, return success
                            val homeData = mapOf(
                                "homeId" to homeId,
                                "name" to "New Home", // You might want to get the actual home name
                                "rooms" to createdRooms
                            )
                            result.success(homeData)
                        }
                    }

                    override fun onError(code: String?, error: String?) {
                        Log.e("TuyaSDK", "Failed to create room $roomName: $error")
                        completedRooms++
                        if (completedRooms == totalRooms) {
                            // Even if some rooms failed, return the home data
                            val homeData = mapOf(
                                "homeId" to homeId,
                                "name" to "New Home",
                                "rooms" to createdRooms
                            )
                            result.success(homeData)
                        }
                    }
                }
            )
        }
    }

    private fun addRoom(homeId: Long, name: String, iconUrl: String?, result: MethodChannel.Result) {
        try {
            Log.d("TuyaSDK", "Adding new room: $name to home: $homeId")
            
            ThingHomeSdk.newHomeInstance(homeId).addRoom(
                name,
                object : IThingRoomResultCallback {
                    override fun onSuccess(newRoom: RoomBean?) {
                        Log.d("TuyaSDK", "Room created successfully: $name")
                        // Find the newly created room
                        val roomData = mapOf(
                            "roomId" to (newRoom?.roomId ?: 0),
                            "name" to (newRoom?.name ?: name),
                            "deviceCount" to (newRoom?.deviceList?.size ?: 0),
                            "icon" to (newRoom?.iconUrl ?: "")
                        )
                        result.success(roomData)
                    }

                    override fun onError(code: String?, error: String?) {
                        Log.e("TuyaSDK", "Failed to create room: $error")
                        result.error("ADD_ROOM_FAILED", error ?: "Failed to create room", null)
                    }
                }
            )
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Exception while creating room: ${e.message}", e)
            result.error("ADD_ROOM_EXCEPTION", "Exception while creating room: ${e.message}", null)
        }
    }


    private fun checkLoginStatus(result: MethodChannel.Result) {
        val user = ThingHomeSdk.getUserInstance().user
        if (user != null) {
            // Initialize SceneHomePipeLine if user is already logged in
            if (!isScenePipelineInitialized) {
                try {
                    Log.d("TuyaSDK", "User already logged in, initializing SceneHomePipeLine...")
                    SceneHomePipeLine().run()
                    isScenePipelineInitialized = true
                    Log.d("TuyaSDK", "✅ SceneHomePipeLine initialized successfully")
                } catch (e: Exception) {
                    Log.e("TuyaSDK", "⚠️ Failed to initialize SceneHomePipeLine: ${e.message}")
                    // Non-critical error, continue
                }
            }
            
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

    private fun sendVerificationCode(email: String, countryCodeArg: String?, result: MethodChannel.Result) {
        Log.d("TuyaSDK", "Sending verification code to: $email")
        
        // Validate email format
        if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            Log.e("TuyaSDK", "Invalid email format: $email")
            result.error("INVALID_EMAIL", "Invalid email format", null)
            return
        }
        
        // Resolve country code: prefer argument, fall back to device locale country
        val localeCountry = try { resources.configuration.locales[0].country } catch (e: Exception) { null }
        val countryCode = (countryCodeArg ?: localeCountry ?: "US").uppercase()

        // Check if SDK is properly initialized
        val userInstance = ThingHomeSdk.getUserInstance()
        if (userInstance == null) {
            Log.e("TuyaSDK", "User instance is null - SDK not properly initialized")
            result.error("SDK_NOT_INITIALIZED", "SDK not properly initialized", null)
            return
        }
        
        Log.d("TuyaSDK", "User instance found, calling sendVerifyCodeWithUserName with country: $countryCode")
        
        try {
            ThingHomeSdk.getUserInstance().sendVerifyCodeWithUserName(
                email,
                null, // Region code, can be null
                "1", // Country code
                1, // 1 for registration
                object : IResultCallback {
                    override fun onSuccess() {
                        Log.d("TuyaSDK", "Verification code sent successfully to: $email")
                        result.success("Verification code sent successfully")
                    }

                    override fun onError(code: String?, error: String?) {
                        Log.e("TuyaSDK", "Failed to send verification code - Code: $code, Error: $error")
                        result.error("SEND_CODE_FAILED", "Code: $code, Error: $error", null)
                    }
                }
            )
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Exception while sending verification code: ${e.message}", e)
            result.error("SEND_CODE_EXCEPTION", "Exception while sending verification code: ${e.message}", null)
        }
    }

    private fun registerUser(email: String, password: String, verificationCode: String, countryCodeArg: String?, result: MethodChannel.Result) {
        Log.d("TuyaSDK", "Registering user with email: $email")
        
        // Validate inputs
        if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            Log.e("TuyaSDK", "Invalid email format: $email")
            result.error("INVALID_EMAIL", "Invalid email format", null)
            return
        }
        
        if (password.length < 6) {
            Log.e("TuyaSDK", "Password too short: ${password.length}")
            result.error("INVALID_PASSWORD", "Password must be at least 6 characters", null)
            return
        }
        
        if (verificationCode.length < 4) {
            Log.e("TuyaSDK", "Verification code too short: ${verificationCode.length}")
            result.error("INVALID_VERIFICATION_CODE", "Verification code must be at least 4 characters", null)
            return
        }
        
        // Check if SDK is properly initialized
        val userInstance = ThingHomeSdk.getUserInstance()
        if (userInstance == null) {
            Log.e("TuyaSDK", "User instance is null - SDK not properly initialized")
            result.error("SDK_NOT_INITIALIZED", "SDK not properly initialized", null)
            return
        }
        
        // Resolve country code: prefer argument, fall back to device locale country
        val localeCountry = try { resources.configuration.locales[0].country } catch (e: Exception) { null }
        val countryCode = (countryCodeArg ?: localeCountry ?: "US").uppercase()

        Log.d("TuyaSDK", "User instance found, calling registerAccountWithEmail with country: $countryCode")
        
        try {
            ThingHomeSdk.getUserInstance().registerAccountWithEmail(
                "1",
                email,
                password,
                verificationCode,
                object : IRegisterCallback {
                    override fun onSuccess(user: User?) {
                        Log.d("TuyaSDK", "User registered successfully: ${user?.email}")
                        val userData = mapOf(
                            "id" to (user?.uid ?: ""),
                            "email" to (user?.email ?: email),
                            "name" to (user?.username ?: email.split("@")[0]),
                        )
                        result.success(userData)
                    }

                    override fun onError(code: String?, error: String?) {
                        Log.e("TuyaSDK", "Registration failed - Code: $code, Error: $error")
                        result.error("REGISTRATION_FAILED", "Code: $code, Error: $error", null)
                    }
                }
            )
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Exception while registering user: ${e.message}", e)
            result.error("REGISTRATION_EXCEPTION", "Exception while registering user: ${e.message}", null)
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
                // BEST PRACTICE: Clear panel cache before opening to prevent stale UI and lag issues
                // This fixes the "panel won't re-enter" issue
                val cacheService = MicroContext.getServiceManager()
                    .findServiceByInterface(ClearCacheService::class.java.name) as? ClearCacheService
                if (cacheService != null) {
                    Log.d("TuyaSDK", "🧹 Clearing panel cache to prevent lag...")
                    cacheService.clearCache(this)
                    // Give cache clear operation time to complete
                    Thread.sleep(100)
                } else {
                    Log.w("TuyaSDK", "⚠️ ClearCacheService not available")
                }
                
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
                result.success(true)
                
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

    /**
     * Scan QR Code for Device Pairing
     * Official Tuya Documentation: https://developer.tuya.com/en/docs/app-development/Scan-the-QR-code-of-the-device-configuration?id=Kaixkxky0f221
     * 
     * This method:
     * 1. Opens QR code scanner
     * 2. Parses the QR code URL to get device UUID
     * 3. Starts QR code device pairing
     */
    private fun scanQRCodeForPairing(result: MethodChannel.Result) {
        try {
            Log.d("TuyaSDK", "════════════════════════════════════════")
            Log.d("TuyaSDK", "📷 Starting QR code scan for device pairing")
            Log.d("TuyaSDK", "════════════════════════════════════════")
            
            // Check camera permission first
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) 
                != PackageManager.PERMISSION_GRANTED) {
                Log.w("TuyaSDK", "⚠️ Camera permission not granted, requesting...")
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.CAMERA),
                    1002
                )
                result.error("CAMERA_PERMISSION_REQUIRED", "Camera permission is required for QR code scanning", null)
                return
            }
            
            // Check if user is logged in
            val user = ThingHomeSdk.getUserInstance().user
            if (user == null) {
                Log.e("TuyaSDK", "❌ User not logged in")
                result.error("USER_NOT_LOGGED_IN", "User must be logged in to pair devices", null)
                return
            }
            
            // Get current home ID
            val serviceManager = MicroServiceManager.getInstance()
            val familyService = serviceManager?.findServiceByInterface(
                AbsBizBundleFamilyService::class.java.name
            ) as? AbsBizBundleFamilyService
            
            var homeId: Long = 0
            if (familyService != null) {
                homeId = familyService.currentHomeId
                if (homeId <= 0) {
                    // Try to get first home
                    ThingHomeSdk.getHomeManagerInstance().queryHomeList(object : IThingGetHomeListCallback {
                        override fun onSuccess(homeBeans: MutableList<HomeBean>?) {
                            if (!homeBeans.isNullOrEmpty()) {
                                val firstHome = homeBeans[0]
                                familyService.shiftCurrentFamily(firstHome.homeId, firstHome.name)
                                homeId = firstHome.homeId
                                Log.d("TuyaSDK", "✅ Set current home: ${firstHome.name} (ID: $homeId)")
                                // Now start QR scanner
                                startQRCodeScanner(homeId, result)
                            } else {
                                Log.e("TuyaSDK", "❌ No homes found")
                                result.error("NO_HOME", "Please create a home before pairing devices", null)
                            }
                        }
                        
                        override fun onError(code: String?, error: String?) {
                            Log.e("TuyaSDK", "❌ Failed to get home list: $code - $error")
                            result.error("HOME_ERROR", "Failed to get home: $error", null)
                        }
                    })
                    return
                }
            } else {
                Log.e("TuyaSDK", "❌ Family service not available")
                result.error("FAMILY_SERVICE_NULL", "Family service not initialized", null)
                return
            }
            
            // Start QR scanner
            startQRCodeScanner(homeId, result)
            
        } catch (e: Exception) {
            Log.e("TuyaSDK", "❌ Exception in scanQRCodeForPairing: ${e.message}", e)
            result.error("QR_SCAN_ERROR", "Exception: ${e.message}", null)
        }
    }
    
    /**
     * Start QR Code Scanner using ZXing (via reflection)
     */
    private fun startQRCodeScanner(homeId: Long, result: MethodChannel.Result) {
        try {
            Log.d("TuyaSDK", "📷 Opening QR code scanner...")
            
            // Use reflection to access ZXing ScanIntentIntegrator
            val integratorClass = Class.forName("com.journeyapps.barcodescanner.ScanIntentIntegrator")
            val integrator = integratorClass.getConstructor(android.app.Activity::class.java).newInstance(this)
            
            // Configure QR code scanner
            val setDesiredBarcodeFormatsMethod = integratorClass.getMethod("setDesiredBarcodeFormats", Array<String>::class.java)
            val qrCodeFormat = integratorClass.getField("QR_CODE").get(null) as String
            setDesiredBarcodeFormatsMethod.invoke(integrator, arrayOf(qrCodeFormat))
            
            val setPromptMethod = integratorClass.getMethod("setPrompt", String::class.java)
            setPromptMethod.invoke(integrator, "Scan device QR code")
            
            val setCameraIdMethod = integratorClass.getMethod("setCameraId", Int::class.javaPrimitiveType)
            setCameraIdMethod.invoke(integrator, 0) // Use back camera
            
            val setBeepEnabledMethod = integratorClass.getMethod("setBeepEnabled", Boolean::class.javaPrimitiveType)
            setBeepEnabledMethod.invoke(integrator, true)
            
            val setBarcodeImageEnabledMethod = integratorClass.getMethod("setBarcodeImageEnabled", Boolean::class.javaPrimitiveType)
            setBarcodeImageEnabledMethod.invoke(integrator, false)
            
            val setOrientationLockedMethod = integratorClass.getMethod("setOrientationLocked", Boolean::class.javaPrimitiveType)
            setOrientationLockedMethod.invoke(integrator, false)
            
            // Start scan activity
            val initiateScanMethod = integratorClass.getMethod("initiateScan")
            initiateScanMethod.invoke(integrator)
            
            // Store result callback for onActivityResult
            pendingQRScanResult = result
            pendingQRScanHomeId = homeId
            
            Log.d("TuyaSDK", "✅ QR code scanner started")
            
        } catch (e: Exception) {
            Log.e("TuyaSDK", "❌ Failed to start QR scanner: ${e.message}", e)
            Log.e("TuyaSDK", "   Stack trace: ${e.stackTrace.joinToString("\n")}")
            result.error("SCANNER_START_FAILED", "Failed to start QR scanner: ${e.message}", null)
        }
    }
    
    // Store pending QR scan result
    private var pendingQRScanResult: MethodChannel.Result? = null
    private var pendingQRScanHomeId: Long = 0
    
    /**
     * Handle QR code scan result
     * Per official Tuya documentation: https://developer.tuya.com/en/docs/app-development/Scan-the-QR-code-of-the-device-configuration?id=Kaixkxky0f221
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        // Parse QR code scan result using reflection
        try {
            val integratorClass = Class.forName("com.journeyapps.barcodescanner.ScanIntentIntegrator")
            val parseActivityResultMethod = integratorClass.getMethod(
                "parseActivityResult",
                Int::class.javaPrimitiveType,
                Int::class.javaPrimitiveType,
                Intent::class.java
            )
            val scanResult = parseActivityResultMethod.invoke(null, requestCode, resultCode, data)
            
            if (scanResult != null) {
                val contentsField = scanResult.javaClass.getDeclaredField("contents")
                contentsField.isAccessible = true
                val qrCodeUrl = contentsField.get(scanResult) as? String
                
                if (qrCodeUrl != null && qrCodeUrl.isNotEmpty()) {
                    Log.d("TuyaSDK", "✅ QR code scanned: $qrCodeUrl")
                    
                    // Parse QR code to get UUID (Step 1 from official docs)
                    parseQRCodeAndPair(qrCodeUrl, pendingQRScanHomeId, pendingQRScanResult)
                    
                    // Clear pending
                    pendingQRScanResult = null
                    pendingQRScanHomeId = 0
                } else {
                    Log.d("TuyaSDK", "❌ QR code scan cancelled or failed")
                    pendingQRScanResult?.error("QR_SCAN_CANCELLED", "QR code scan was cancelled", null)
                    pendingQRScanResult = null
                    pendingQRScanHomeId = 0
                }
            } else {
                Log.d("TuyaSDK", "❌ QR code scan cancelled or failed")
                pendingQRScanResult?.error("QR_SCAN_CANCELLED", "QR code scan was cancelled", null)
                pendingQRScanResult = null
                pendingQRScanHomeId = 0
            }
        } catch (e: Exception) {
            Log.e("TuyaSDK", "❌ Error parsing QR scan result: ${e.message}", e)
            pendingQRScanResult?.error("QR_SCAN_PARSE_ERROR", "Failed to parse QR scan result: ${e.message}", null)
            pendingQRScanResult = null
            pendingQRScanHomeId = 0
        }
    }
    
    /**
     * Parse QR Code and Start Pairing
     * Official Tuya Documentation: https://developer.tuya.com/en/docs/app-development/Scan-the-QR-code-of-the-device-configuration?id=Kaixkxky0f221
     * Using reflection to access Tuya SDK classes that may not be directly importable
     */
    private fun parseQRCodeAndPair(qrCodeUrl: String, homeId: Long, result: MethodChannel.Result?) {
        try {
            Log.d("TuyaSDK", "════════════════════════════════════════")
            Log.d("TuyaSDK", "🔍 Parsing QR code: $qrCodeUrl")
            Log.d("TuyaSDK", "   Home ID: $homeId")
            Log.d("TuyaSDK", "════════════════════════════════════════")
            
            // Step 1: Parse QR code to get UUID using reflection
            // Per official docs: ThingHomeSdk.getActivatorInstance().deviceQrCodeParse()
            try {
                val activatorInstance = ThingHomeSdk.getActivatorInstance()
                val parseMethod = activatorInstance.javaClass.getMethod(
                    "deviceQrCodeParse",
                    String::class.java,
                    Class.forName("com.thingclips.smart.sdk.api.IThingDataCallback")
                )
                
                // Create callback using reflection
                val callbackClass = Class.forName("com.thingclips.smart.sdk.api.IThingDataCallback")
                val callback = java.lang.reflect.Proxy.newProxyInstance(
                    callbackClass.classLoader,
                    arrayOf(callbackClass)
                ) { _, method, args ->
                    when (method.name) {
                        "onSuccess" -> {
                            val qrScanBean = args?.get(0)
                            if (qrScanBean != null) {
                                try {
                                    // Get actionData field using reflection
                                    val actionDataField = qrScanBean.javaClass.getDeclaredField("actionData")
                                    actionDataField.isAccessible = true
                                    val uuid = actionDataField.get(qrScanBean) as? String
                                    
                                    if (uuid != null && uuid.isNotEmpty()) {
                                        Log.d("TuyaSDK", "✅ QR code parsed successfully")
                                        Log.d("TuyaSDK", "   Device UUID: $uuid")
                                        
                                        // Start pairing with UUID
                                        startQRCodePairing(uuid, homeId, result)
                                    } else {
                                        Log.e("TuyaSDK", "❌ Invalid UUID from QR code")
                                        result?.error("INVALID_QR_CODE", "QR code does not contain valid device UUID", null)
                                    }
                                } catch (e: Exception) {
                                    Log.e("TuyaSDK", "❌ Error extracting UUID: ${e.message}", e)
                                    result?.error("UUID_EXTRACTION_ERROR", "Failed to extract UUID: ${e.message}", null)
                                }
                            } else {
                                Log.e("TuyaSDK", "❌ Invalid QR code result")
                                result?.error("INVALID_QR_CODE", "QR code does not contain valid device information", null)
                            }
                            null
                        }
                        "onError" -> {
                            val errorCode = args?.get(0) as? String
                            val errorMessage = args?.get(1) as? String
                            Log.e("TuyaSDK", "❌ QR code parse error: $errorCode - $errorMessage")
                            result?.error(
                                errorCode ?: "QR_PARSE_ERROR",
                                errorMessage ?: "Failed to parse QR code",
                                null
                            )
                            null
                        }
                        else -> null
                    }
                }
                
                parseMethod.invoke(activatorInstance, qrCodeUrl, callback)
                Log.d("TuyaSDK", "✅ QR code parse method called")
                
            } catch (e: Exception) {
                Log.e("TuyaSDK", "❌ Exception parsing QR code with reflection: ${e.message}", e)
                Log.e("TuyaSDK", "   Stack trace: ${e.stackTrace.joinToString("\n")}")
                result?.error("QR_PARSE_EXCEPTION", "Exception: ${e.message}", null)
            }
            
        } catch (e: Exception) {
            Log.e("TuyaSDK", "❌ Exception in parseQRCodeAndPair: ${e.message}", e)
            result?.error("QR_PARSE_EXCEPTION", "Exception: ${e.message}", null)
        }
    }
    
    /**
     * Start QR Code Pairing with UUID
     * Uses reflection to access Tuya SDK QR code activator classes
     */
    private fun startQRCodePairing(uuid: String, homeId: Long, result: MethodChannel.Result?) {
        try {
            Log.d("TuyaSDK", "🚀 Starting QR code device pairing with UUID: $uuid")
            
            // Use reflection to create QR code activator
            val activatorInstance = ThingHomeSdk.getActivatorInstance()
            
            // Try to create QR code activator builder using reflection
            try {
                val builderClass = Class.forName("com.thingclips.smart.home.sdk.activator.ThingQRCodeActivatorBuilder")
                val builder = builderClass.getDeclaredConstructor().newInstance()
                
                // Set UUID
                val setUuidMethod = builderClass.getMethod("setUuid", String::class.java)
                setUuidMethod.invoke(builder, uuid)
                
                // Set Home ID
                val setHomeIdMethod = builderClass.getMethod("setHomeId", Long::class.javaPrimitiveType)
                setHomeIdMethod.invoke(builder, homeId)
                
                // Set Context
                val setContextMethod = builderClass.getMethod("setContext", android.content.Context::class.java)
                setContextMethod.invoke(builder, this)
                
                // Set Timeout
                val setTimeoutMethod = builderClass.getMethod("setTimeOut", Int::class.javaPrimitiveType)
                setTimeoutMethod.invoke(builder, 100)
                
                // Create listener using reflection
                val listenerClass = Class.forName("com.thingclips.smart.home.sdk.activator.IThingSmartActivatorListener")
                val listener = java.lang.reflect.Proxy.newProxyInstance(
                    listenerClass.classLoader,
                    arrayOf(listenerClass)
                ) { _, method, args ->
                    when (method.name) {
                        "onError" -> {
                            val errorCode = args?.get(0) as? String
                            val errorMsg = args?.get(1) as? String
                            Log.e("TuyaSDK", "❌ Device pairing error: $errorCode - $errorMsg")
                            result?.error(
                                errorCode ?: "PAIRING_ERROR",
                                errorMsg ?: "Device pairing failed",
                                null
                            )
                            null
                        }
                        "onActiveSuccess" -> {
                            val devResp = args?.get(0)
                            if (devResp != null) {
                                try {
                                    val devIdField = devResp.javaClass.getDeclaredField("devId")
                                    devIdField.isAccessible = true
                                    val devId = devIdField.get(devResp) as? String
                                    
                                    val nameField = devResp.javaClass.getDeclaredField("name")
                                    nameField.isAccessible = true
                                    val name = nameField.get(devResp) as? String
                                    
                                    Log.d("TuyaSDK", "✅ Device paired successfully!")
                                    Log.d("TuyaSDK", "   Device ID: $devId")
                                    Log.d("TuyaSDK", "   Device Name: $name")
                                    result?.success(mapOf(
                                        "deviceId" to (devId ?: ""),
                                        "deviceName" to (name ?: ""),
                                        "success" to true
                                    ))
                                } catch (e: Exception) {
                                    Log.e("TuyaSDK", "❌ Error extracting device info: ${e.message}", e)
                                    result?.success(mapOf("success" to true))
                                }
                            }
                            null
                        }
                        "onStep" -> {
                            val step = args?.get(0) as? String
                            Log.d("TuyaSDK", "📋 Pairing step: $step")
                            null
                        }
                        else -> null
                    }
                }
                
                // Set listener
                val setListenerMethod = builderClass.getMethod("setListener", listenerClass)
                setListenerMethod.invoke(builder, listener)
                
                // Create activator
                val newQRCodeDevActivatorMethod = activatorInstance.javaClass.getMethod(
                    "newQRCodeDevActivator",
                    builderClass
                )
                val activator = newQRCodeDevActivatorMethod.invoke(activatorInstance, builder)
                
                // Start pairing
                val startMethod = activator?.javaClass?.getMethod("start")
                startMethod?.invoke(activator)
                
                // Store activator for cleanup
                qrCodeActivator = activator
                
                Log.d("TuyaSDK", "🚀 QR code device pairing started")
                
            } catch (e: Exception) {
                Log.e("TuyaSDK", "❌ Exception creating QR code activator: ${e.message}", e)
                Log.e("TuyaSDK", "   Stack trace: ${e.stackTrace.joinToString("\n")}")
                result?.error("ACTIVATOR_CREATION_ERROR", "Failed to create QR code activator: ${e.message}", null)
            }
            
        } catch (e: Exception) {
            Log.e("TuyaSDK", "❌ Exception in startQRCodePairing: ${e.message}", e)
            result?.error("PAIRING_START_ERROR", "Exception: ${e.message}", null)
        }
    }

    /**
     * Execute a manual scene (Tap to Run)
     * Per Tuya SDK documentation for Scene BizBundle
     * https://developer.tuya.com/en/docs/app-development/scene?id=Ka8qf8lmlptsr
     */
    private fun executeScene(sceneId: String, result: MethodChannel.Result) {
        try {
            Log.d("TuyaSDK", "════════════════════════════════════════")
            Log.d("TuyaSDK", "▶️ Executing scene (Tap to Run)")
            Log.d("TuyaSDK", "   Scene ID: $sceneId")
            Log.d("TuyaSDK", "════════════════════════════════════════")
            
            // Use ThingSmartScene to execute the manual scene
            // Create scene instance with scene ID
            val scene = ThingHomeSdk.newSceneInstance(sceneId)
            if (scene == null) {
                Log.e("TuyaSDK", "❌ Failed to create scene instance")
                result.error("SCENE_INSTANCE_NULL", "Failed to create scene instance", null)
                return
            }
            
            // Execute the scene
            scene.executeScene(object : IResultCallback {
                override fun onSuccess() {
                    Log.d("TuyaSDK", "✅ Scene executed successfully: $sceneId")
                    result.success(true)
                }
                
                override fun onError(errorCode: String?, errorMessage: String?) {
                    Log.e("TuyaSDK", "❌ Scene execution failed: $errorCode - $errorMessage")
                    result.error(
                        errorCode ?: "SCENE_EXECUTION_FAILED",
                        errorMessage ?: "Failed to execute scene",
                        null
                    )
                }
            })
            
        } catch (e: Exception) {
            Log.e("TuyaSDK", "❌ Exception executing scene: ${e.message}", e)
            result.error("SCENE_EXECUTION_ERROR", "Exception: ${e.message}", null)
        }
    }


    // Store pending pairing request to retry after permissions granted
    private var pendingPairingRequest: MethodChannel.Result? = null

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        when (requestCode) {
            1001 -> {
                if (grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                    Log.d("TuyaSDK", "✅ All permissions granted, starting device pairing")
                    // Retry pairing now that permissions are granted
                    pendingPairingRequest?.let { result ->
                        pendingPairingRequest = null
                        // Retry pairing after a short delay to ensure permissions are fully processed
                        handler.postDelayed({
                            startDevicePairingInternal(result)
                        }, 500)
                    }
                } else {
                    Log.e("TuyaSDK", "❌ Permissions denied, cannot start device pairing")
                    pendingPairingRequest?.error(
                        "PERMISSIONS_DENIED",
                        "Required permissions were denied. Please grant permissions in app settings.",
                        null
                    )
                    pendingPairingRequest = null
                }
            }
            1002 -> {
                // QR Code scanner camera permission
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    Log.d("TuyaSDK", "✅ Camera permission granted for QR code scanning")
                    // Retry QR code scanning
                    if (pendingQRScanHomeId > 0 && pendingQRScanResult != null) {
                        val homeId = pendingQRScanHomeId
                        val result = pendingQRScanResult
                        pendingQRScanHomeId = 0
                        pendingQRScanResult = null
                        handler.postDelayed({
                            startQRCodeScanner(homeId, result!!)
                        }, 300)
                    }
                } else {
                    Log.e("TuyaSDK", "❌ Camera permission denied for QR code scanning")
                    pendingQRScanResult?.error(
                        "CAMERA_PERMISSION_DENIED",
                        "Camera permission is required for QR code scanning. Please grant permission in app settings.",
                        null
                    )
                    pendingQRScanResult = null
                    pendingQRScanHomeId = 0
                }
            }
        }
    }
    
    private val handler = android.os.Handler(android.os.Looper.getMainLooper())

    private fun pairDevices(result: MethodChannel.Result) {
        try {
            Log.d("TuyaSDK", "════════════════════════════════════════")
            Log.d("TuyaSDK", "🚀 Starting device pairing flow")
            Log.d("TuyaSDK", "════════════════════════════════════════")

            // Check if the user is logged in before starting device pairing
            val user = ThingHomeSdk.getUserInstance().user
            if (user == null) {
                Log.e("TuyaSDK", "❌ User not logged in, cannot start device pairing")
                result.error("USER_NOT_LOGGED_IN", "User must be logged in to pair devices", null)
                return
            }

            Log.d("TuyaSDK", "✅ User is logged in: ${user.email}")

            // CRITICAL: Check and request permissions BEFORE opening BizBundle UI
            // BizBundle UI will crash if permissions aren't granted when scan button is pressed
            if (!checkPermissions()) {
                Log.d("TuyaSDK", "⚠️ Permissions not granted, requesting now...")
                Log.d("TuyaSDK", "   Storing pairing request to retry after permissions granted")
                pendingPairingRequest = result
                requestPermissions()
                // Don't return success yet - wait for permissions to be granted
                return
            }

            Log.d("TuyaSDK", "✅ All permissions granted, proceeding with pairing")
            startDevicePairingInternal(result)
        } catch (e: Exception) {
            Log.e("TuyaSDK", "❌ Failed to start device pairing: ${e.message}", e)
            result.error("PAIR_FAILED", "Failed to start device pairing: ${e.message}", null)
        }
    }
    
    private fun startDevicePairingInternal(result: MethodChannel.Result) {
        try {
            Log.d("TuyaSDK", "════════════════════════════════════════")
            Log.d("TuyaSDK", "🔧 Starting device activator")
            Log.d("TuyaSDK", "════════════════════════════════════════")

            try {
                // Double-check permissions are still granted (safety check)
                if (!checkPermissions()) {
                    Log.e("TuyaSDK", "❌ Permissions were revoked, cannot start pairing")
                    result.error("PERMISSIONS_REVOKED", "Required permissions are not granted", null)
                    return
                }
                
                // Check if we have a valid context
                Log.d("TuyaSDK", "✅ Context valid: ${this.javaClass.name}")
                
                // Try the BizBundle UI approach now that theme is properly configured
                Log.d("TuyaSDK", "🎯 Attempting to start BizBundle device pairing UI")
                Log.d("TuyaSDK", "   All permissions verified before opening UI")

                try {
                    // OFFICIAL TUYA DOCUMENTATION METHOD:
                    // Per official docs: https://developer.tuya.com/en/docs/app-development/activator
                    // CRITICAL: Ensure home context is set before opening device activator UI
                    val serviceManager = MicroServiceManager.getInstance()
                    val familyService = serviceManager?.findServiceByInterface(
                        AbsBizBundleFamilyService::class.java.name
                    ) as? AbsBizBundleFamilyService
                    
                    if (familyService != null) {
                        var currentHomeId = familyService.currentHomeId
                        if (currentHomeId <= 0) {
                            // No home set, try to get the first home from user's home list
                            Log.w("TuyaSDK", "⚠️ No current home set, attempting to get first home...")
                            ThingHomeSdk.getHomeManagerInstance().queryHomeList(object : IThingGetHomeListCallback {
                                override fun onSuccess(homeBeans: MutableList<HomeBean>?) {
                                    if (!homeBeans.isNullOrEmpty()) {
                                        val firstHome = homeBeans[0]
                                        familyService.shiftCurrentFamily(firstHome.homeId, firstHome.name)
                                        Log.d("TuyaSDK", "✅ Set current home: ${firstHome.name} (ID: ${firstHome.homeId})")
                                    } else {
                                        Log.e("TuyaSDK", "❌ No homes found, user must create a home first")
                                    }
                                }
                                
                                override fun onError(code: String?, error: String?) {
                                    Log.e("TuyaSDK", "❌ Failed to get home list: $code - $error")
                                }
                            })
                            // Wait a moment for home to be set
                            Thread.sleep(500)
                            currentHomeId = familyService.currentHomeId
                        }
                        
                        if (currentHomeId > 0) {
                            Log.d("TuyaSDK", "✅ Current home ID: $currentHomeId")
                        } else {
                            Log.e("TuyaSDK", "❌ No home available, device pairing requires a home")
                            result.error("NO_HOME", "Please create a home before pairing devices", null)
                            return
                        }
                    } else {
                        Log.e("TuyaSDK", "❌ Family service not available")
                        result.error("FAMILY_SERVICE_NULL", "Family service not initialized", null)
                        return
                    }
                    
                    // Start device activator UI - this includes QR code scanning
                    // Per official Tuya documentation, this method opens the full pairing UI
                    ThingDeviceActivatorManager.startDeviceActiveAction(this)
                    Log.d("TuyaSDK", "✅ BizBundle device pairing UI started successfully")
                    Log.d("TuyaSDK", "   Camera scanning is now available in the UI")
                    result.success("Device pairing UI started successfully")
                } catch (uiException: Exception) {
                    Log.e(
                        "TuyaSDK",
                        "BizBundle UI failed, falling back to core scanning: ${uiException.message}"
                    )

                    // Fallback to core activator scanning if UI fails
                    Log.d("TuyaSDK", "Using core activator approach as fallback")
                    
                    // Configure scan builder (timeout is handled by SDK default or can be set if method exists)
                    val scanBuilder = ThingActivatorScanBuilder()
                    
                    // Try to set timeout if method exists (120 seconds recommended by Tuya)
                    try {
                        val timeoutMethod = scanBuilder.javaClass.getMethod("setTimeout", Int::class.javaPrimitiveType)
                        timeoutMethod.invoke(scanBuilder, 120)
                        Log.d("TuyaSDK", "Scan timeout set to 120 seconds")
                    } catch (e: Exception) {
                        Log.d("TuyaSDK", "Timeout method not available, using default")
                    }
                    
                    Log.d("TuyaSDK", "Starting device scan")
                    Log.d("TuyaSDK", "Scanning for Wi-Fi and Bluetooth devices...")

                    ThingActivatorCoreKit.getScanDeviceManager()
                        .startScan(scanBuilder, object : ThingActivatorScanCallback {
                            override fun deviceFound(deviceBean: ThingActivatorScanDeviceBean) {
                                Log.d("TuyaSDK", "═══════════════════════════════════════")
                                Log.d("TuyaSDK", "✅ Device FOUND!")
                                Log.d("TuyaSDK", "   Name: ${deviceBean.name}")
                                
                                // Safely access properties that may exist
                                try {
                                    val uuidField = deviceBean.javaClass.getDeclaredField("uuid")
                                    uuidField.isAccessible = true
                                    val uuid = uuidField.get(deviceBean) as? String
                                    if (uuid != null) {
                                        Log.d("TuyaSDK", "   UUID: $uuid")
                                    }
                                } catch (e: Exception) {
                                    // UUID field not available
                                }
                                
                                try {
                                    val productIdField = deviceBean.javaClass.getDeclaredField("productId")
                                    productIdField.isAccessible = true
                                    val productId = productIdField.get(deviceBean) as? String
                                    if (productId != null) {
                                        Log.d("TuyaSDK", "   Product ID: $productId")
                                    }
                                } catch (e: Exception) {
                                    // ProductId field not available
                                }
                                
                                Log.d("TuyaSDK", "   Device: ${deviceBean.toString()}")
                                Log.d("TuyaSDK", "═══════════════════════════════════════")
                                
                                // You can implement UI to show discovered devices here
                                // For now, logging the device information
                            }

                            override fun deviceRepeat(deviceBean: ThingActivatorScanDeviceBean) {
                                Log.d("TuyaSDK", "⚡ Device repeat: ${deviceBean.name}")
                            }

                            override fun deviceUpdate(deviceBean: ThingActivatorScanDeviceBean) {
                                Log.d("TuyaSDK", "🔄 Device update: ${deviceBean.name}")
                            }

                            override fun scanFailure(failureBean: ThingActivatorScanFailureBean) {
                                Log.e("TuyaSDK", "❌ Scan failed!")
                                Log.e("TuyaSDK", "   Error Code: ${failureBean.errorCode}")
                                Log.e("TuyaSDK", "   Error Message: ${failureBean.errorMsg}")
                            }

                            override fun scanFinish() {
                                Log.d("TuyaSDK", "✅ Device scan finished (after timeout or manual stop)")
                            }
                        })

                    Log.d("TuyaSDK", "✅ Device scanning started successfully")
                    Log.d("TuyaSDK", "   Make sure devices are in pairing mode!")
                    result.success("Device scanning started - Check logs for discovered devices")
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

        // CRITICAL: Check camera permission (required for QR code scanning in device pairing)
        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.CAMERA
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            permissions.add(Manifest.permission.CAMERA)
        }

        // Check location permission (required for Wi-Fi and BLE device pairing)
        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            permissions.add(Manifest.permission.ACCESS_FINE_LOCATION)
        }

        // Check Bluetooth permissions for Android 12+ (API 31+)
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
            // BLUETOOTH_ADVERTISE is needed for some device types
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.BLUETOOTH_ADVERTISE
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                permissions.add(Manifest.permission.BLUETOOTH_ADVERTISE)
            }
        }

        // Check notification permission for Android 13+ (API 33+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                permissions.add(Manifest.permission.POST_NOTIFICATIONS)
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

        // For Android 13+ (API 33+), check READ_MEDIA_IMAGES
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.READ_MEDIA_IMAGES
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                permissions.add(Manifest.permission.READ_MEDIA_IMAGES)
            }
        }

        return permissions.isEmpty()
    }

    private fun requestPermissions() {
        val permissions = mutableListOf<String>()

        // CRITICAL: Request camera permission (required for QR code scanning in device pairing)
        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.CAMERA
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            permissions.add(Manifest.permission.CAMERA)
        }

        // Request location permission (required for Wi-Fi and BLE device pairing)
        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            permissions.add(Manifest.permission.ACCESS_FINE_LOCATION)
        }

        // Request Bluetooth permissions for Android 12+ (API 31+)
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
            // BLUETOOTH_ADVERTISE is needed for some device types
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.BLUETOOTH_ADVERTISE
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                permissions.add(Manifest.permission.BLUETOOTH_ADVERTISE)
            }
        }

        // Request notification permission for Android 13+ (API 33+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                permissions.add(Manifest.permission.POST_NOTIFICATIONS)
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

        // For Android 13+ (API 33+), request READ_MEDIA_IMAGES
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.READ_MEDIA_IMAGES
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                permissions.add(Manifest.permission.READ_MEDIA_IMAGES)
            }
        }

        if (permissions.isNotEmpty()) {
            Log.d("TuyaSDK", "Requesting permissions: ${permissions.joinToString(", ")}")
            ActivityCompat.requestPermissions(this, permissions.toTypedArray(), 1001)
        }
    }


    private fun openScenesBizBundle(homeId: Long, homeName: String, result: MethodChannel.Result) {
        try {
            Log.d("TuyaSDK", "════════════════════════════════════════")
            Log.d("TuyaSDK", "🎬 Opening Scenes BizBundle UI")
            Log.d("TuyaSDK", "   Home ID: $homeId")
            Log.d("TuyaSDK", "   Home Name: $homeName")
            Log.d("TuyaSDK", "════════════════════════════════════════")
            
            // CRITICAL: Set the current family ID before opening Scene UI
            val serviceManager = MicroServiceManager.getInstance()
            if (serviceManager == null) {
                Log.e("TuyaSDK", "❌ MicroServiceManager is null")
                result.error("SERVICE_MANAGER_NULL", "MicroServiceManager is not initialized", null)
                return
            }
            
            // 1. Switch to the correct family first
            val familyService = serviceManager.findServiceByInterface(
                AbsBizBundleFamilyService::class.java.name
            ) as? AbsBizBundleFamilyService
            
            if (familyService == null) {
                Log.e("TuyaSDK", "❌ AbsBizBundleFamilyService not found")
                result.error("FAMILY_SERVICE_NULL", "Family service not initialized", null)
                return
            }
            
            Log.d("TuyaSDK", "✅ Setting current family to: $homeName ($homeId)")
            familyService.shiftCurrentFamily(homeId, homeName)
            
            // 2. Get the Scene Business Service and open scene UI
            Log.d("TuyaSDK", "Getting IThingSceneBusinessService...")
            val sceneService = MicroContext.findServiceByInterface(
                IThingSceneBusinessService::class.java.name
            ) as? IThingSceneBusinessService
            
            if (sceneService == null) {
                Log.e("TuyaSDK", "❌ IThingSceneBusinessService not found")
                result.error("SCENE_SERVICE_NULL", "Scene service not initialized. Please ensure Scene BizBundle is properly configured.", null)
                return
            }
            
            Log.d("TuyaSDK", "✅ IThingSceneBusinessService found, opening add scene UI...")
            // Open the add scene screen
            // requestCode 1001 is used for scene activity result
            sceneService.addBizSceneBean(this, homeId, 1001)
            
            Log.d("TuyaSDK", "✅ Scene UI opened successfully")
            result.success(true)
            
        } catch (e: Exception) {
            Log.e("TuyaSDK", "❌ Error opening Scene BizBundle: ${e.message}", e)
            result.error("SCENE_ERROR", "Failed to open scenes: ${e.message}", null)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Clean up SDK resources when app is destroyed
        ThingHomeSdk.onDestroy()
    }

    // Room Management Methods
    // Based on Tuya SDK patterns - using home instance methods for room management

    private fun addDeviceToRoom(homeId: Long, roomId: Long, deviceId: String, result: MethodChannel.Result) {
        Log.d("TuyaSDK", "➕ Adding device $deviceId to room $roomId in home $homeId")
        
        // Per Tuya docs: Use newRoomInstance and call addDevice on the Room
        try {
            // Try ThingHomeSdk.newRoomInstance (Tuya SDK naming convention)
            val roomInstanceMethod = ThingHomeSdk::class.java.getMethod("newRoomInstance", Long::class.javaPrimitiveType)
            val room = roomInstanceMethod.invoke(null, roomId)
            
            if (room != null) {
                val addDeviceMethod = room.javaClass.getMethod("addDevice", String::class.java, IResultCallback::class.java)
                addDeviceMethod.invoke(room, deviceId, object : IResultCallback {
                    override fun onSuccess() {
                        Log.d("TuyaSDK", "✅ Device $deviceId added to room $roomId successfully")
                        result.success(null)
                    }
                    
                    override fun onError(code: String?, error: String?) {
                        Log.e("TuyaSDK", "❌ Failed to add device to room: $error")
                        result.error(code ?: "ADD_DEVICE_TO_ROOM_FAILED", error ?: "Failed to add device to room", null)
                    }
                })
                return
            }
        } catch (e: NoSuchMethodException) {
            Log.d("TuyaSDK", "newRoomInstance not found, trying home instance method...")
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Room instance approach failed: ${e.message}")
        }
        
        // Fallback: Try home instance with single deviceId
        val home = ThingHomeSdk.newHomeInstance(homeId)
        try {
            val method = home.javaClass.getMethod(
                "addDeviceToRoom",
                Long::class.javaPrimitiveType,
                String::class.java,
                IResultCallback::class.java
            )
            method.invoke(home, roomId, deviceId, object : IResultCallback {
                override fun onSuccess() {
                    Log.d("TuyaSDK", "✅ Device $deviceId added to room $roomId successfully")
                    result.success(null)
                }
                
                override fun onError(code: String?, error: String?) {
                    Log.e("TuyaSDK", "❌ Failed to add device to room: $error")
                    result.error(code ?: "ADD_DEVICE_TO_ROOM_FAILED", error ?: "Failed to add device to room", null)
                }
            })
        } catch (e: Exception) {
            Log.e("TuyaSDK", "❌ All methods failed: ${e.message}")
            Log.e("TuyaSDK", "❌ Stack trace: ${e.stackTraceToString()}")
            result.error(
                "NOT_IMPLEMENTED",
                "Room management not supported by this SDK version. Error: ${e.message}",
                null
            )
        }
    }

    private fun removeDeviceFromRoom(homeId: Long, roomId: Long, deviceId: String, result: MethodChannel.Result) {
        Log.d("TuyaSDK", "➖ Removing device $deviceId from room $roomId in home $homeId")
        
        // Try Room instance approach first
        try {
            val roomInstanceMethod = ThingHomeSdk::class.java.getMethod("newRoomInstance", Long::class.javaPrimitiveType)
            val room = roomInstanceMethod.invoke(null, roomId)
            
            if (room != null) {
                val removeDeviceMethod = room.javaClass.getMethod("removeDevice", String::class.java, IResultCallback::class.java)
                removeDeviceMethod.invoke(room, deviceId, object : IResultCallback {
                    override fun onSuccess() {
                        Log.d("TuyaSDK", "✅ Device $deviceId removed from room $roomId successfully")
                        result.success(null)
                    }
                    
                    override fun onError(code: String?, error: String?) {
                        Log.e("TuyaSDK", "❌ Failed to remove device from room: $error")
                        result.error(code ?: "REMOVE_DEVICE_FROM_ROOM_FAILED", error ?: "Failed to remove device from room", null)
                    }
                })
                return
            }
        } catch (e: NoSuchMethodException) {
            Log.d("TuyaSDK", "newRoomInstance not found, trying home instance method...")
        } catch (e: Exception) {
            Log.e("TuyaSDK", "Room instance approach failed: ${e.message}")
        }
        
        // Fallback: Try home instance
        val home = ThingHomeSdk.newHomeInstance(homeId)
        try {
            val method = home.javaClass.getMethod(
                "removeDeviceFromRoom",
                Long::class.javaPrimitiveType,
                String::class.java,
                IResultCallback::class.java
            )
            method.invoke(home, roomId, deviceId, object : IResultCallback {
                override fun onSuccess() {
                    Log.d("TuyaSDK", "✅ Device $deviceId removed from room $roomId successfully")
                    result.success(null)
                }
                
                override fun onError(code: String?, error: String?) {
                    Log.e("TuyaSDK", "❌ Failed to remove device from room: $error")
                    result.error(code ?: "REMOVE_DEVICE_FROM_ROOM_FAILED", error ?: "Failed to remove device from room", null)
                }
            })
        } catch (e: Exception) {
            Log.e("TuyaSDK", "❌ All methods failed: ${e.message}")
            result.error(
                "NOT_IMPLEMENTED",
                "Room management not supported by this SDK version. Error: ${e.message}",
                null
            )
        }
    }

    private fun updateRoomName(homeId: Long, roomId: Long, name: String, result: MethodChannel.Result) {
        Log.d("TuyaSDK", "✏️ Updating room $roomId name to: $name")
        
        // Try approach 1: TuyaHomeSdk.getRoomInstance(roomId).updateRoom(newName, callback)
        try {
            val getRoomInstanceMethod = ThingHomeSdk::class.java.getMethod("getRoomInstance", Long::class.javaPrimitiveType)
            val room = getRoomInstanceMethod.invoke(null, roomId)
            
            if (room != null) {
                try {
                    val updateMethod = room.javaClass.getMethod("updateRoom", String::class.java, IResultCallback::class.java)
                    updateMethod.invoke(room, name, object : IResultCallback {
                        override fun onSuccess() {
                            Log.d("TuyaSDK", "✅ Room $roomId name updated to: $name")
                            result.success(null)
                        }
                        
                        override fun onError(code: String?, error: String?) {
                            Log.e("TuyaSDK", "❌ Failed to update room name: $error")
                            result.error(code ?: "UPDATE_ROOM_NAME_FAILED", error ?: "Failed to update room name", null)
                        }
                    })
                    return
                } catch (e: Exception) {
                    Log.d("TuyaSDK", "getRoomInstance.updateRoom failed: ${e.message}")
                }
            }
        } catch (e: Exception) {
            Log.d("TuyaSDK", "getRoomInstance not available: ${e.message}")
        }
        
        // Try approach 2: ThingHomeSdk.newRoomInstance(roomId).updateRoom(newName, callback)
        try {
            val newRoomInstanceMethod = ThingHomeSdk::class.java.getMethod("newRoomInstance", Long::class.javaPrimitiveType)
            val room = newRoomInstanceMethod.invoke(null, roomId)
            
            if (room != null) {
                try {
                    val updateMethod = room.javaClass.getMethod("updateRoom", String::class.java, IResultCallback::class.java)
                    updateMethod.invoke(room, name, object : IResultCallback {
                        override fun onSuccess() {
                            Log.d("TuyaSDK", "✅ Room $roomId name updated to: $name")
                            result.success(null)
                        }
                        
                        override fun onError(code: String?, error: String?) {
                            Log.e("TuyaSDK", "❌ Failed to update room name: $error")
                            result.error(code ?: "UPDATE_ROOM_NAME_FAILED", error ?: "Failed to update room name", null)
                        }
                    })
                    return
                } catch (e: Exception) {
                    Log.d("TuyaSDK", "newRoomInstance.updateRoom failed: ${e.message}")
                }
            }
        } catch (e: Exception) {
            Log.d("TuyaSDK", "newRoomInstance not available: ${e.message}")
        }
        
        // Try approach 3: ThingHomeSdk.getHomeManagerInstance().updateRoom(roomId, newName, callback)
        try {
            val homeManager = ThingHomeSdk.getHomeManagerInstance()
            val updateMethod = homeManager.javaClass.getMethod(
                "updateRoom",
                Long::class.javaPrimitiveType,
                String::class.java,
                IResultCallback::class.java
            )
            updateMethod.invoke(homeManager, roomId, name, object : IResultCallback {
                override fun onSuccess() {
                    Log.d("TuyaSDK", "✅ Room $roomId name updated to: $name")
                    result.success(null)
                }
                
                override fun onError(code: String?, error: String?) {
                    Log.e("TuyaSDK", "❌ Failed to update room name: $error")
                    result.error(code ?: "UPDATE_ROOM_NAME_FAILED", error ?: "Failed to update room name", null)
                }
            })
            return
        } catch (e: Exception) {
            Log.e("TuyaSDK", "❌ All room update methods failed: ${e.message}")
        }
        
        result.error(
            "NOT_IMPLEMENTED",
            "Room rename not supported by this SDK version. All known methods failed.",
            null
        )
    }

    private fun removeRoom(homeId: Long, roomId: Long, result: MethodChannel.Result) {
        Log.d("TuyaSDK", "🗑️ Removing room $roomId from home $homeId")
        
        val home = ThingHomeSdk.newHomeInstance(homeId)
        
        // Try removeRoom first, then dismissRoom as fallback
        try {
            home.removeRoom(roomId, object : IResultCallback {
                override fun onSuccess() {
                    Log.d("TuyaSDK", "✅ Room $roomId removed successfully")
                    result.success(null)
                }
                
                override fun onError(code: String?, error: String?) {
                    Log.e("TuyaSDK", "❌ Failed to remove room: $error")
                    result.error(code ?: "REMOVE_ROOM_FAILED", error ?: "Failed to remove room", null)
                }
            })
        } catch (e: NoSuchMethodError) {
            // Fallback to dismissRoom if removeRoom doesn't exist
            try {
                val method = home.javaClass.getMethod("dismissRoom", Long::class.java, IResultCallback::class.java)
                method.invoke(home, roomId, object : IResultCallback {
                    override fun onSuccess() {
                        Log.d("TuyaSDK", "✅ Room $roomId removed successfully")
                        result.success(null)
                    }
                    
                    override fun onError(code: String?, error: String?) {
                        Log.e("TuyaSDK", "❌ Failed to remove room: $error")
                        result.error(code ?: "REMOVE_ROOM_FAILED", error ?: "Failed to remove room", null)
                    }
                })
            } catch (e2: Exception) {
                Log.e("TuyaSDK", "❌ Both removeRoom and dismissRoom not found: ${e2.message}")
                result.error(
                    "NOT_IMPLEMENTED",
                    "Room removal method not available in this SDK version. SDK may need update.",
                    null
                )
            }
        }
    }
}