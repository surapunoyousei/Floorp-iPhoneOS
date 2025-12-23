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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        geckoView = GeckoView()
        geckoView.backgroundColor = .white
        geckoView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(geckoView)
        // 画面全体（セーフエリア無視で全画面）に広げる
        NSLayoutConstraint.activate([
            geckoView.topAnchor.constraint(equalTo: view.topAnchor),
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
        session = GeckoSession()
        session.navigationDelegate = self
        session.progressDelegate = self
        session.open()
        
        geckoView.session = session
        
        // 17.4+ の Browser Engine Kit 向けにセッションを確実にアクティブ化
        // (以前クラッシュした setActive は慎重に。ここでは load を優先)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("[Floorp] Loading initial page: https://floorp.app")
            self.session.load("https://floorp.app")
        }
    }
}

extension BrowserViewController: NavigationDelegate {
    func onLocationChange(session: GeckoSession, url: String?, permissions: [ContentPermission]) {
        print("[Floorp] URL -> \(url ?? "nil")")
    }
    func onLoadRequest(session: GeckoSession, request: LoadRequest) -> AllowOrDeny { .allow }
    func onCanGoBack(session: GeckoSession, canGoBack: Bool) {}
    func onCanGoForward(session: GeckoSession, canGoForward: Bool) {}
    func onSubframeLoadRequest(session: GeckoSession, request: LoadRequest) -> AllowOrDeny { .allow }
    func onNewSession(session: GeckoSession, uri: String) -> GeckoSession? { nil }
}

extension BrowserViewController: ProgressDelegate {
    func onPageStart(session: GeckoSession, url: String) {}
    func onPageStop(session: GeckoSession, success: Bool) {}
    func onProgressChange(session: GeckoSession, progress: Int) {}
}
