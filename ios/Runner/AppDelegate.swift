import UIKit
import Flutter
import workmanager

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
    GeneratedPluginRegistrant.register(with: registry) 
    }

    WorkmanagerPlugin.registerTask(withIdentifier: "getPassBaseStatusBackground")
    WorkmanagerPlugin.registerTask(withIdentifier: "io.altme.wallet.matrixNotification")
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*1))
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

   override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         completionHandler(.alert) // shows banner even if app is in foreground
     }
}
