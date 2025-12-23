import Foundation
import UIKit
import GeckoView

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        print("[Floorp] SceneDelegate: Building UI")
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = BrowserViewController()
        window?.makeKeyAndVisible()
    }
}

