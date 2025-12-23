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
    private lazy var topSafeAreaFiller: UIView = .build { view in
        view.backgroundColor = .systemBackground
    }
    
    private lazy var searchBar: BrowserSearchBar = .build { bar in
        bar.backgroundColor = .systemBackground
    }
    
    private lazy var progressBar: UIProgressView = .build { progress in
        progress.progressTintColor = .systemBlue
        progress.trackTintColor = .systemGray5
    }
    
    private lazy var geckoView: GeckoView = .build { view in
        view.backgroundColor = .white
    }
    
    private lazy var toolbar: BrowserToolbar = .build { toolbar in
        toolbar.isTranslucent = false
    }
    
    /// Fills the area below safe area (home indicator)
    private lazy var bottomSafeAreaFiller: UIView = .build { view in
        view.backgroundColor = .systemBackground
    }
    
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
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupGeckoSession()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Add subviews in order (bottom to top for z-order)
        view.addSubview(geckoView)
        view.addSubview(topSafeAreaFiller)
        view.addSubview(searchBar)
        view.addSubview(progressBar)
        view.addSubview(toolbar)
        view.addSubview(bottomSafeAreaFiller)
        
        // Configure delegates
        searchBar.configure(delegate: self)
        toolbar.toolbarDelegate = self
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Top safe area filler (from top edge to safe area top)
            topSafeAreaFiller.topAnchor.constraint(equalTo: view.topAnchor),
            topSafeAreaFiller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSafeAreaFiller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSafeAreaFiller.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            // Search bar (at top safe area)
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 56),
            
            // Progress bar (below search bar)
            progressBar.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 2),
            
            // GeckoView (fills remaining space between progress bar and toolbar)
            geckoView.topAnchor.constraint(equalTo: progressBar.bottomAnchor),
            geckoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            geckoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            geckoView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            
            // Toolbar (above bottom safe area)
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44),
            
            // Bottom safe area filler (below toolbar to bottom edge)
            bottomSafeAreaFiller.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomSafeAreaFiller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSafeAreaFiller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSafeAreaFiller.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
            browse(to: homepage)
        }
    }
    
    // MARK: - Navigation
    
    private func browse(to urlString: String) {
        searchBar.resignFirstResponder()
        
        if let url = searchBar.inputToURL(urlString) {
            session.load(url)
        }
    }
}

// MARK: - BrowserSearchBarDelegate
extension BrowserViewController: BrowserSearchBarDelegate {
    func searchBarDidSubmit(text: String) {
        browse(to: text)
    }
}

// MARK: - BrowserToolbarDelegate
extension BrowserViewController: BrowserToolbarDelegate {
    func backButtonClicked() {
        session.goBack()
    }
    
    func forwardButtonClicked() {
        session.goForward()
    }
    
    func reloadButtonClicked() {
        session.reload()
    }
    
    func stopButtonClicked() {
        session.stop()
    }
}

// MARK: - NavigationDelegate
extension BrowserViewController: NavigationDelegate {
    func onLocationChange(session: GeckoSession, url: String?, permissions: [ContentPermission]) {
        // Update search bar with current URL
        searchBar.setSearchBarText(url)
    }
    
    func onCanGoBack(session: GeckoSession, canGoBack: Bool) {
        toolbar.updateBackButton(canGoBack: canGoBack)
    }
    
    func onCanGoForward(session: GeckoSession, canGoForward: Bool) {
        toolbar.updateForwardButton(canGoForward: canGoForward)
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
        toolbar.updateReloadStopButton(isLoading: true)
    }
    
    func onPageStop(session: GeckoSession, success: Bool) {
        progressBar.isHidden = true
        toolbar.updateReloadStopButton(isLoading: false)
    }
    
    func onProgressChange(session: GeckoSession, progress: Int) {
        progressBar.progress = Float(progress) / 100.0
    }
}

// MARK: - ContentDelegate
extension BrowserViewController: ContentDelegate {
    func onTitleChange(session: GeckoSession, title: String) {
        // Could update window title or tab title here
    }
    
    func onPreviewImage(session: GeckoSession, previewImageUrl: String) {}
    
    func onFocusRequest(session: GeckoSession) {}
    
    func onCloseRequest(session: GeckoSession) {}
    
    func onFullScreen(session: GeckoSession, fullScreen: Bool) {
        // Handle fullscreen mode
        navigationController?.setNavigationBarHidden(fullScreen, animated: true)
        topSafeAreaFiller.isHidden = fullScreen
        searchBar.isHidden = fullScreen
        progressBar.isHidden = fullScreen
        toolbar.isHidden = fullScreen
        bottomSafeAreaFiller.isHidden = fullScreen
    }
    
    func onMetaViewportFitChange(session: GeckoSession, viewportFit: String) {}
    
    func onProductUrl(session: GeckoSession) {}
    
    func onContextMenu(session: GeckoSession, screenX: Int, screenY: Int, element: ContextElement) {
        // Could show context menu here
    }
    
    func onCrash(session: GeckoSession) {
        // Handle crash - could show an error UI and offer to reload
        let alert = UIAlertController(
            title: "ページがクラッシュしました",
            message: "このページで問題が発生しました。",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "再読み込み", style: .default) { [weak self] _ in
            self?.session.open()
            self?.geckoView.session = self?.session
            self?.browse(to: self?.homepage ?? "https://floorp.app")
        })
        alert.addAction(UIAlertAction(title: "閉じる", style: .cancel))
        present(alert, animated: true)
    }
    
    func onKill(session: GeckoSession) {
        // Similar to crash handling
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
