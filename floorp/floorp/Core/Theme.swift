// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

/// Unified theme management for Floorp browser
enum Theme {
    
    // MARK: - Colors
    
    enum Colors {
        /// Primary background color
        static let background = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.1, alpha: 1.0)
                : .systemBackground
        }
        
        /// Secondary background color (for containers, cells)
        static let secondaryBackground = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.15, alpha: 1.0)
                : UIColor(white: 0.95, alpha: 1.0)
        }
        
        /// Tertiary background color (for nested elements)
        static let tertiaryBackground = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.12, alpha: 1.0)
                : UIColor(white: 0.92, alpha: 1.0)
        }
        
        /// Border/separator color
        static let separator = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.2, alpha: 1.0)
                : UIColor(white: 0.85, alpha: 1.0)
        }
        
        /// Tab switcher background
        static let tabSwitcherBackground = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.08, alpha: 1.0)
                : UIColor(white: 0.96, alpha: 1.0)
        }
        
        /// Accent color
        static let accent = UIColor.systemBlue
        
        /// Selected/highlighted state
        static let selected = UIColor.systemBlue
    }
    
    // MARK: - Fonts
    
    enum Fonts {
        static let title = UIFont.systemFont(ofSize: 17, weight: .semibold)
        static let body = UIFont.systemFont(ofSize: 15)
        static let caption = UIFont.systemFont(ofSize: 14)
        static let small = UIFont.systemFont(ofSize: 12, weight: .medium)
    }
    
    // MARK: - Symbol Configuration
    
    enum Symbols {
        static let medium = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        static let large = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        static let small = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
    }
}

