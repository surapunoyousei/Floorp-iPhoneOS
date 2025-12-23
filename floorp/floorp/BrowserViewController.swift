// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import GeckoView

@objc(BrowserViewController)
class BrowserViewController: UIViewController {
    
    // MARK: - UI Components
    
    /// Fills the area above safe area (status bar / Dynamic Island)
    private lazy var topSafeAreaFiller: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(white: 0.1, alpha: 1.0)
                : .systemBackground
        }
        return view
    }()
    
    /// URL bar at top (Desktop Floorp style)
    private lazy var urlBar: BrowserURLBar = {
        let bar = BrowserURLBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.delegate = self
        return bar
    }()
    
    private lazy var progressBar: UIProgressView = {
        let progress = UIProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressTintColor = .systemBlue
        progress.trackTintColor = .clear
        return progress
    }()
    
    private lazy var geckoView: GeckoView = {
        let view = GeckoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    /// Bottom navigation bar with buttons
    private lazy var bottomBar: BrowserBottomBar = {
        let bar = BrowserBottomBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.delegate = self
        return bar
    }()
    
    /// Fills the area below safe area (home indicator)
    private lazy var bottomSafeAreaFiller: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(white: 0.1, alpha: 1.0)
                : .systemBackground
        }
        return view
    }()
    
    // MARK: - Properties
    
    private var session: GeckoSession!
    private var homepage = "https://floorp.app"
    
    // MARK: - Lifecycle
    
    @objc init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use dark interface style for Floorp look
        overrideUserInterfaceStyle = .dark
        
        view.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        setupUI()
        setupGeckoSession()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Add subviews
        view.addSubview(geckoView)
        view.addSubview(topSafeAreaFiller)
        view.addSubview(urlBar)
        view.addSubview(progressBar)
        view.addSubview(bottomBar)
        view.addSubview(bottomSafeAreaFiller)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Top safe area filler
            topSafeAreaFiller.topAnchor.constraint(equalTo: view.topAnchor),
            topSafeAreaFiller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSafeAreaFiller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSafeAreaFiller.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            // URL bar at top
            urlBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            urlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            urlBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            urlBar.heightAnchor.constraint(equalToConstant: 52),
            
            // Progress bar
            progressBar.topAnchor.constraint(equalTo: urlBar.bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 2),
            
            // Bottom bar
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 50),
            
            // Bottom safe area filler
            bottomSafeAreaFiller.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomSafeAreaFiller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSafeAreaFiller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSafeAreaFiller.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // GeckoView (fills remaining space)
            geckoView.topAnchor.constraint(equalTo: progressBar.bottomAnchor),
            geckoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            geckoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            geckoView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
        ])
        
        // Initial state
        progressBar.isHidden = true
    }
    
    // MARK: - Gecko Setup
    
    private func setupGeckoSession() {
        session = GeckoSession()
        session.navigationDelegate = self
        session.progressDelegate = self
        session.contentDelegate = self
        session.open()
        
        geckoView.session = session
        
        // Load homepage
        if !homepage.isEmpty {
            session.load(homepage)
        }
    }
    
    // MARK: - Navigation
    
    private func loadURL(_ urlString: String) {
        urlBar.resignFirstResponder()
        session.load(urlString)
    }
}

// MARK: - BrowserURLBarDelegate
extension BrowserViewController: BrowserURLBarDelegate {
    func urlSubmitted(_ url: String) {
        loadURL(url)
    }
}

// MARK: - BrowserBottomBarDelegate
extension BrowserViewController: BrowserBottomBarDelegate {
    func backButtonTapped() {
        session.goBack()
    }
    
    func forwardButtonTapped() {
        session.goForward()
    }
    
    func reloadButtonTapped() {
        session.reload()
    }
    
    func stopButtonTapped() {
        session.stop()
    }
    
    func homeButtonTapped() {
        loadURL(homepage)
    }
    
    func tabsButtonTapped() {
        // TODO: Implement tab management
        print("[Floorp] Tabs button tapped - not implemented yet")
    }
}

// MARK: - NavigationDelegate
extension BrowserViewController: NavigationDelegate {
    func onLocationChange(session: GeckoSession, url: String?, permissions: [ContentPermission]) {
        urlBar.setURL(url)
    }
    
    func onCanGoBack(session: GeckoSession, canGoBack: Bool) {
        bottomBar.updateBackButton(canGoBack: canGoBack)
    }
    
    func onCanGoForward(session: GeckoSession, canGoForward: Bool) {
        bottomBar.updateForwardButton(canGoForward: canGoForward)
    }
    
    func onLoadRequest(session: GeckoSession, request: LoadRequest) -> AllowOrDeny {
        return .allow
    }
    
    func onSubframeLoadRequest(session: GeckoSession, request: LoadRequest) -> AllowOrDeny {
        return .allow
    }
    
    func onNewSession(session: GeckoSession, uri: String) -> GeckoSession? {
        return nil
    }
}

// MARK: - ProgressDelegate
extension BrowserViewController: ProgressDelegate {
    func onPageStart(session: GeckoSession, url: String) {
        progressBar.isHidden = false
        progressBar.progress = 0
        bottomBar.updateLoadingState(isLoading: true)
    }
    
    func onPageStop(session: GeckoSession, success: Bool) {
        progressBar.isHidden = true
        bottomBar.updateLoadingState(isLoading: false)
    }
    
    func onProgressChange(session: GeckoSession, progress: Int) {
        progressBar.progress = Float(progress) / 100.0
    }
}

// MARK: - ContentDelegate
extension BrowserViewController: ContentDelegate {
    func onTitleChange(session: GeckoSession, title: String) {}
    
    func onPreviewImage(session: GeckoSession, previewImageUrl: String) {}
    
    func onFocusRequest(session: GeckoSession) {}
    
    func onCloseRequest(session: GeckoSession) {}
    
    func onFullScreen(session: GeckoSession, fullScreen: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.topSafeAreaFiller.isHidden = fullScreen
            self.urlBar.isHidden = fullScreen
            self.progressBar.isHidden = fullScreen
            self.bottomBar.isHidden = fullScreen
            self.bottomSafeAreaFiller.isHidden = fullScreen
        }
    }
    
    func onMetaViewportFitChange(session: GeckoSession, viewportFit: String) {}
    
    func onProductUrl(session: GeckoSession) {}
    
    func onContextMenu(session: GeckoSession, screenX: Int, screenY: Int, element: ContextElement) {}
    
    func onCrash(session: GeckoSession) {
        let alert = UIAlertController(
            title: "Page Crashed",
            message: "Something went wrong with this page.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Reload", style: .default) { [weak self] _ in
            self?.session.open()
            self?.geckoView.session = self?.session
            self?.session.load(self?.homepage ?? "https://floorp.app")
        })
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }
    
    func onKill(session: GeckoSession) {
        onCrash(session: session)
    }
    
    func onFirstComposite(session: GeckoSession) {}
    
    func onFirstContentfulPaint(session: GeckoSession) {}
    
    func onPaintStatusReset(session: GeckoSession) {}
    
    func onWebAppManifest(session: GeckoSession, manifest: Any) {}
    
    func onSlowScript(session: GeckoSession, scriptFileName: String) async -> SlowScriptResponse {
        return .halt
    }
    
    func onShowDynamicToolbar(session: GeckoSession) {}
    
    func onCookieBannerDetected(session: GeckoSession) {}
    
    func onCookieBannerHandled(session: GeckoSession) {}
}
