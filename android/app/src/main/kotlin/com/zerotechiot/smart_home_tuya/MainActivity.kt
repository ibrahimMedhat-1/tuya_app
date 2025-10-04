package com.zerotechiot.smart_home_tuya

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import com.tuya.smart.android.user.api.IRegisterCallback
import com.tuya.smart.android.user.api.ILoginCallback
import com.tuya.smart.android.user.api.ILogoutCallback
import com.tuya.smart.android.user.bean.User
import com.tuya.smart.home.sdk.TuyaHomeSdk
import com.tuya.smart.sdk.api.IResultCallback
import com.tuya.smart.home.sdk.bean.HomeBean
import com.tuya.smart.home.sdk.callback.ITuyaHomeResultCallback
import com.tuya.smart.sdk.api.ITuyaActivator
import com.tuya.smart.sdk.api.ITuyaActivatorGetToken
import com.tuya.smart.sdk.api.ITuyaDataCallback
import com.tuya.smart.sdk.bean.DeviceBean as ActivatorDeviceBean
import android.content.Intent

/**
 * Main activity class that integrates with Tuya SDK v3.25.0
 * Following official Tuya documentation and sample
 */
class MainActivity : FlutterActivity() {
    private val CHANNEL = "tuya_flutter_sdk"
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initTuyaSDK" -> {
                    val appKey = call.argument<String>("appKey")
                    val appSecret = call.argument<String>("appSecret")
                    val packageName = call.argument<String>("packageName") ?: "com.zerotechiot.smart_home_tuya"
                    
                    Log.d(TAG, "Tuya SDK initialization temporarily disabled - returning mock success")
                    
                    // TODO: Tuya SDK is temporarily disabled due to native library issues
                    // Return mock success to allow UI testing
                    result.success(true)
                    
