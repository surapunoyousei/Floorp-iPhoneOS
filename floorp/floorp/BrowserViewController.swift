// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import GeckoView

@objc(BrowserViewController)
class BrowserViewController: UIViewController {
    
    // MARK: - UI Components
    
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
    
    private lazy var bottomBar: BrowserBottomBar = {
        let bar = BrowserBottomBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.delegate = self
        return bar
    }()
    
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
    
    private let tabManager = TabManager.shared
    private var homepage = "https://floorp.app"
    
    private var currentTab: Tab? {
        return tabManager.selectedTab
    }
    
    // MARK: - Lifecycle
    
    @objc init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        setupUI()
        setupTabManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Ensure homepage is loaded if current tab has no URL
        if let tab = currentTab, tab.url == nil {
            tab.load(homepage)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(geckoView)
        view.addSubview(topSafeAreaFiller)
        view.addSubview(urlBar)
        view.addSubview(progressBar)
        view.addSubview(bottomBar)
        view.addSubview(bottomSafeAreaFiller)
        
        NSLayoutConstraint.activate([
            topSafeAreaFiller.topAnchor.constraint(equalTo: view.topAnchor),
            topSafeAreaFiller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSafeAreaFiller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSafeAreaFiller.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            urlBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            urlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            urlBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            urlBar.heightAnchor.constraint(equalToConstant: 52),
            
            progressBar.topAnchor.constraint(equalTo: urlBar.bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 2),
            
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 50),
            
            bottomSafeAreaFiller.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomSafeAreaFiller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSafeAreaFiller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSafeAreaFiller.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            geckoView.topAnchor.constraint(equalTo: progressBar.bottomAnchor),
            geckoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            geckoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            geckoView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
        ])
        
        progressBar.isHidden = true
    }
    
    // MARK: - Tab Manager Setup
    
    private func setupTabManager() {
        tabManager.delegate = self
        
        // Create first tab if none exist
        if tabManager.tabs.isEmpty {
            tabManager.createTab(url: homepage)
        } else if let tab = tabManager.selectedTab {
            // Reconnect to existing tab
            connectToTab(tab)
        }
    }
    
    private func connectToTab(_ tab: Tab) {
        // Set up delegates for the tab's session
        tab.session.navigationDelegate = self
        tab.session.progressDelegate = self
        tab.session.contentDelegate = self
        
        // Connect GeckoView to session
        geckoView.session = tab.session
        
        // Update UI
        urlBar.setURL(tab.url)
        bottomBar.updateBackButton(canGoBack: tab.canGoBack)
        bottomBar.updateForwardButton(canGoForward: tab.canGoForward)
    }
    
    // MARK: - Screenshot
    
    private func captureScreenshot() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: geckoView.bounds)
        return renderer.image { context in
            geckoView.drawHierarchy(in: geckoView.bounds, afterScreenUpdates: true)
        }
    }
    
    private func updateCurrentTabScreenshot() {
        guard let tab = currentTab else { return }
        let screenshot = captureScreenshot()
        tabManager.updateTab(tab, screenshot: screenshot)
    }
    
    // MARK: - Navigation
    
    private func loadURL(_ urlString: String) {
        urlBar.resignFirstResponder()
        currentTab?.load(urlString)
    }
    
    // MARK: - Tab Switcher
    
    private func showTabSwitcher() {
        // Capture screenshot before showing switcher
        updateCurrentTabScreenshot()
        
        let tabSwitcher = TabSwitcherViewController()
        tabSwitcher.delegate = self
        tabSwitcher.modalPresentationStyle = .fullScreen
        present(tabSwitcher, animated: true)
    }
}

// MARK: - TabManagerDelegate
extension BrowserViewController: TabManagerDelegate {
    func tabManager(_ manager: TabManager, didSelectTab tab: Tab) {
        connectToTab(tab)
    }
    
    func tabManager(_ manager: TabManager, didAddTab tab: Tab) {
        // Set up the new tab
        tab.session.navigationDelegate = self
        tab.session.progressDelegate = self
        tab.session.contentDelegate = self
    }
    
    func tabManager(_ manager: TabManager, didRemoveTab tab: Tab) {
        // Tab cleanup is handled by TabManager
    }
    
    func tabManagerDidUpdateTabs(_ manager: TabManager) {
        // Could update tab count badge here
    }
}

