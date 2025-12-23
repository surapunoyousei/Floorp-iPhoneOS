// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

/// Centralized constants for the Floorp browser
enum Constants {
    
    // MARK: - URLs
    
    enum URLs {
        static let homepage = "https://floorp.app"
        static let searchEngine = "https://www.google.com/search?q="
    }
    
    // MARK: - Layout
    
    enum Layout {
        static let urlBarHeight: CGFloat = 52
        static let bottomBarHeight: CGFloat = 50
        static let progressBarHeight: CGFloat = 2
        static let cornerRadius: CGFloat = 8
        static let buttonSize: CGFloat = 44
        static let iconSize: CGFloat = 18
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 8
    }
    
    // MARK: - Animation
    
    enum Animation {
        static let defaultDuration: TimeInterval = 0.3
        static let screenshotDelay: TimeInterval = 0.5
    }
    
    // MARK: - Tab
    
    enum Tab {
        static let defaultTitle = "New Tab"
        static let cardAspectRatio: CGFloat = 0.65
        static let gridColumns = 2
    }
}

