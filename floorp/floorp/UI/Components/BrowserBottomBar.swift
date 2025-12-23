// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

protocol BrowserBottomBarDelegate: AnyObject {
    func backButtonTapped()
    func forwardButtonTapped()
    func reloadButtonTapped()
    func stopButtonTapped()
    func homeButtonTapped()
    func tabsButtonTapped()
}

/// Bottom navigation bar with browser controls
class BrowserBottomBar: UIView {
    
    weak var delegate: BrowserBottomBarDelegate?
    
    // MARK: - UI Components
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    
    private lazy var backButton: UIButton = createButton(
        systemName: "chevron.left",
        action: #selector(backTapped)
    )
    
    private lazy var forwardButton: UIButton = createButton(
        systemName: "chevron.right",
        action: #selector(forwardTapped)
    )
    
    private lazy var reloadStopButton: UIButton = createButton(
        systemName: "arrow.clockwise",
        action: #selector(reloadTapped)
    )
    
    private lazy var homeButton: UIButton = createButton(
        systemName: "house",
        action: #selector(homeTapped)
    )
    
    private lazy var tabsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Create tabs icon with badge-like appearance
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: "square.on.square", withConfiguration: config), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(tabsTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44),
        ])
        return button
    }()
    
    private var isLoading = false
    
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
        backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(white: 0.1, alpha: 1.0)
                : .systemBackground
        }
        
        // Add top border
        let topBorder = UIView()
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        topBorder.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(white: 0.2, alpha: 1.0)
                : UIColor(white: 0.85, alpha: 1.0)
        }
        addSubview(topBorder)
        
        addSubview(stackView)
        
        // Add buttons
        stackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(forwardButton)
        stackView.addArrangedSubview(homeButton)
        stackView.addArrangedSubview(reloadStopButton)
        stackView.addArrangedSubview(tabsButton)
        
        // Initial state
        backButton.isEnabled = false
        backButton.tintColor = .secondaryLabel
        forwardButton.isEnabled = false
        forwardButton.tintColor = .secondaryLabel
        
        NSLayoutConstraint.activate([
            topBorder.topAnchor.constraint(equalTo: topAnchor),
            topBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
            topBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
            topBorder.heightAnchor.constraint(equalToConstant: 0.5),
            
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }
    
    private func createButton(systemName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: action, for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44),
        ])
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
        
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        
        if isLoading {
            reloadStopButton.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
            reloadStopButton.removeTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
            reloadStopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
        } else {
            reloadStopButton.setImage(UIImage(systemName: "arrow.clockwise", withConfiguration: config), for: .normal)
            reloadStopButton.removeTarget(self, action: #selector(stopTapped), for: .touchUpInside)
            reloadStopButton.addTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
        }
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        delegate?.backButtonTapped()
    }
    
    @objc private func forwardTapped() {
        delegate?.forwardButtonTapped()
    }
    
    @objc private func reloadTapped() {
        delegate?.reloadButtonTapped()
    }
    
    @objc private func stopTapped() {
        delegate?.stopButtonTapped()
    }
    
    @objc private func homeTapped() {
        delegate?.homeButtonTapped()
    }
    
    @objc private func tabsTapped() {
        delegate?.tabsButtonTapped()
    }
}

