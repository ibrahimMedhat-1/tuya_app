//
//  TuyaBridge.swift
//  Runner
//
//  MethodChannel bridge between Flutter and Tuya iOS SDK
//  Rewritten from scratch with proper BizBundle UI navigation
//

import Foundation
import Flutter
import ThingSmartDeviceKit
import ThingSmartBizCore
import ThingModuleServices
import ThingSmartFamilyBizKit
import UIKit

class TuyaBridge: NSObject {
    static let shared = TuyaBridge()
    
    private override init() {
        super.init()
        NSLog("✅ [iOS-NSLog] TuyaBridge initialized")
    }
    
    // MARK: - MethodChannel Handler
    
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult, controller: UIViewController?) {
        NSLog("🔧 [iOS-NSLog] TuyaBridge.handleMethodCall: \(call.method)")
        
        switch call.method {
        case "test_ios_connection":
            NSLog("🧪 [iOS-NSLog] Test connection method called!")
            result(["status": "iOS is responding!", "timestamp": Date().timeIntervalSince1970])
            
        case "login":
            login(call, result: result)
            
        case "logout":
            logout(result: result)
            
        case "isLoggedIn":
            isLoggedIn(result: result)
            
        case "getHomes":
            getHomes(result: result)
            
        case "getHomeDevices":
            getHomeDevices(call, result: result)
            
        case "pairDevices":
            NSLog("📱 [iOS-NSLog] pairDevices called")
            pairDevices(result: result, controller: controller)
            
        case "openDeviceControlPanel":
            NSLog("🎮 [iOS-NSLog] openDeviceControlPanel called")
            openDeviceControlPanel(call, result: result, controller: controller)
            
        case "openScenes":
            NSLog("🎬 [iOS-NSLog] openScenes called")
            openScenes(call, result: result, controller: controller)
            
        default:
            NSLog("❌ [iOS-NSLog] Method not implemented: \(call.method)")
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - User Authentication
    
    private func login(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let email = args["email"] as? String,
              let password = args["password"] as? String else {
            NSLog("❌ [iOS-NSLog] Missing email/password for login")
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Email and password are required", details: nil))
            return
        }
        
        NSLog("🔐 [iOS-NSLog] Attempting login with email: \(email)")
        
        ThingSmartUser.sharedInstance().login(
            byEmail: "US",
            email: email,
            password: password
        ) {
            let user = ThingSmartUser.sharedInstance()
            NSLog("✅ [iOS-NSLog] User logged in successfully")
            
            let userData: [String: Any] = [
                "id": user.uid ?? "",
                "email": email,
                "name": user.email ?? email.components(separatedBy: "@").first ?? ""
            ]
            result(userData)
            
        } failure: { error in
            NSLog("❌ [iOS-NSLog] Login failed: \(error?.localizedDescription ?? "Unknown error")")
            result(FlutterError(
                code: "LOGIN_FAILED",
                message: error?.localizedDescription ?? "Login failed",
                details: nil
            ))
        }
    }
    
    private func logout(result: @escaping FlutterResult) {
        NSLog("🔐 [iOS-NSLog] Logging out user")
        
        ThingSmartUser.sharedInstance().loginOut {
            NSLog("✅ [iOS-NSLog] User logged out successfully")
            
            // Clear stored home ID
            UserDefaults.standard.removeObject(forKey: "currentHomeId")
            UserDefaults.standard.synchronize()
            
            result(nil)
            
        } failure: { error in
            NSLog("❌ [iOS-NSLog] Logout failed: \(error?.localizedDescription ?? "Unknown error")")
            result(FlutterError(
                code: "LOGOUT_FAILED",
                message: error?.localizedDescription ?? "Logout failed",
                details: nil
            ))
        }
    }
    
    private func isLoggedIn(result: @escaping FlutterResult) {
        NSLog("🔐 [iOS-NSLog] Checking login status")
        
        if ThingSmartUser.sharedInstance().isLogin {
            let user = ThingSmartUser.sharedInstance()
            NSLog("✅ [iOS-NSLog] User is logged in: \(user.uid ?? "N/A")")
            
            let userData: [String: Any] = [
                "id": user.uid ?? "",
                "email": user.email ?? "",
                "name": user.email ?? user.uid ?? ""
            ]
            result(userData)
        } else {
            NSLog("ℹ️ [iOS-NSLog] User is not logged in")
            result(nil)
        }
    }
    
    // MARK: - Home Management
    
    private func getHomes(result: @escaping FlutterResult) {
        NSLog("🏠 [iOS-NSLog] Getting homes list")
        
        guard ThingSmartUser.sharedInstance().isLogin else {
            NSLog("❌ [iOS-NSLog] User not logged in for getHomes")
            result(FlutterError(code: "NOT_LOGGED_IN", message: "User must be logged in", details: nil))
            return
        }
        
        ThingSmartHomeManager().getHomeList { homeList in
            guard let homes = homeList else {
                NSLog("ℹ️ [iOS-NSLog] No homes found")
                result([])
                return
            }
            
            let homesData = homes.map { home -> [String: Any] in
                return [
                    "homeId": home.homeId,
                    "name": home.name ?? ""
                ]
            }
            
            NSLog("✅ [iOS-NSLog] Found \(homesData.count) homes")
            result(homesData)
            
        } failure: { error in
            NSLog("❌ [iOS-NSLog] Failed to get homes: \(error?.localizedDescription ?? "Unknown error")")
            result(FlutterError(
                code: "GET_HOMES_FAILED",
                message: error?.localizedDescription ?? "Failed to get homes",
                details: nil
            ))
        }
    }
    
    private func getHomeDevices(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            NSLog("❌ [iOS-NSLog] Missing arguments for getHomeDevices")
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "homeId is required", details: nil))
            return
        }
        
        let homeId: Int64
        if let id = args["homeId"] as? Int {
            homeId = Int64(id)
        } else if let id = args["homeId"] as? Int64 {
            homeId = id
        } else {
            NSLog("❌ [iOS-NSLog] Invalid homeId type for getHomeDevices")
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "homeId is required", details: nil))
            return
        }
        
        NSLog("📱 [iOS-NSLog] Getting devices for home: \(homeId)")
        
        guard ThingSmartUser.sharedInstance().isLogin else {
            NSLog("❌ [iOS-NSLog] User not logged in for getHomeDevices")
            result(FlutterError(code: "NOT_LOGGED_IN", message: "User must be logged in", details: nil))
            return
        }
        
        guard let home = ThingSmartHome(homeId: homeId) else {
            NSLog("❌ [iOS-NSLog] Home not found for ID: \(homeId)")
            result(FlutterError(code: "HOME_NOT_FOUND", message: "Home not found", details: nil))
            return
        }
        
        // Store current home ID for BizBundle protocols
        TuyaProtocolHandler.shared.setCurrentHomeId(homeId)
        
        // Set current family in ThingSmartFamilyBiz (REQUIRED for BizBundle navigation)
        ThingSmartFamilyBiz.sharedInstance().setCurrentFamilyId(homeId)
        NSLog("✅ [iOS-NSLog] Current family set to: \(homeId)")
        
        guard let deviceList = home.deviceList, !deviceList.isEmpty else {
            NSLog("ℹ️ [iOS-NSLog] No devices found for home \(homeId)")
            result([])
            return
        }
        
        let devicesData = deviceList.map { (device: ThingSmartDeviceModel) -> [String: Any] in
            return [
                "deviceId": device.devId ?? "",
                "name": device.name ?? "no name",
                "isOnline": device.isOnline,
                "image": device.iconUrl ?? ""
            ]
        }
        
        NSLog("✅ [iOS-NSLog] Found \(devicesData.count) devices for home \(homeId)")
        result(devicesData)
    }
    
    // MARK: - Device Pairing (BizBundle UI)
    
    private func pairDevices(result: @escaping FlutterResult, controller: UIViewController?) {
        NSLog("🔧 [iOS-NSLog] Starting device pairing flow")
        
        guard ThingSmartUser.sharedInstance().isLogin else {
            NSLog("❌ [iOS-NSLog] User not logged in for device pairing")
            result(FlutterError(
                code: "USER_NOT_LOGGED_IN",
                message: "User must be logged in to pair devices",
                details: nil
            ))
            return
        }
        
        // Ensure we have a current home set
        ensureCurrentHomeIsSet { homeId in
            guard homeId != nil else {
                NSLog("❌ [iOS-NSLog] No home available for device pairing")
                result(FlutterError(
                    code: "NO_HOME",
                    message: "No home available. Please create a home first.",
                    details: nil
                ))
                return
            }
            
            NSLog("✅ [iOS-NSLog] Current home confirmed: \(homeId!)")
            
            // Must run on main thread for UI operations
            DispatchQueue.main.async {
                guard let flutterVC = controller else {
                    NSLog("❌ [iOS-NSLog] No view controller available for device pairing")
                    result(FlutterError(
                        code: "NO_CONTROLLER",
                        message: "View controller not available",
                        details: nil
                    ))
                    return
                }
                
                // Get the ThingActivatorProtocol service from BizBundle
                guard let activatorService = ThingSmartBizCore.sharedInstance()
                    .service(of: ThingActivatorProtocol.self) as? ThingActivatorProtocol else {
                    NSLog("❌ [iOS-NSLog] ThingActivatorProtocol service not available")
                    result(FlutterError(
                        code: "SERVICE_NOT_AVAILABLE",
                        message: "Device pairing service not available. Make sure BizBundle is properly installed.",
                        details: nil
                    ))
                    return
                }
                
                NSLog("✅ [iOS-NSLog] ThingActivatorProtocol service found")
                
                // Launch the device category selection screen
                // This is the main entry point for device pairing in Tuya BizBundle
                activatorService.gotoCategoryViewController()
                
                NSLog("✅ [iOS-NSLog] Device pairing UI launched successfully")
                
                // Return success immediately (the UI is presented modally)
                result("Device pairing UI started")
            }
        }
    }
    
    // MARK: - Device Control (BizBundle UI)
    
    private func openDeviceControlPanel(_ call: FlutterMethodCall, result: @escaping FlutterResult, controller: UIViewController?) {
        guard let args = call.arguments as? [String: Any],
              let deviceId = args["deviceId"] as? String else {
            NSLog("❌ [iOS-NSLog] Missing deviceId for openDeviceControlPanel")
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "deviceId is required", details: nil))
            return
        }
        
        // Extract homeId and homeName (optional parameters)
        let homeId: Int64?
        if let id = args["homeId"] as? Int {
            homeId = Int64(id)
        } else if let id = args["homeId"] as? Int64 {
            homeId = id
        } else {
            homeId = nil
        }
        let homeName = args["homeName"] as? String
        
        NSLog("🎮 [iOS-NSLog] Opening device control panel for device: \(deviceId)")
        if let homeId = homeId {
            NSLog("   Home ID: \(homeId), Home Name: \(homeName ?? "N/A")")
        }
        
        guard ThingSmartUser.sharedInstance().isLogin else {
            NSLog("❌ [iOS-NSLog] User not logged in for device control")
            result(FlutterError(
                code: "NOT_LOGGED_IN",
                message: "User must be logged in to control devices",
                details: nil
            ))
            return
        }
        
        guard let device = ThingSmartDevice(deviceId: deviceId) else {
            NSLog("❌ [iOS-NSLog] Device not found for ID: \(deviceId)")
            result(FlutterError(code: "DEVICE_NOT_FOUND", message: "Device not found", details: nil))
            return
        }
        
        NSLog("✅ [iOS-NSLog] Device found: \(device.deviceModel.name ?? "Unknown")")
        
        // If homeId is provided, update current home
        if let homeId = homeId {
            TuyaProtocolHandler.shared.setCurrentHomeId(homeId)
            ThingSmartFamilyBiz.sharedInstance().setCurrentFamilyId(homeId)
            NSLog("✅ [iOS-NSLog] Current family set to: \(homeId)")
        }
        
        // Must run on main thread for UI operations
        DispatchQueue.main.async {
            guard let flutterVC = controller else {
                NSLog("❌ [iOS-NSLog] No view controller available for device control")
                result(FlutterError(
                    code: "NO_CONTROLLER",
                    message: "View controller not available",
                    details: nil
                ))
                return
            }
            
            // Get the ThingPanelProtocol service from BizBundle
            guard let panelService = ThingSmartBizCore.sharedInstance()
                .service(of: ThingPanelProtocol.self) as? ThingPanelProtocol else {
                NSLog("❌ [iOS-NSLog] ThingPanelProtocol service not available")
                result(FlutterError(
                    code: "SERVICE_NOT_AVAILABLE",
                    message: "Device control panel service not available. Make sure BizBundle is properly installed.",
                    details: nil
                ))
                return
            }
            
            NSLog("✅ [iOS-NSLog] ThingPanelProtocol service found, opening panel")
            
            // With UINavigationController wrapping FlutterViewController,
            // BizBundle can now properly present its UI
            panelService.gotoPanelViewController(
                withDevice: device.deviceModel,
                group: nil,
                initialProps: nil,
                contextProps: nil
            ) { (error: Error?) in
                DispatchQueue.main.async {
                    if let error = error {
                        NSLog("❌ [iOS-NSLog] Failed to open device panel: \(error.localizedDescription)")
                    } else {
                        NSLog("✅ [iOS-NSLog] Device control panel opened successfully!")
                    }
                }
            }
            
            NSLog("✅ [iOS-NSLog] Device control panel launched")
            
            // Return success immediately
            result(nil)
        }
    }
    
    // MARK: - Scene Management (BizBundle UI)
    
    private func openScenes(_ call: FlutterMethodCall, result: @escaping FlutterResult, controller: UIViewController?) {
        guard let args = call.arguments as? [String: Any] else {
            NSLog("❌ [iOS-NSLog] Missing arguments for openScenes")
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "homeId is required", details: nil))
            return
        }
        
        // Extract homeId and homeName
        let homeId: Int64
        if let id = args["homeId"] as? Int {
            homeId = Int64(id)
        } else if let id = args["homeId"] as? Int64 {
            homeId = id
        } else {
            NSLog("❌ [iOS-NSLog] Invalid homeId type for openScenes")
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "homeId is required", details: nil))
            return
        }
        
        let homeName = args["homeName"] as? String ?? ""
        
        NSLog("🎬 [iOS-NSLog] Opening Scene UI for home: \(homeId) (\(homeName))")
        
        guard ThingSmartUser.sharedInstance().isLogin else {
            NSLog("❌ [iOS-NSLog] User not logged in for scene management")
            result(FlutterError(
                code: "NOT_LOGGED_IN",
                message: "User must be logged in to manage scenes",
                details: nil
            ))
            return
        }
        
        // Set current family ID for Scene BizBundle context
        TuyaProtocolHandler.shared.setCurrentHomeId(homeId)
        ThingSmartFamilyBiz.sharedInstance().setCurrentFamilyId(homeId)
        NSLog("✅ [iOS-NSLog] Current family set to: \(homeId)")
        
        // Must run on main thread for UI operations
        DispatchQueue.main.async {
            guard let flutterVC = controller else {
                NSLog("❌ [iOS-NSLog] No view controller available for scene management")
                result(FlutterError(
                    code: "NO_CONTROLLER",
                    message: "View controller not available",
                    details: nil
                ))
                return
            }
            
            // Get the Scene protocol service from BizBundle
            guard let sceneService = ThingSmartBizCore.sharedInstance()
                .service(of: ThingSmartSceneProtocol.self) as? ThingSmartSceneProtocol else {
                NSLog("❌ [iOS-NSLog] ThingSmartSceneProtocol service not available")
                result(FlutterError(
                    code: "SERVICE_NOT_AVAILABLE",
                    message: "Scene service not available. Make sure Scene BizBundle is properly installed.",
                    details: nil
                ))
                return
            }
            
            NSLog("✅ [iOS-NSLog] ThingSmartSceneProtocol service found, opening scene list")
            
            // Open scene list/management UI
            // The Scene BizBundle provides gotoSceneViewController for opening scene management
            sceneService.gotoSceneViewController()
            
            NSLog("✅ [iOS-NSLog] Scene UI launched successfully")
            
            // Return success immediately
            result(nil)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Ensures that a current home is set in the system
    /// This is required for BizBundle navigation to work properly
    private func ensureCurrentHomeIsSet(completion: @escaping (Int64?) -> Void) {
        // Check if we already have a stored home ID
        if let storedHomeId = UserDefaults.standard.object(forKey: "currentHomeId") as? Int64, storedHomeId > 0 {
            NSLog("✅ [iOS-NSLog] Using stored home ID: \(storedHomeId)")
            ThingSmartFamilyBiz.sharedInstance().setCurrentFamilyId(storedHomeId)
            completion(storedHomeId)
            return
        }
        
        // If not, get the first home from the list
        NSLog("🔍 [iOS-NSLog] No stored home ID, fetching first available home")
        ThingSmartHomeManager().getHomeList { homeList in
            guard let homes = homeList, let firstHome = homes.first else {
                NSLog("❌ [iOS-NSLog] No homes found in ensureCurrentHomeIsSet")
                completion(nil)
                return
            }
            
            let homeId = firstHome.homeId
            NSLog("✅ [iOS-NSLog] Using first available home: \(homeId)")
            
            // Store and set current home
            UserDefaults.standard.set(homeId, forKey: "currentHomeId")
            UserDefaults.standard.synchronize()
            TuyaProtocolHandler.shared.setCurrentHomeId(homeId)
            ThingSmartFamilyBiz.sharedInstance().setCurrentFamilyId(homeId)
            
            completion(homeId)
            
        } failure: { error in
            NSLog("❌ [iOS-NSLog] Failed to get homes in ensureCurrentHomeIsSet: \(error?.localizedDescription ?? "Unknown")")
            completion(nil)
        }
    }
}
