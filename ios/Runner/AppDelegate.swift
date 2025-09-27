import Flutter
import UIKit
import ThingSmartBaseKit // Import Tuya SDK

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

    // Set up the Flutter MethodChannel for user/login operations
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
