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