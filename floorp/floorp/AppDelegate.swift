import UIKit

@objc(AppDelegate)
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("[Floorp] AppDelegate: didFinishLaunching")
        return true
    }

    // これが重要：システムに SceneDelegate を使わせるための設定
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("[Floorp] AppDelegate: Connecting SceneDelegate")
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

