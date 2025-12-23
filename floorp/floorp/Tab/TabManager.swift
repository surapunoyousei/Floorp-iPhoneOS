// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import GeckoView

// MARK: - TabManagerDelegate

protocol TabManagerDelegate: AnyObject {
    func tabManager(_ manager: TabManager, didSelectTab tab: Tab)
    func tabManager(_ manager: TabManager, didAddTab tab: Tab)
    func tabManager(_ manager: TabManager, didRemoveTab tab: Tab)
    func tabManagerDidUpdateTabs(_ manager: TabManager)
}

// MARK: - TabManager

/// Manages all browser tabs
final class TabManager {
    
    // MARK: - Singleton
    
    static let shared = TabManager()
    
    // MARK: - Properties
    
    weak var delegate: TabManagerDelegate?
    
    private(set) var tabs: [Tab] = []
    private(set) var selectedTab: Tab?
    
    var selectedIndex: Int? {
        guard let tab = selectedTab else { return nil }
        return tabs.firstIndex(of: tab)
    }
    
    var tabCount: Int {
        tabs.count
    }
    
    var isEmpty: Bool {
        tabs.isEmpty
    }
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Tab Creation
    
    /// Creates a new tab and optionally loads a URL
    @discardableResult
    func createTab(url: String? = nil, select: Bool = true) -> Tab {
        let tab = Tab()
        tab.open()
        
        tabs.append(tab)
        delegate?.tabManager(self, didAddTab: tab)
        
        // Select first, then load - ensures geckoView.session is set before loading
        if select {
            selectTab(tab)
        }
        
        // Load URL after selection so geckoView is connected
        if let url = url {
            tab.load(url)
        }
        
        delegate?.tabManagerDidUpdateTabs(self)
        return tab
    }
    
    // MARK: - Tab Selection
    
    /// Selects a tab
    func selectTab(_ tab: Tab) {
        guard tabs.contains(tab) else { return }
        selectedTab = tab
        delegate?.tabManager(self, didSelectTab: tab)
    }
    
    /// Selects tab at index
    func selectTab(at index: Int) {
        guard tabs.indices.contains(index) else { return }
        selectTab(tabs[index])
    }
    
    // MARK: - Tab Closing
    
    /// Closes a tab
    func closeTab(_ tab: Tab) {
        guard let index = tabs.firstIndex(of: tab) else { return }
        
        tab.close()
        tabs.remove(at: index)
        delegate?.tabManager(self, didRemoveTab: tab)
        
        // If we closed the selected tab, select another one
        if selectedTab == tab {
            if tabs.isEmpty {
                // Create a new tab if all tabs are closed
                createTab(url: Constants.URLs.homepage)
            } else {
                // Select the previous tab or the first one
                let newIndex = min(index, tabs.count - 1)
                selectTab(tabs[newIndex])
            }
        }
        
        delegate?.tabManagerDidUpdateTabs(self)
    }
    
    /// Closes tab at index
    func closeTab(at index: Int) {
        guard tabs.indices.contains(index) else { return }
        closeTab(tabs[index])
    }
    
    /// Closes all tabs except the given one
    func closeAllTabs(except exceptTab: Tab? = nil) {
        let tabsToClose: [Tab]
        if let exceptTab {
            tabsToClose = tabs.filter { $0 != exceptTab }
        } else {
            tabsToClose = tabs
        }
        tabsToClose.forEach { closeTab($0) }
    }
    
    // MARK: - Tab Updates
    
    /// Updates tab info (title, url, screenshot)
    func updateTab(_ tab: Tab, title: String? = nil, url: String? = nil, screenshot: UIImage? = nil) {
        if let title = title {
            tab.title = title
        }
        if let url = url {
            tab.url = url
        }
        if let screenshot = screenshot {
            tab.screenshot = screenshot
        }
        delegate?.tabManagerDidUpdateTabs(self)
    }
    
    /// Updates navigation state for a tab
    func updateNavigation(for tab: Tab, canGoBack: Bool, canGoForward: Bool) {
        tab.canGoBack = canGoBack
        tab.canGoForward = canGoForward
    }
    
    // MARK: - Tab Lookup
    
    /// Finds a tab by its session
    func tab(for session: GeckoSession) -> Tab? {
        tabs.first { $0.session === session }
    }
}
