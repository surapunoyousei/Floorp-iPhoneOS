// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import GeckoView

/// Represents a single browser tab
final class Tab: Identifiable, Equatable, Hashable {
    
    // MARK: - Properties
    
    let id: UUID
    let session: GeckoSession
    
    var title: String = Constants.Tab.defaultTitle
    var url: String?
    var screenshot: UIImage?
    var canGoBack: Bool = false
    var canGoForward: Bool = false
    
    // MARK: - Computed Properties
    
    var displayTitle: String {
        if title.isEmpty || title == Constants.Tab.defaultTitle {
            return url?.replacingOccurrences(of: "https://", with: "")
                       .replacingOccurrences(of: "http://", with: "")
                       .components(separatedBy: "/").first ?? Constants.Tab.defaultTitle
        }
        return title
    }
    
    // MARK: - Init
    
    init(id: UUID = UUID()) {
        self.id = id
        self.session = GeckoSession()
    }
    
    // MARK: - Session Management
    
    func open() {
        session.open()
    }
    
    func close() {
        session.close()
    }
    
    func load(_ url: String) {
        self.url = url
        session.load(url)
    }
    
    func reload() {
        session.reload()
    }
    
    func stop() {
        session.stop()
    }
    
    func goBack() {
        session.goBack()
    }
    
    func goForward() {
        session.goForward()
    }
    
    // MARK: - Equatable & Hashable
    
    static func == (lhs: Tab, rhs: Tab) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
