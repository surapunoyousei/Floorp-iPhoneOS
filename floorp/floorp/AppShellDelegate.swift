import UIKit
import GeckoView

// @objc(AppShellDelegate) を付けることで、Gecko 内部の C++ コードが 
// UIApplicationMain(..., @"AppShellDelegate") を呼んだ際に、
// この Swift クラスが身代わりとして呼び出されるようになります。
@objc(AppShellDelegate)
class AppShellDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("[Floorp] AppShellDelegate (Custom): didFinishLaunching")
        return true
    }

    // MARK: UISceneSession Lifecycle
    // これを実装することで、iOS は Info.plist に記載した SceneDelegate を読み込むようになります
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("[Floorp] AppShellDelegate: Scene connection requested")
        let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

