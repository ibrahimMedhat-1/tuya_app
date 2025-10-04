import Flutter
import UIKit
import ThingSmartHomeKit

/// AppDelegate with Tuya SDK v6.2.0 integration
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "tuya_flutter_sdk", binaryMessenger: controller.binaryMessenger)
    
    channel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "initTuyaSDK":
        guard let args = call.arguments as? [String: Any],
              let appKey = args["appKey"] as? String,
              let appSecret = args["appSecret"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing appKey or appSecret", details: nil))
          return
        }
        
        let bundleId = (args["packageName"] as? String) ?? "com.zerotechiot.eg"
        print("Initializing Tuya SDK with appKey: \(appKey), bundleId: \(bundleId)")
        
        // Initialize Tuya SDK v6.2.0 (latest stable version)
        ThingSmartSDK.sharedInstance().start(withAppKey: appKey, secretKey: appSecret)
        // Enable debug mode during development
        ThingSmartSDK.sharedInstance().debugMode = true
        
        // Set up login callback
        ThingSmartSDK.sharedInstance().setNeedLoginListener {
            print("User needs to login")
        }
        
        result(true)
        
      case "registerWithEmail":
        guard let args = call.arguments as? [String: Any],
              let email = args["email"] as? String,
              let password = args["password"] as? String,
              let countryCode = args["countryCode"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing email, password, or countryCode", details: nil))
          return
        }
        
        // Register with email using Tuya SDK v6.2.0
        // For simplicity, we use the password as verification code
        ThingSmartUser.sharedInstance().registerByEmail(countryCode, email: email, password: password, code: password, success: { user in
          let userData: [String: Any] = [
            "id": user.uid ?? "",
            "email": email,
            "username": user.userName ?? email
          ]
          result(userData)
        }, failure: { error in
          result(FlutterError(code: "REGISTER_ERROR", message: error?.localizedDescription ?? "Registration failed", details: nil))
        })
        
      case "loginWithEmail":
        guard let args = call.arguments as? [String: Any],
              let email = args["email"] as? String,
              let password = args["password"] as? String,
              let countryCode = args["countryCode"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing email, password, or countryCode", details: nil))
          return
        }
        
        // Login with email using Tuya SDK v6.2.0
        ThingSmartUser.sharedInstance().login(byEmail: countryCode, email: email, password: password, success: { user in
          let userData: [String: Any] = [
            "id": user.uid ?? "",
            "email": email,
            "username": user.userName ?? email
          ]
          result(userData)
        }, failure: { error in
          result(FlutterError(code: "LOGIN_ERROR", message: error?.localizedDescription ?? "Login failed", details: nil))
        })
        
      case "logout":
        // Logout using Tuya SDK v6.2.0
        ThingSmartUser.sharedInstance().logout(success: {
          result(nil)
        }, failure: { error in
          result(FlutterError(code: "LOGOUT_ERROR", message: error?.localizedDescription ?? "Logout failed", details: nil))
        })
        
      case "isLoggedIn":
        // Check login status using Tuya SDK v6.2.0
        let isLoggedIn = ThingSmartUser.sharedInstance().isLogin
        result(isLoggedIn)
        
      case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)
        
      case "openHomeActivity":
        self.openHomeActivity()
        result(nil)
        
      case "openDeviceControlActivity":
        guard let args = call.arguments as? [String: Any],
              let deviceId = args["deviceId"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing deviceId", details: nil))
          return
        }
        self.openDeviceControlActivity(deviceId: deviceId)
        result(nil)
        
      case "openAddDeviceActivity":
        self.openAddDeviceActivity()
        result(nil)
        
      case "openSettingsActivity":
        self.openSettingsActivity()
        result(nil)
        
      case "startDeviceDiscovery":
        guard let args = call.arguments as? [String: Any],
              let homeId = args["homeId"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing homeId", details: nil))
          return
        }
        self.startDeviceDiscovery(homeId: homeId, result: result)
        
      case "stopDeviceDiscovery":
        self.stopDeviceDiscovery()
        result(nil)
        
      case "pairDevice":
        guard let args = call.arguments as? [String: Any],
              let homeId = args["homeId"] as? String,
              let deviceId = args["deviceId"] as? String,
              let deviceName = args["deviceName"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing homeId, deviceId, or deviceName", details: nil))
          return
        }
        self.pairDevice(homeId: homeId, deviceId: deviceId, deviceName: deviceName, result: result)
        
      case "getHomes":
        self.getHomes(result: result)
        
      case "getDevices":
        guard let args = call.arguments as? [String: Any],
              let homeId = args["homeId"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing homeId", details: nil))
          return
        }
        self.getDevices(homeId: homeId, result: result)
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - Activity Methods
  
  private func openHomeActivity() {
    DispatchQueue.main.async {
      let homeVC = HomeViewController()
      let navController = UINavigationController(rootViewController: homeVC)
      navController.modalPresentationStyle = .fullScreen
      self.window?.rootViewController?.present(navController, animated: true)
    }
  }
  
  private func openDeviceControlActivity(deviceId: String) {
    DispatchQueue.main.async {
      // Find device by ID
      ThingSmartHomeManager.sharedInstance().getHomeList { homes in
        DispatchQueue.main.async {
          for home in homes ?? [] {
            home.getDeviceList { devices in
              DispatchQueue.main.async {
                if let device = devices?.first(where: { $0.devId == deviceId }) {
                  let deviceControlVC = DeviceControlViewController(device: device)
                  let navController = UINavigationController(rootViewController: deviceControlVC)
                  navController.modalPresentationStyle = .fullScreen
                  self.window?.rootViewController?.present(navController, animated: true)
                } else {
                  print("Device with ID \(deviceId) not found")
                }
              }
            } failure: { error in
              print("Error loading devices: \(error?.localizedDescription ?? "Unknown error")")
            }
          }
        }
      } failure: { error in
        print("Error loading homes: \(error?.localizedDescription ?? "Unknown error")")
      }
    }
  }
  
  private func openAddDeviceActivity() {
    DispatchQueue.main.async {
      let addDeviceVC = AddDeviceViewController()
      let navController = UINavigationController(rootViewController: addDeviceVC)
      navController.modalPresentationStyle = .fullScreen
      self.window?.rootViewController?.present(navController, animated: true)
    }
  }
  
  private func openSettingsActivity() {
    DispatchQueue.main.async {
      let settingsVC = SettingsViewController()
      let navController = UINavigationController(rootViewController: settingsVC)
      navController.modalPresentationStyle = .fullScreen
      self.window?.rootViewController?.present(navController, animated: true)
    }
  }
  
  // MARK: - Device Pairing Methods
  
  private var currentActivator: ThingSmartActivator?
  
  private func startDeviceDiscovery(homeId: String, result: @escaping FlutterResult) {
    print("Starting device discovery for home: \(homeId)")
    
    // Get activator token
    ThingSmartActivator.sharedInstance().getToken(withHomeId: homeId, success: { [weak self] token in
      print("Got activator token: \(token)")
      
      // Start device discovery
      self?.currentActivator = ThingSmartActivator.sharedInstance()
      self?.currentActivator?.startConfigWiFi(withToken: token, success: { deviceList in
        DispatchQueue.main.async {
          print("Discovered \(deviceList?.count ?? 0) devices")
          result("Device discovery started. Found \(deviceList?.count ?? 0) devices.")
        }
      }, failure: { error in
        DispatchQueue.main.async {
          print("Device discovery failed: \(error?.localizedDescription ?? "Unknown error")")
          result(FlutterError(code: "DISCOVERY_ERROR", message: error?.localizedDescription ?? "Unknown error", details: nil))
        }
      })
      
    }, failure: { error in
      DispatchQueue.main.async {
        print("Failed to get activator token: \(error?.localizedDescription ?? "Unknown error")")
        result(FlutterError(code: "TOKEN_ERROR", message: error?.localizedDescription ?? "Unknown error", details: nil))
      }
    })
  }
  
  private func stopDeviceDiscovery() {
    print("Stopping device discovery")
    currentActivator?.stopConfigWiFi()
    currentActivator = nil
  }
  
  private func pairDevice(homeId: String, deviceId: String, deviceName: String, result: @escaping FlutterResult) {
    print("Pairing device: \(deviceName) (\(deviceId)) to home: \(homeId)")
    
    // Find the home
    ThingSmartHomeManager.sharedInstance().getHomeList { homes in
      guard let home = homes?.first(where: { $0.homeId == homeId }) else {
        DispatchQueue.main.async {
          result(FlutterError(code: "HOME_NOT_FOUND", message: "Home not found", details: nil))
        }
        return
      }
      
      // Add device to home
      home.addHomeDevice(deviceId, name: deviceName, success: {
        DispatchQueue.main.async {
          print("Device paired successfully: \(deviceName)")
          result("Device '\(deviceName)' paired successfully")
        }
      }, failure: { error in
        DispatchQueue.main.async {
          print("Failed to pair device: \(error?.localizedDescription ?? "Unknown error")")
          result(FlutterError(code: "PAIRING_ERROR", message: error?.localizedDescription ?? "Unknown error", details: nil))
        }
      })
      
    } failure: { error in
      DispatchQueue.main.async {
        print("Failed to load homes: \(error?.localizedDescription ?? "Unknown error")")
        result(FlutterError(code: "HOMES_ERROR", message: error?.localizedDescription ?? "Unknown error", details: nil))
      }
    }
  }
  
  private func getHomes(result: @escaping FlutterResult) {
    print("Getting homes list")
    
    ThingSmartHomeManager.sharedInstance().getHomeList { homes in
      DispatchQueue.main.async {
        let homeList = homes?.map { home in
          [
            "homeId": home.homeId,
            "name": home.name,
            "geoName": home.geoName ?? "",
            "admin": home.admin,
            "cityId": home.cityId,
            "lat": home.lat,
            "lon": home.lon
          ]
        } ?? []
        result(homeList)
      }
    } failure: { error in
      DispatchQueue.main.async {
        print("Failed to get homes: \(error?.localizedDescription ?? "Unknown error")")
        result(FlutterError(code: "HOMES_ERROR", message: error?.localizedDescription ?? "Unknown error", details: nil))
      }
    }
  }
  
  private func getDevices(homeId: String, result: @escaping FlutterResult) {
    print("Getting devices for home: \(homeId)")
    
    ThingSmartHomeManager.sharedInstance().getHomeList { homes in
      guard let home = homes?.first(where: { $0.homeId == homeId }) else {
        DispatchQueue.main.async {
          result(FlutterError(code: "HOME_NOT_FOUND", message: "Home not found", details: nil))
        }
        return
      }
      
      home.getDeviceList { devices in
        DispatchQueue.main.async {
          let deviceList = devices?.map { device in
            [
              "devId": device.devId,
              "name": device.name,
              "isOnline": device.isOnline,
              "productId": device.productId,
              "iconUrl": device.iconUrl ?? "",
              "nodeId": device.nodeId ?? ""
            ]
          } ?? []
          result(deviceList)
        }
      } failure: { error in
        DispatchQueue.main.async {
          print("Failed to get devices: \(error?.localizedDescription ?? "Unknown error")")
          result(FlutterError(code: "DEVICES_ERROR", message: error?.localizedDescription ?? "Unknown error", details: nil))
        }
      }
    } failure: { error in
      DispatchQueue.main.async {
        print("Failed to load homes: \(error?.localizedDescription ?? "Unknown error")")
        result(FlutterError(code: "HOMES_ERROR", message: error?.localizedDescription ?? "Unknown error", details: nil))
      }
    }
  }
}
