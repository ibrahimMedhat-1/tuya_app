import Flutter
import UIKit
import ThingSmartBaseKit // Import Tuya SDK
import ThingSmartDeviceKit
import ThingSmartHomeKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var userChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Initialize Tuya SDK with your actual keys
    ThingSmartSDK.sharedInstance().start(withAppKey: "m7q5wupkcc55e4wamdxr", secretKey: "u53dy9rtuu4vqkp93g3cyuf9pchxag9c")

    // Set up the Flutter MethodChannel for Tuya operations
    if let controller = window?.rootViewController as? FlutterViewController {
      let channelName = "com.zerotechiot.eg/tuya_sdk" // Dart side should match this
      let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
      self.userChannel = channel
      channel.setMethodCallHandler { [weak self] call, result in
        guard let self = self else { return }
        switch call.method {
        case "login":
          guard
            let args = call.arguments as? [String: Any],
             let email = args["email"] as? String,
            let password = args["password"] as? String
          else {
            result(FlutterError(code: "ARG_ERROR", message: "Missing countryCode/email/password", details: nil))
            return
          }
            ThingSmartUser.sharedInstance().login( byEmail: email, email:email,password: password, success: {
            result(self.makeUserPayload())
          }, failure: { error in
              result(FlutterError(code: "Login Failure", message: error?.localizedDescription, details: nil))
          })
        case "isLoggedIn":
          let user = ThingSmartUser.sharedInstance()
          if user.isLogin {
            result(self.makeUserPayload())
          } else {
            result(nil)
          }
        case "logout":
          ThingSmartUser.sharedInstance().logout({
            result(nil)
          }, failure: { error in
            result(FlutterError(code: "LOGOUT_FAILED", message: error?.localizedDescription, details: nil))
          })
        case "getHomes":
          ThingSmartHomeManager().getHomeList { list in
            let mapped = list?.map { home in
              return [
                "homeId": home.homeId,
                "name": home.name ?? ""
              ]
            } ?? []
            result(mapped)
          } failure: { error in
            result(FlutterError(code: "GET_HOMES_FAILED", message: error?.localizedDescription, details: nil))
          }
        case "getHomeDevices":
          guard let args = call.arguments as? [String: Any], let homeId = args["homeId"] as? Int else {
            result(FlutterError(code: "ARG_ERROR", message: "Missing homeId", details: nil))
            return
          }
          let home = ThingSmartHome(homeId: UInt64(homeId))
          home?.getHomeDetail({ homeModel in
            let devices = homeModel?.deviceList?.map { dev in
              return [
                "deviceId": dev.devId ?? "",
                "name": dev.name ?? "",
                "isOnline": dev.isOnline
              ] as [String : Any]
            } ?? []
            result(devices)
          }, failure: { error in
            result(FlutterError(code: "GET_HOME_DEVICES_FAILED", message: error?.localizedDescription, details: nil))
          })
        case "controlDevice":
          guard let args = call.arguments as? [String: Any], let deviceId = args["deviceId"] as? String, let dps = args["dps"] as? [String: Any] else {
            result(FlutterError(code: "ARG_ERROR", message: "Missing deviceId/dps", details: nil))
            return
          }
          let device = ThingSmartDevice.init(deviceId: deviceId)
          device?.publishDps(dps, success: {
            result(nil)
          }, failure: { error in
            result(FlutterError(code: "CONTROL_DEVICE_FAILED", message: error?.localizedDescription, details: nil))
          })
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Build a payload with current user info after successful login
  private func makeUserPayload() -> [String: Any] {
    let u = ThingSmartUser.sharedInstance()
    return [
        "id": u.uid,
      "email": u.email,
      "name": u.userName,
      ]
  }
}