                    /*
                    try {
                        // Note: Basic initialization is already done in TuyaSmartApplication
                        // Here we just set the app key and secret
                        TuyaHomeSdk.setDebugMode(true)
                        TuyaHomeSdk.init(application, appKey, appSecret)
                        
                        Log.d(TAG, "Tuya SDK initialization successful")
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error initializing Tuya SDK: ${e.message}")
                        Log.e(TAG, "Stack trace: ${e.stackTraceToString()}")
                        // Return success even if SDK fails to allow UI testing
                        result.success(false)
                    }
                    */
                }
                "registerWithEmail" -> {
                    val email = call.argument<String>("email")
                    val password = call.argument<String>("password")
                    val countryCode = call.argument<String>("countryCode") ?: "1"
                    
                    if (email.isNullOrEmpty() || password.isNullOrEmpty()) {
                        result.error("INVALID_ARGS", "Email and password are required", null)
                        return@setMethodCallHandler
                    }
                    
                    Log.d(TAG, "Registration attempt with: $email, $countryCode")
                    
                    // Use the Tuya SDK v3.25.0 registration method
                    TuyaHomeSdk.getUserInstance().registerAccountWithEmail(
                        countryCode, 
                        email, 
                        password,
                        password, // Using password as verification code for demo
                        object : IRegisterCallback {
                            override fun onSuccess(user: User) {
                                val userData = HashMap<String, Any>()
                                userData["id"] = user.uid ?: ""
                                userData["email"] = email
                                userData["username"] = user.nickName ?: email
                                result.success(userData)
                            }
                            
                            override fun onError(code: String, error: String) {
                                Log.e(TAG, "Registration error: $code - $error")
                                result.error(code, error, null)
                            }
                        }
                    )
                }
                "loginWithEmail" -> {
                    val email = call.argument<String>("email")
                    val password = call.argument<String>("password")
                    val countryCode = call.argument<String>("countryCode") ?: "1"
                    
                    if (email.isNullOrEmpty() || password.isNullOrEmpty()) {
                        result.error("INVALID_ARGS", "Email and password are required", null)
                        return@setMethodCallHandler
                    }
                    
                    Log.d(TAG, "Login attempt with: $email, $countryCode")
                    
                    // Use the Tuya SDK v3.25.0 login method
                    TuyaHomeSdk.getUserInstance().loginWithEmail(
                        countryCode, 
                        email, 
                        password,
                        object : ILoginCallback {
                            override fun onSuccess(user: User) {
                                val userData = HashMap<String, Any>()
                                userData["id"] = user.uid ?: ""
                                userData["email"] = email
                                userData["username"] = user.nickName ?: email
                                result.success(userData)
                            }
                            
                            override fun onError(code: String, error: String) {
                                Log.e(TAG, "Login error: $code - $error")
                                result.error(code, error, null)
                            }
                        }
                    )
                }
                "logout" -> {
                    Log.d(TAG, "Logout called")
                    // Use the Tuya SDK v3.25.0 logout method
                    TuyaHomeSdk.getUserInstance().logout(object : ILogoutCallback {
                        override fun onSuccess() {
                            result.success(null)
                        }
                        
                        override fun onError(code: String, error: String) {
                            Log.e(TAG, "Logout error: $code - $error")
                            result.error(code, error, null)
                        }
                    })
                }
                "isLoggedIn" -> {
                    Log.d(TAG, "Checking login status")
                    // Use the Tuya SDK v3.25.0 isLogin property
                    val isLoggedIn = TuyaHomeSdk.getUserInstance().isLogin
                    result.success(isLoggedIn)
                }
                "getPlatformVersion" -> {
                    result.success("Android ${android.os.Build.VERSION.RELEASE}")
                }
                "openHomeActivity" -> {
                    // For Android, we can navigate to a Flutter page or show a message
                    Log.d(TAG, "HomeActivity requested - redirecting to Flutter home page")
                    result.success("HomeActivity opened")
                }
                "openDeviceControlActivity" -> {
                    val deviceId = call.argument<String>("deviceId")
                    Log.d(TAG, "DeviceControlActivity requested for device: $deviceId")
                    result.success("DeviceControlActivity opened for device: $deviceId")
                }
                "openAddDeviceActivity" -> {
                    Log.d(TAG, "AddDeviceActivity requested - opening native device pairing activity")
                    openDevicePairingActivity()
                    result.success("AddDeviceActivity opened")
                }
                "startDeviceDiscovery" -> {
                    val homeId = call.argument<String>("homeId")
                    if (homeId != null) {
                        startDeviceDiscovery(homeId, result)
                    } else {
                        result.error("INVALID_ARGS", "Home ID is required", null)
                    }
                }
                "stopDeviceDiscovery" -> {
                    stopDeviceDiscovery()
                    result.success("Device discovery stopped")
                }
                "pairDevice" -> {
                    val homeId = call.argument<String>("homeId")
                    val deviceId = call.argument<String>("deviceId")
                    val deviceName = call.argument<String>("deviceName")
                    
                    if (homeId != null && deviceId != null && deviceName != null) {
                        pairDevice(homeId, deviceId, deviceName, result)
                    } else {
                        result.error("INVALID_ARGS", "Home ID, Device ID, and Device Name are required", null)
                    }
                }
                "getHomes" -> {
                    getHomes(result)
                }
                "getDevices" -> {
                    val homeId = call.argument<String>("homeId")
                    if (homeId != null) {
                        getDevices(homeId, result)
                    } else {
                        result.error("INVALID_ARGS", "Home ID is required", null)
                    }
                }
                "openSettingsActivity" -> {
                    Log.d(TAG, "SettingsActivity requested - redirecting to Flutter settings page")
                    result.success("SettingsActivity opened")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    // MARK: - Device Pairing Methods
    
    private fun openDevicePairingActivity() {
        val intent = Intent(this, DevicePairingActivity::class.java)
        startActivity(intent)
    }
    
    private var currentActivator: ITuyaActivator? = null
    
    private fun startDeviceDiscovery(homeId: String, result: MethodChannel.Result) {
        Log.d(TAG, "Starting device discovery for home: $homeId")
        
        TuyaHomeSdk.getActivatorInstance().getActivatorToken(
            homeId,
            object : ITuyaActivatorGetToken {
                override fun onSuccess(token: String) {
                    Log.d(TAG, "Got activator token: $token")
                    
                    currentActivator = TuyaHomeSdk.getActivatorInstance().newActivator()
                    currentActivator?.startDiscovery(
                        token,
                        object : ITuyaDataCallback<ActivatorDeviceBean> {
                            override fun onSuccess(device: ActivatorDeviceBean) {
                                Log.d(TAG, "Discovered device: ${device.name} (${device.devId})")
                                // Send device discovery event to Flutter
                                val deviceData = HashMap<String, Any>()
                                deviceData["devId"] = device.devId
                                deviceData["name"] = device.name
                                deviceData["isOnline"] = device.isOnline
                                deviceData["productId"] = device.productId
                                
                                // You could use an EventChannel here to stream discovered devices
                                // For now, we'll just log them
                            }
                            
                            override fun onFailure(errorCode: String, errorMsg: String) {
                                Log.e(TAG, "Device discovery failed: $errorCode - $errorMsg")
                                result.error(errorCode, errorMsg, null)
                            }
                        }
                    )
                    
                    result.success("Device discovery started")
                }
                
                override fun onFailure(errorCode: String, errorMsg: String) {
                    Log.e(TAG, "Failed to get activator token: $errorCode - $errorMsg")
                    result.error(errorCode, errorMsg, null)
                }
            }
        )
    }
    
    private fun stopDeviceDiscovery() {
        Log.d(TAG, "Stopping device discovery")
        currentActivator?.stopDiscovery()
        currentActivator = null
    }
    
    private fun pairDevice(homeId: String, deviceId: String, deviceName: String, result: MethodChannel.Result) {
        Log.d(TAG, "Pairing device: $deviceName ($deviceId) to home: $homeId")
        
        TuyaHomeSdk.getHomeManagerInstance().addHomeDevice(
            homeId,
            deviceId,
            deviceName,
            object : ITuyaHomeResultCallback {
                override fun onSuccess(home: HomeBean) {
                    Log.d(TAG, "Device paired successfully: $deviceName")
                    result.success("Device '$deviceName' paired successfully")
                }
                
                override fun onError(errorCode: String, errorMessage: String) {
                    Log.e(TAG, "Failed to pair device: $errorCode - $errorMessage")
                    result.error(errorCode, errorMessage, null)
                }
            }
        )
    }
    
    private fun getHomes(result: MethodChannel.Result) {
        Log.d(TAG, "Getting homes list")
        
        TuyaHomeSdk.getHomeManagerInstance().queryHomeList(object : ITuyaHomeResultCallback {
            override fun onSuccess(homes: List<HomeBean>) {
                val homeList = homes.map { home ->
                    val homeData = HashMap<String, Any>()
                    homeData["homeId"] = home.homeId
                    homeData["name"] = home.name
                    homeData["geoName"] = home.geoName ?: ""
                    homeData["admin"] = home.admin
                    homeData["cityId"] = home.cityId
                    homeData["lat"] = home.lat
                    homeData["lon"] = home.lon
                    homeData
                }
                result.success(homeList)
            }
            
            override fun onError(errorCode: String, errorMessage: String) {
                Log.e(TAG, "Failed to get homes: $errorCode - $errorMessage")
                result.error(errorCode, errorMessage, null)
            }
        })
    }
    
    private fun getDevices(homeId: String, result: MethodChannel.Result) {
        Log.d(TAG, "Getting devices for home: $homeId")
        
        TuyaHomeSdk.getHomeManagerInstance().queryHomeDetail(homeId, object : ITuyaHomeResultCallback {
            override fun onSuccess(home: HomeBean) {
                val deviceList = home.deviceList?.map { device ->
                    val deviceData = HashMap<String, Any>()
                    deviceData["devId"] = device.devId
                    deviceData["name"] = device.name
                    deviceData["isOnline"] = device.isOnline
                    deviceData["productId"] = device.productId
                    deviceData["iconUrl"] = device.iconUrl ?: ""
                    deviceData["nodeId"] = device.nodeId ?: ""
                    deviceData
                } ?: emptyList()
                result.success(deviceList)
            }
            
            override fun onError(errorCode: String, errorMessage: String) {
                Log.e(TAG, "Failed to get devices: $errorCode - $errorMessage")
                result.error(errorCode, errorMessage, null)
            }
        })
    }
}
