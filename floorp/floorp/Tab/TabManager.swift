// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import GeckoView

protocol TabManagerDelegate: AnyObject {
    func tabManager(_ manager: TabManager, didSelectTab tab: Tab)
    func tabManager(_ manager: TabManager, didAddTab tab: Tab)
    func tabManager(_ manager: TabManager, didRemoveTab tab: Tab)
    func tabManagerDidUpdateTabs(_ manager: TabManager)
}

/// Manages all browser tabs
class TabManager {
    
    static let shared = TabManager()
    
    weak var delegate: TabManagerDelegate?
    
    private(set) var tabs: [Tab] = []
    private(set) var selectedTab: Tab?
    
    var selectedIndex: Int? {
        guard let tab = selectedTab else { return nil }
        return tabs.firstIndex(where: { $0.id == tab.id })
    }
    
    var tabCount: Int {
        return tabs.count
    }
    
    private init() {}
    
    // MARK: - Tab Management
    
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
    
    /// Selects a tab
    func selectTab(_ tab: Tab) {
        guard tabs.contains(where: { $0.id == tab.id }) else { return }
        selectedTab = tab
        delegate?.tabManager(self, didSelectTab: tab)
    }
    
    /// Selects tab at index
    func selectTab(at index: Int) {
        guard index >= 0 && index < tabs.count else { return }
        selectTab(tabs[index])
    }
    
    /// Closes a tab
    func closeTab(_ tab: Tab) {
        guard let index = tabs.firstIndex(where: { $0.id == tab.id }) else { return }
        
        tab.close()
        tabs.remove(at: index)
        delegate?.tabManager(self, didRemoveTab: tab)
        
        // If we closed the selected tab, select another one
        if selectedTab?.id == tab.id {
            if tabs.isEmpty {
                // Create a new tab if all tabs are closed
                createTab(url: "https://floorp.app")
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
        guard index >= 0 && index < tabs.count else { return }
        closeTab(tabs[index])
    }
    
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
    func updateTabNavigation(_ tab: Tab, canGoBack: Bool, canGoForward: Bool) {
        tab.canGoBack = canGoBack
        tab.canGoForward = canGoForward
    }
}

