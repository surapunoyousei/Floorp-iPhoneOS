// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import GeckoView

@objc(BrowserViewController)
final class BrowserViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var topSafeAreaFiller: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.Colors.background
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
        progress.progressTintColor = Theme.Colors.accent
        progress.trackTintColor = .clear
        progress.isHidden = true
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
        view.backgroundColor = Theme.Colors.background
        return view
    }()
    
    // MARK: - Properties
    
    private let tabManager = TabManager.shared
    
    private var currentTab: Tab? {
        tabManager.selectedTab
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
        configureAppearance()
        setupUI()
        setupTabManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ensureTabLoaded()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Configuration
    
    private func configureAppearance() {
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = Theme.Colors.background
    }
    
    private func setupUI() {
        view.addSubview(geckoView)
        view.addSubview(topSafeAreaFiller)
        view.addSubview(urlBar)
        view.addSubview(progressBar)
        view.addSubview(bottomBar)
        view.addSubview(bottomSafeAreaFiller)
        
        NSLayoutConstraint.activate([
            // Top safe area filler
            topSafeAreaFiller.topAnchor.constraint(equalTo: view.topAnchor),
            topSafeAreaFiller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSafeAreaFiller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSafeAreaFiller.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            // URL bar
            urlBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            urlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            urlBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            urlBar.heightAnchor.constraint(equalToConstant: Constants.Layout.urlBarHeight),
            
            // Progress bar
            progressBar.topAnchor.constraint(equalTo: urlBar.bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: Constants.Layout.progressBarHeight),
            
            // Bottom bar
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: Constants.Layout.bottomBarHeight),
            
            // Bottom safe area filler
            bottomSafeAreaFiller.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomSafeAreaFiller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSafeAreaFiller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSafeAreaFiller.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Gecko view
            geckoView.topAnchor.constraint(equalTo: progressBar.bottomAnchor),
            geckoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            geckoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            geckoView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
        ])
    }
    
    private func setupTabManager() {
        tabManager.delegate = self
        
        if tabManager.isEmpty {
            tabManager.createTab(url: Constants.URLs.homepage)
        } else if let tab = tabManager.selectedTab {
            connectToTab(tab)
        }
    }
    
    private func ensureTabLoaded() {
        guard let tab = currentTab, tab.url == nil else { return }
        tab.load(Constants.URLs.homepage)
    }
    
    // MARK: - Tab Connection
    
    private func connectToTab(_ tab: Tab) {
        // Set up delegates
        tab.session.navigationDelegate = self
        tab.session.progressDelegate = self
        tab.session.contentDelegate = self
        
        // Connect GeckoView
        geckoView.session = tab.session
        
        // Update UI
        urlBar.setURL(tab.url)
        bottomBar.updateBackButton(canGoBack: tab.canGoBack)
        bottomBar.updateForwardButton(canGoForward: tab.canGoForward)
    }
    
    // MARK: - Screenshot
    
    private func captureScreenshot() -> UIImage? {
        UIGraphicsImageRenderer(bounds: geckoView.bounds).image { _ in
            geckoView.drawHierarchy(in: geckoView.bounds, afterScreenUpdates: true)
        }
    }
    
    private func updateCurrentTabScreenshot() {
        guard let tab = currentTab else { return }
        tabManager.updateTab(tab, screenshot: captureScreenshot())
    }
    
    // MARK: - Navigation
    
    private func loadURL(_ urlString: String) {
        urlBar.resignFirstResponder()
        currentTab?.load(urlString)
    }
    
    // MARK: - Tab Switcher
    
    private func showTabSwitcher() {
        updateCurrentTabScreenshot()
        
        let tabSwitcher = TabSwitcherViewController()
        tabSwitcher.delegate = self
        tabSwitcher.modalPresentationStyle = .fullScreen
        present(tabSwitcher, animated: true)
    }
    
    // MARK: - Full Screen
    
    private func setFullScreen(_ isFullScreen: Bool, animated: Bool = true) {
        let duration = animated ? Constants.Animation.defaultDuration : 0
        
        UIView.animate(withDuration: duration) {
            self.topSafeAreaFiller.isHidden = isFullScreen
            self.urlBar.isHidden = isFullScreen
            self.progressBar.isHidden = isFullScreen
            self.bottomBar.isHidden = isFullScreen
            self.bottomSafeAreaFiller.isHidden = isFullScreen
        }
    }
}

// MARK: - TabManagerDelegate

extension BrowserViewController: TabManagerDelegate {
    
    func tabManager(_ manager: TabManager, didSelectTab tab: Tab) {
        connectToTab(tab)
    }
    
    func tabManager(_ manager: TabManager, didAddTab tab: Tab) {
        tab.session.navigationDelegate = self
        tab.session.progressDelegate = self
        tab.session.contentDelegate = self
    }
    