// MARK: - TabSwitcherDelegate
extension BrowserViewController: TabSwitcherDelegate {
    func tabSwitcher(_ switcher: TabSwitcherViewController, didSelectTab tab: Tab) {
        tabManager.selectTab(tab)
        switcher.dismiss(animated: true)
    }
    
    func tabSwitcher(_ switcher: TabSwitcherViewController, didCloseTab tab: Tab) {
        tabManager.closeTab(tab)
    }
    
    func tabSwitcherDidRequestNewTab(_ switcher: TabSwitcherViewController) {
        tabManager.createTab(url: homepage)
        switcher.dismiss(animated: true)
    }
    
    func tabSwitcherDidRequestDismiss(_ switcher: TabSwitcherViewController) {
        switcher.dismiss(animated: true)
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
        currentTab?.session.goBack()
    }
    
    func forwardButtonTapped() {
        currentTab?.session.goForward()
    }
    
    func reloadButtonTapped() {
        currentTab?.session.reload()
    }
    
    func stopButtonTapped() {
        currentTab?.session.stop()
    }
    
    func homeButtonTapped() {
        loadURL(homepage)
    }
    
    func tabsButtonTapped() {
        showTabSwitcher()
    }
}

// MARK: - NavigationDelegate
extension BrowserViewController: NavigationDelegate {
    func onLocationChange(session: GeckoSession, url: String?, permissions: [ContentPermission]) {
        guard let tab = currentTab, tab.session === session else { return }
        urlBar.setURL(url)
        tabManager.updateTab(tab, url: url)
    }
    
    func onCanGoBack(session: GeckoSession, canGoBack: Bool) {
        guard let tab = currentTab, tab.session === session else { return }
        tab.canGoBack = canGoBack
        bottomBar.updateBackButton(canGoBack: canGoBack)
    }
    
    func onCanGoForward(session: GeckoSession, canGoForward: Bool) {
        guard let tab = currentTab, tab.session === session else { return }
        tab.canGoForward = canGoForward
        bottomBar.updateForwardButton(canGoForward: canGoForward)
    }
    
    func onLoadRequest(session: GeckoSession, request: LoadRequest) -> AllowOrDeny {
        return .allow
    }
    
    func onSubframeLoadRequest(session: GeckoSession, request: LoadRequest) -> AllowOrDeny {
        return .allow
    }
    
    func onNewSession(session: GeckoSession, uri: String) -> GeckoSession? {
        // Open in new tab
        let newTab = tabManager.createTab(url: uri)
        return newTab.session
    }
}

// MARK: - ProgressDelegate
extension BrowserViewController: ProgressDelegate {
    func onPageStart(session: GeckoSession, url: String) {
        guard let tab = currentTab, tab.session === session else { return }
        progressBar.isHidden = false
        progressBar.progress = 0
        bottomBar.updateLoadingState(isLoading: true)
    }
    
    func onPageStop(session: GeckoSession, success: Bool) {
        guard let tab = currentTab, tab.session === session else { return }
        progressBar.isHidden = true
        bottomBar.updateLoadingState(isLoading: false)
        
        // Capture screenshot after page load
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.updateCurrentTabScreenshot()
        }
    }
    
    func onProgressChange(session: GeckoSession, progress: Int) {
        progressBar.progress = Float(progress) / 100.0
    }
}

// MARK: - ContentDelegate
extension BrowserViewController: ContentDelegate {
    func onTitleChange(session: GeckoSession, title: String) {
        guard let tab = currentTab, tab.session === session else { return }
        tabManager.updateTab(tab, title: title)
    }
    
    func onPreviewImage(session: GeckoSession, previewImageUrl: String) {}
    
    func onFocusRequest(session: GeckoSession) {}
    
    func onCloseRequest(session: GeckoSession) {
        // Find and close the tab that requested close
        if let tab = tabManager.tabs.first(where: { $0.session === session }) {
            tabManager.closeTab(tab)
        }
    }
    
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
            self?.currentTab?.session.open()
            if let tab = self?.currentTab {
                self?.geckoView.session = tab.session
                tab.load(self?.homepage ?? "https://floorp.app")
            }
        })
        alert.addAction(UIAlertAction(title: "Close Tab", style: .destructive) { [weak self] _ in
            if let tab = self?.currentTab {
                self?.tabManager.closeTab(tab)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
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
