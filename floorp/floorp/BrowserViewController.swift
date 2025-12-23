import Foundation
import UIKit
import GeckoView

@objc(BrowserViewController)
class BrowserViewController: UIViewController {
    private var geckoView: GeckoView!
    private var session: GeckoSession!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupGecko()
    }

    private func setupGecko() {
        print("[Floorp] BrowserViewController: Setting up Gecko")
        
        session = GeckoSession()
        session.open()
        
        geckoView = GeckoView()
        geckoView.session = session
        geckoView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(geckoView)
        NSLayoutConstraint.activate([
            geckoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            geckoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            geckoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            geckoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        print("[Floorp] BrowserViewController: Loading floorp.app")
        session.load("https://floorp.app")
    }
}

