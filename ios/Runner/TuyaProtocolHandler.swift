//
//  TuyaProtocolHandler.swift
//  Runner
//
//  Protocol implementations for Tuya BizBundle
//  Provides current home information to BizBundle components
//

import Foundation
import ThingSmartDeviceKit
import ThingModuleServices

/// Protocol handler for ThingSmartHomeDataProtocol, ThingFamilyProtocol, and ThingSmartHouseIndexProtocol
/// This is REQUIRED for BizBundle UI components (Device Panel, Scene, etc.) to function properly
/// They query these protocols to get the current home context and permissions
class TuyaProtocolHandler: NSObject, ThingSmartHomeDataProtocol, ThingFamilyProtocol, ThingSmartHouseIndexProtocol {
    static let shared = TuyaProtocolHandler()
    
    private override init() {
        super.init()
        NSLog("✅ [iOS-NSLog] TuyaProtocolHandler initialized")
    }
    
    // MARK: - ThingSmartHomeDataProtocol
    
    /// Returns the current home for BizBundle context
    /// This is called by BizBundle UI components to determine which home to operate in
    func getCurrentHome() -> ThingSmartHome! {
        NSLog("🏠 [iOS-NSLog] TuyaProtocolHandler.getCurrentHome() called")
        
        guard let homeId = getCurrentHomeId() else {
            NSLog("❌ [iOS-NSLog] No current home ID available")
            return nil
        }
        
        guard let home = ThingSmartHome(homeId: homeId) else {
            NSLog("❌ [iOS-NSLog] Could not create ThingSmartHome for ID: \(homeId)")
            return nil
        }
        
        NSLog("✅ [iOS-NSLog] Returning current home: \(home.homeModel.name ?? "Unknown") (ID: \(homeId))")
        return home
    }
    
    // MARK: - Current Home Management
    
    /// Returns the current home ID
    /// First tries UserDefaults, then falls back to the first available home
    private func getCurrentHomeId() -> Int64? {
        // Try stored home ID first
        if let storedHomeId = UserDefaults.standard.object(forKey: "currentHomeId") as? Int64, storedHomeId > 0 {
            NSLog("✅ [iOS-NSLog] Using stored home ID: \(storedHomeId)")
            return storedHomeId
        }
        
        NSLog("🔍 [iOS-NSLog] No stored home ID, fetching first available home")
        
        // If no stored ID, try to get the first home from the list
        // This is a synchronous call, so we use a semaphore
        var firstHomeId: Int64?
        let semaphore = DispatchSemaphore(value: 0)
        
        ThingSmartHomeManager().getHomeList { homeList in
            if let homes = homeList, let firstHome = homes.first {
                firstHomeId = firstHome.homeId
                // Store for future use
                UserDefaults.standard.set(firstHomeId, forKey: "currentHomeId")
                UserDefaults.standard.synchronize()
                NSLog("✅ [iOS-NSLog] Using first available home ID: \(firstHomeId!)")
            } else {
                NSLog("❌ [iOS-NSLog] No homes found in getCurrentHomeId")
            }
            semaphore.signal()
        } failure: { error in
            NSLog("❌ [iOS-NSLog] Failed to get home list: \(error?.localizedDescription ?? "Unknown error")")
            semaphore.signal()
        }
        
        // Wait for async call to complete (with timeout)
        _ = semaphore.wait(timeout: .now() + 5.0)
        return firstHomeId
    }
    
    /// Sets the current home ID
    /// This should be called whenever the user switches homes or loads devices
    func setCurrentHomeId(_ homeId: Int64) {
        UserDefaults.standard.set(homeId, forKey: "currentHomeId")
        UserDefaults.standard.synchronize()
        NSLog("✅ [iOS-NSLog] Current home ID set to: \(homeId)")
    }
    
    /// Clears the current home ID
    /// This should be called on logout
    func clearCurrentHomeId() {
        UserDefaults.standard.removeObject(forKey: "currentHomeId")
        UserDefaults.standard.synchronize()
        NSLog("✅ [iOS-NSLog] Current home ID cleared")
    }
    
    // MARK: - ThingFamilyProtocol (Required for Scene BizBundle)
    
    /// Returns the current home ID required by Scene BizBundle
    /// https://developer.tuya.com/en/docs/app-development/scene?id=Ka8qf8lmlptsr
    func currentFamilyId() -> Int64 {
        if let storedHomeId = getCurrentHomeId() {
            NSLog("✅ [iOS-NSLog] Scene: currentFamilyId = \(storedHomeId)")
            return storedHomeId
        }
        NSLog("⚠️ [iOS-NSLog] Scene: No current home ID found, returning 0")
        return 0
    }
    
    /// Checks if the user has required permissions to edit scenes
    /// Returns YES to allow all logged-in users to edit scenes
    func checkAdminAndRightLimit(_ alert: Bool) -> Bool {
        NSLog("✅ [iOS-NSLog] Scene: checkAdminAndRightLimit called, returning true")
        return true
    }
    
    /// Alternative method for checking admin rights with homeId
    func checkAdminAndRightLimit(_ alert: Bool, withHomeId homeId: Int64) -> Bool {
        NSLog("✅ [iOS-NSLog] Scene: checkAdminAndRightLimit with homeId \(homeId), returning true")
        return true
    }
    
    // MARK: - ThingSmartHouseIndexProtocol (Required for Scene BizBundle)
    
    /// Indicates whether the user is the administrator of the current home
    /// Returns YES to allow all users to edit scenes
    func homeAdminValidation() -> Bool {
        NSLog("✅ [iOS-NSLog] Scene: homeAdminValidation called, returning true")
        return true
    }
}
