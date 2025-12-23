// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

// MARK: - BrowserBottomBarDelegate

protocol BrowserBottomBarDelegate: AnyObject {
    func backButtonTapped()
    func forwardButtonTapped()
    func reloadButtonTapped()
    func stopButtonTapped()
    func homeButtonTapped()
    func tabsButtonTapped()
}

// MARK: - BrowserBottomBar

/// Bottom navigation bar with browser controls
final class BrowserBottomBar: UIView {
    
    // MARK: - Properties
    
    weak var delegate: BrowserBottomBarDelegate?
    private var isLoading = false
    
    // MARK: - UI Components
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    
    private lazy var backButton = createButton(systemName: "chevron.left", action: #selector(backTapped))
    private lazy var forwardButton = createButton(systemName: "chevron.right", action: #selector(forwardTapped))
    private lazy var homeButton = createButton(systemName: "house", action: #selector(homeTapped))
    private lazy var reloadStopButton = createButton(systemName: "arrow.clockwise", action: #selector(reloadTapped))
    private lazy var tabsButton = createButton(systemName: "square.on.square", action: #selector(tabsTapped))
    
    private lazy var topBorder: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.Colors.separator
        return view
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = Theme.Colors.background
        
        addSubview(topBorder)
        addSubview(stackView)
        
        [backButton, forwardButton, homeButton, reloadStopButton, tabsButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        // Initial disabled state
        updateBackButton(canGoBack: false)
        updateForwardButton(canGoForward: false)
        
        NSLayoutConstraint.activate([
            topBorder.topAnchor.constraint(equalTo: topAnchor),
            topBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
            topBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
            topBorder.heightAnchor.constraint(equalToConstant: 0.5),
            
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func createButton(systemName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: systemName, withConfiguration: Theme.Symbols.medium), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: action, for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: Constants.Layout.buttonSize).isActive = true
        return button
    }
    
    // MARK: - Public Methods
    
    func updateBackButton(canGoBack: Bool) {
        backButton.isEnabled = canGoBack
        backButton.tintColor = canGoBack ? .label : .secondaryLabel
    }
    
    func updateForwardButton(canGoForward: Bool) {
        forwardButton.isEnabled = canGoForward
        forwardButton.tintColor = canGoForward ? .label : .secondaryLabel
    }
    
    func updateLoadingState(isLoading: Bool) {
        guard self.isLoading != isLoading else { return }
        self.isLoading = isLoading
        
        let iconName = isLoading ? "xmark" : "arrow.clockwise"
        let action = isLoading ? #selector(stopTapped) : #selector(reloadTapped)
        let previousAction = isLoading ? #selector(reloadTapped) : #selector(stopTapped)
        
        reloadStopButton.setImage(UIImage(systemName: iconName, withConfiguration: Theme.Symbols.medium), for: .normal)
        reloadStopButton.removeTarget(self, action: previousAction, for: .touchUpInside)
        reloadStopButton.addTarget(self, action: action, for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() { delegate?.backButtonTapped() }
    @objc private func forwardTapped() { delegate?.forwardButtonTapped() }
    @objc private func homeTapped() { delegate?.homeButtonTapped() }
    @objc private func reloadTapped() { delegate?.reloadButtonTapped() }
    @objc private func stopTapped() { delegate?.stopButtonTapped() }
    @objc private func tabsTapped() { delegate?.tabsButtonTapped() }
}
