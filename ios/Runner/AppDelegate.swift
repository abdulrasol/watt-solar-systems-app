import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register for remote notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: { granted, error in
        if granted {
          print("✅ Notification permission granted")
          DispatchQueue.main.async {
            application.registerForRemoteNotifications()
          }
        } else {
          print("❌ Notification permission denied: \(error?.localizedDescription ?? "unknown error")")
        }
      }
    )
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
