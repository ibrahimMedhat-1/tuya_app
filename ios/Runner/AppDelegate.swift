//
//  AppDelegate.swift
//  Runner
//
//  Flutter app with Tuya SDK integration
//  Fixed version with proper BizBundle UI navigation
//

import UIKit
import Flutter
import ThingSmartBaseKit
import ThingSmartBusinessExtensionKit
import ThingSmartBizCore
import ThingSmartFamilyBizKit
import ThingModuleServices

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var methodChannel: FlutterMethodChannel?
    private var flutterViewController: FlutterViewController?
    private let channelName = "com.zerotechiot.eg/tuya_sdk"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        NSLog("")
        NSLog("═══════════════════════════════════════════════════════════")
        NSLog("🚀 [iOS-NSLog] Application LAUNCHING...")
        NSLog("═══════════════════════════════════════════════════════════")
        NSLog("")
        
        // Initialize Tuya SDK FIRST (before Flutter)
        NSLog("📱 [iOS-NSLog] Step 1: Initializing Tuya SDK...")
        initializeTuyaSDK()
        NSLog("✅ [iOS-NSLog] Step 1: Tuya SDK initialized")
        
        // Call super to initialize Flutter
        NSLog("📱 [iOS-NSLog] Step 2: Initializing Flutter...")
        let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        NSLog("✅ [iOS-NSLog] Step 2: Flutter initialized")
        
        // Register Flutter plugins
        NSLog("📱 [iOS-NSLog] Step 3: Registering Flutter plugins...")
        GeneratedPluginRegistrant.register(with: self)
        NSLog("✅ [iOS-NSLog] Step 3: Flutter plugins registered")
        
        // CRITICAL FIX: Wrap FlutterViewController in UINavigationController
        // This is required for Tuya BizBundle to present its UI correctly
        NSLog("📱 [iOS-NSLog] Step 4: Setting up view hierarchy for BizBundle...")
        if let controller = window?.rootViewController as? FlutterViewController {
            self.flutterViewController = controller
            
            // Hide the navigation bar since we don't need it for Flutter
            let navController = UINavigationController(rootViewController: controller)
            navController.setNavigationBarHidden(true, animated: false)
            
            // Replace the root view controller with the navigation controller
            window?.rootViewController = navController
            
            NSLog("✅ [iOS-NSLog] Step 4: FlutterViewController wrapped in UINavigationController")
            NSLog("   FlutterVC: \(controller)")
            NSLog("   NavController: \(navController)")
        } else {
            NSLog("❌❌❌ [iOS-NSLog] Step 4: FAILED - Could not get FlutterViewController!")
            NSLog("   window: \(String(describing: window))")
            NSLog("   rootViewController: \(String(describing: window?.rootViewController))")
            NSLog("   rootViewController type: \(String(describing: type(of: window?.rootViewController)))")
        }
        
        // Set up Flutter MethodChannel
        NSLog("📱 [iOS-NSLog] Step 5: Setting up MethodChannel...")
        setupMethodChannel()
        NSLog("✅ [iOS-NSLog] Step 5: MethodChannel setup attempted")
        
        NSLog("")
        NSLog("═══════════════════════════════════════════════════════════")
        NSLog("✅ [iOS-NSLog] Application launched successfully!")
        NSLog("✅ [iOS-NSLog] BizBundle UI should now work correctly!")
        NSLog("═══════════════════════════════════════════════════════════")
        NSLog("")
        
        return result
    }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        NSLog("📱 [iOS-NSLog] applicationDidBecomeActive called")
        
        // Ensure MethodChannel and ViewController are properly set up
        if flutterViewController == nil {
            NSLog("⚠️ [iOS-NSLog] FlutterViewController was nil, attempting to get it now...")
            if let controller = window?.rootViewController as? FlutterViewController {
                self.flutterViewController = controller
                NSLog("✅ [iOS-NSLog] FlutterViewController stored in applicationDidBecomeActive")
            } else {
                NSLog("❌ [iOS-NSLog] Still cannot get FlutterViewController in applicationDidBecomeActive")
            }
        }
        
        if methodChannel == nil {
            NSLog("⚠️ [iOS-NSLog] MethodChannel was nil in applicationDidBecomeActive, setting up now...")
            setupMethodChannel()
        } else {
            NSLog("✅ [iOS-NSLog] MethodChannel already set up: \(channelName)")
        }
    }
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        // IMPORTANT: Camera video streaming lifecycle management
        // Per Tuya documentation: https://developer.tuya.com/en/docs/app-development/streaming?id=Kceuftys3the1
        // Video streaming must be stopped when app enters background to prevent crashes
        // related to hardware decoding and OpenGL rendering
        NSLog("📱 [iOS-NSLog] App entering background - camera streams managed by BizBundle")
        
        // Note: Camera lifecycle is handled automatically by ThingSmartCameraPanelBizBundle
        // The BizBundle stops video streams when views are dismissed or app backgrounds
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        // Camera streams will resume automatically when BizBundle UI is presented again
        NSLog("📱 [iOS-NSLog] App returning to foreground")
    }
    
    // MARK: - Tuya SDK Initialization
    
    private func initializeTuyaSDK() {
        NSLog("🔧 [iOS-NSLog] Initializing Tuya SDK...")
        NSLog("🔧 [iOS-NSLog] AppKey: \(AppKey.appKey)")
        
        // Start SDK with App Key and Secret
        ThingSmartSDK.sharedInstance().start(
            withAppKey: AppKey.appKey,
            secretKey: AppKey.secretKey
        )
        
        // Setup BizBundle configuration (REQUIRED for Device Pairing and Control UI)
        ThingSmartBusinessExtensionConfig.setupConfig()
        NSLog("✅ [iOS-NSLog] BizBundle config setup complete")
        
        // Enable debug mode for development
        #if DEBUG
        ThingSmartSDK.sharedInstance().debugMode = true
        NSLog("✅ [iOS-NSLog] Debug mode enabled")
        #endif
        
        // Register protocol implementations for BizBundle
        registerBizBundleProtocols()
        
        NSLog("✅ [iOS-NSLog] Tuya SDK initialized successfully")
    }
    
    private func registerBizBundleProtocols() {
        NSLog("🔧 [iOS-NSLog] Registering BizBundle protocols...")
        
        // Register ThingSmartHomeDataProtocol for home context
        ThingSmartBizCore.sharedInstance().registerService(
            ThingSmartHomeDataProtocol.self,
            withInstance: TuyaProtocolHandler.shared
        )
        
        // Register Scene BizBundle protocols (required for Scene UI)
        // https://developer.tuya.com/en/docs/app-development/scene?id=Ka8qf8lmlptsr
        // TuyaProtocolHandler now implements all protocols including Scene protocols
        ThingSmartBizCore.sharedInstance().registerService(
            ThingFamilyProtocol.self,
            withInstance: TuyaProtocolHandler.shared
        )
        
        ThingSmartBizCore.sharedInstance().registerService(
            ThingSmartHouseIndexProtocol.self,
            withInstance: TuyaProtocolHandler.shared
        )
        
        NSLog("✅ [iOS-NSLog] BizBundle protocols registered (Home + Scene)")
    }
    
    // MARK: - Flutter MethodChannel Setup
    
    private func setupMethodChannel() {
        NSLog("")
        NSLog("═══════════════════════════════════════════════════════════")
        NSLog("🔍 [iOS-NSLog] setupMethodChannel() called")
        NSLog("═══════════════════════════════════════════════════════════")
        
        guard let flutterVC = flutterViewController ?? window?.rootViewController as? FlutterViewController else {
            NSLog("❌❌❌ [iOS-NSLog] CRITICAL ERROR: Failed to get FlutterViewController!")
            NSLog("   flutterViewController property: \(String(describing: flutterViewController))")
            NSLog("   window: \(String(describing: window))")
            NSLog("   window.rootViewController: \(String(describing: window?.rootViewController))")
            NSLog("═══════════════════════════════════════════════════════════")
            NSLog("")
            return
        }
        
        NSLog("✅ [iOS-NSLog] Got FlutterViewController: \(flutterVC)")
        
        // Store the reference if we got it from window
        if self.flutterViewController == nil {
            self.flutterViewController = flutterVC
            NSLog("✅ [iOS-NSLog] Stored FlutterViewController from window")
        }
        
        NSLog("📱 [iOS-NSLog] Creating FlutterMethodChannel with name: '\(channelName)'")
        
        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: flutterVC.binaryMessenger
        )
        self.methodChannel = channel
        
        NSLog("✅ [iOS-NSLog] FlutterMethodChannel created successfully")
        NSLog("   Channel: \(channel)")
        
        // Set method call handler
        NSLog("📱 [iOS-NSLog] Registering setMethodCallHandler...")
        channel.setMethodCallHandler { [weak self] call, result in
            NSLog("")
            NSLog("═══════════════════════════════════════════════════════════")
            NSLog("🎯🎯🎯 [iOS-NSLog] MethodChannel RECEIVED CALL FROM FLUTTER!")
            NSLog("   Method: '\(call.method)'")
            NSLog("   Arguments: \(String(describing: call.arguments))")
            NSLog("═══════════════════════════════════════════════════════════")
            NSLog("")
            
            guard let self = self else {
                NSLog("❌ [iOS-NSLog] self is nil in handler")
                result(FlutterError(code: "NO_SELF", message: "AppDelegate self is nil", details: nil))
                return
            }
            
            NSLog("📱 [iOS-NSLog] Forwarding call to TuyaBridge...")
            
            // Delegate all calls to TuyaBridge with proper FlutterViewController
            TuyaBridge.shared.handleMethodCall(
                call,
                result: result,
                controller: self.flutterViewController
            )
        }
        
        NSLog("✅ [iOS-NSLog] setMethodCallHandler registered successfully!")
        NSLog("═══════════════════════════════════════════════════════════")
        NSLog("🎉 [iOS-NSLog] MethodChannel setup COMPLETE!")
        NSLog("   Flutter can now communicate with iOS using channel: '\(channelName)'")
        NSLog("═══════════════════════════════════════════════════════════")
        NSLog("")
    }
}
