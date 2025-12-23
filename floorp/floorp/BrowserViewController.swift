import Foundation
import UIKit
import GeckoView

@objc(BrowserViewController)
class BrowserViewController: UIViewController {
    private var geckoView: GeckoView!
    private var session: GeckoSession!
    private var isGeckoConfigured = false

    @objc init() {
        super.init(nibName: nil, bundle: nil)
        print("[Floorp] BrowserViewController: init called")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("[Floorp] BrowserViewController: viewDidLoad")
        view.backgroundColor = .blue // 背景を青に（目立つように）

        geckoView = GeckoView()
        geckoView.backgroundColor = .red // GeckoView を赤に
        geckoView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(geckoView)
        NSLayoutConstraint.activate([
            geckoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            geckoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            geckoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            geckoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isGeckoConfigured && geckoView.frame.width > 0 {
            setupGecko()
            isGeckoConfigured = true
        }
    }

    private func setupGecko() {
        print("[Floorp] BrowserViewController: Setting up Gecko with size \(geckoView.frame.size)")
        session = GeckoSession()
        session.open()
        geckoView.session = session
        print("[Floorp] BrowserViewController: Loading floorp.app")
        session.load("https://floorp.app")
    }
}
