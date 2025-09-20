package com.zerotechiot.eg

import android.app.Application
import com.thingclips.smart.android.user.api.ILoginCallback
import com.thingclips.smart.android.user.api.IResetPasswordCallback
import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.android.user.bean.User
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
                "initSDK" -> {
                    // SDK is already initialized in Application.onCreate()
                    result.success("Tuya SDK initialized successfully")
                }

                "isSDKInitialized" -> {
                    result.success(true)
                }

                "login" -> {
                    val email = call.argument<String>("email")
                    val password = call.argument<String>("password")
                    
                    if (email != null && password != null) {
                        loginUser(email, password, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Email and password are required", null)
                    }
                }

                "resetPassword" -> {
                    val email = call.argument<String>("email")
                    
                    if (email != null) {
                        resetPassword(email, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Email is required", null)
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
                        "avatarUrl" to null
                    )
                    result.success(userData)
                }

                override fun onError(code: String?, error: String?) {
                    result.error("LOGIN_FAILED", error ?: "Login failed", null)
                }
            }
        )
    }

    private fun resetPassword(email: String, result: MethodChannel.Result) {
        ThingHomeSdk.getUserInstance().sendVerifyCodeWithUserName(
            email,
            "US", // Country code
            "1", // Type: 1 for reset password
            object : IResetPasswordCallback {
                override fun onSuccess() {
                    result.success("Password reset email sent successfully")
                }

                override fun onError(code: String?, error: String?) {
                    result.error("RESET_PASSWORD_FAILED", error ?: "Failed to send reset password email", null)
                }
            }
        )
    }

    override fun onDestroy() {
        super.onDestroy()
        // Clean up SDK resources when app is destroyed
        ThingHomeSdk.onDestroy()
    }
}
class TuyaApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Initialize Tuya SDK - this must be done in Application.onCreate()
        ThingHomeSdk.init(this)
        // Enable debug mode for development (disable in production)
        ThingHomeSdk.setDebugMode(true)
    }
}