    func tabManager(_ manager: TabManager, didRemoveTab tab: Tab) {
        // Cleanup handled by TabManager
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
        tabManager.createTab(url: Constants.URLs.homepage)
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
        currentTab?.goBack()
    }
    
    func forwardButtonTapped() {
        currentTab?.goForward()
    }
    
    func reloadButtonTapped() {
        currentTab?.reload()
    }
    
    func stopButtonTapped() {
        currentTab?.stop()
    }
    
    func homeButtonTapped() {
        loadURL(Constants.URLs.homepage)
    }
    
    func tabsButtonTapped() {
        showTabSwitcher()
    }
}

// MARK: - NavigationDelegate

extension BrowserViewController: NavigationDelegate {
    
    func onLocationChange(session: GeckoSession, url: String?, permissions: [ContentPermission]) {
        guard let tab = tabManager.tab(for: session), tab == currentTab else { return }
        urlBar.setURL(url)
        tabManager.updateTab(tab, url: url)
    }
    
    func onCanGoBack(session: GeckoSession, canGoBack: Bool) {
        guard let tab = tabManager.tab(for: session), tab == currentTab else { return }
        tab.canGoBack = canGoBack
        bottomBar.updateBackButton(canGoBack: canGoBack)
    }
    
    func onCanGoForward(session: GeckoSession, canGoForward: Bool) {
        guard let tab = tabManager.tab(for: session), tab == currentTab else { return }
        tab.canGoForward = canGoForward
        bottomBar.updateForwardButton(canGoForward: canGoForward)
    }
    
    func onLoadRequest(session: GeckoSession, request: LoadRequest) -> AllowOrDeny {
        .allow
    }
    
    func onSubframeLoadRequest(session: GeckoSession, request: LoadRequest) -> AllowOrDeny {
        .allow
    }
    
    func onNewSession(session: GeckoSession, uri: String) -> GeckoSession? {
        tabManager.createTab(url: uri).session
    }
}

// MARK: - ProgressDelegate

extension BrowserViewController: ProgressDelegate {
    
    func onPageStart(session: GeckoSession, url: String) {
        guard tabManager.tab(for: session) == currentTab else { return }
        progressBar.isHidden = false
        progressBar.progress = 0
        bottomBar.updateLoadingState(isLoading: true)
    }
    
    func onPageStop(session: GeckoSession, success: Bool) {
        guard tabManager.tab(for: session) == currentTab else { return }
        progressBar.isHidden = true
        bottomBar.updateLoadingState(isLoading: false)
        
        // Capture screenshot after page load
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Animation.screenshotDelay) { [weak self] in
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
        guard let tab = tabManager.tab(for: session) else { return }
        tabManager.updateTab(tab, title: title)
    }
    
    func onPreviewImage(session: GeckoSession, previewImageUrl: String) {}
    
    func onFocusRequest(session: GeckoSession) {}
    
    func onCloseRequest(session: GeckoSession) {
        guard let tab = tabManager.tab(for: session) else { return }
        tabManager.closeTab(tab)
    }
    
    func onFullScreen(session: GeckoSession, fullScreen: Bool) {
        setFullScreen(fullScreen)
    }
    
    func onMetaViewportFitChange(session: GeckoSession, viewportFit: String) {}
    
    func onProductUrl(session: GeckoSession) {}
    
    func onContextMenu(session: GeckoSession, screenX: Int, screenY: Int, element: ContextElement) {}
    
    func onCrash(session: GeckoSession) {
        presentCrashAlert(for: session)
    }
    
    func onKill(session: GeckoSession) {
        presentCrashAlert(for: session)
    }
    
    func onFirstComposite(session: GeckoSession) {}
    
    func onFirstContentfulPaint(session: GeckoSession) {}
    
    func onPaintStatusReset(session: GeckoSession) {}
    
    func onWebAppManifest(session: GeckoSession, manifest: Any) {}
    
    func onSlowScript(session: GeckoSession, scriptFileName: String) async -> SlowScriptResponse {
        .halt
    }
    
    func onShowDynamicToolbar(session: GeckoSession) {}
    
    func onCookieBannerDetected(session: GeckoSession) {}
    
    func onCookieBannerHandled(session: GeckoSession) {}
    
    // MARK: - Crash Handling
    
    private func presentCrashAlert(for session: GeckoSession) {
        let alert = UIAlertController(
            title: "Page Crashed",
            message: "Something went wrong with this page.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Reload", style: .default) { [weak self] _ in
            guard let self, let tab = self.tabManager.tab(for: session) else { return }
            tab.open()
            self.geckoView.session = tab.session
            tab.load(tab.url ?? Constants.URLs.homepage)
        })
        
        alert.addAction(UIAlertAction(title: "Close Tab", style: .destructive) { [weak self] _ in
            guard let self, let tab = self.tabManager.tab(for: session) else { return }
            self.tabManager.closeTab(tab)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}
