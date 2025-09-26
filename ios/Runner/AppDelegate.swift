import Flutter
import UIKit
import ThingSmartBaseKit // Import Tuya SDK

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Initialize Tuya SDK with your actual keys
    ThingSmartSDK.sharedInstance().start(withAppKey: "m7q5wupkcc55e4wamdxr", secretKey: "u53dy9rtuu4vqkp93g3cyuf9pchxag9c")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
