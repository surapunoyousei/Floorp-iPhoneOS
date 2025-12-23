// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import GeckoView

/// Represents a single browser tab
class Tab: Identifiable {
    let id: UUID
    let session: GeckoSession
    
    var title: String = "New Tab"
    var url: String?
    var screenshot: UIImage?
    var canGoBack: Bool = false
    var canGoForward: Bool = false
    
    init(id: UUID = UUID()) {
        self.id = id
        self.session = GeckoSession()
    }
    
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
}

