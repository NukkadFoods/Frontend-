import Flutter
import UIKit
import FirebaseCore
import UserNotifications
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase first
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }
    
    // Configure Google Maps
    GMSServices.provideAPIKey("AIzaSyCsZ1wSI0CdaLU35oH4l4dhQrz7TjBSYTw")
    
    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)
    
    // Register for remote notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { granted, error in
          print("🔔 Restaurant App: Notification permission granted: \(granted)")
          if let error = error {
            print("❌ Restaurant App: Notification permission error: \(error.localizedDescription)")
          }
        }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    application.registerForRemoteNotifications()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // APNs token received successfully
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("🍎 [RESTAURANT] APNs Token received successfully!")
    print("🔑 [RESTAURANT] APNs Token: \(token)")
    print("📱 [RESTAURANT] Token length: \(token.count) characters")
    print("✅ [RESTAURANT] iOS Push Notifications are properly configured!")
    
    // Pass the token to Flutter plugins (Firebase, etc.)
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  // APNs token registration failed
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("❌ [RESTAURANT] Failed to register for remote notifications!")
    print("❌ [RESTAURANT] Error: \(error.localizedDescription)")
    
    if let error = error as NSError? {
      switch error.code {
      case 3000:
        print("💡 [RESTAURANT] Solution: This is likely because you're running on iOS Simulator")
        print("💡 [RESTAURANT] Try running on a physical iOS device to get a real APNs token")
      case 3010:
        print("💡 [RESTAURANT] Solution: Check your Apple Developer account and provisioning profile")
      default:
        print("💡 [RESTAURANT] Error code: \(error.code)")
      }
    }
    
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
