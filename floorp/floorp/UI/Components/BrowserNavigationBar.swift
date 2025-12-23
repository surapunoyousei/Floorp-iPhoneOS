// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

protocol BrowserNavigationBarDelegate: AnyObject {
    func backButtonTapped()
    func forwardButtonTapped()
    func reloadButtonTapped()
    func stopButtonTapped()
    func urlSubmitted(_ url: String)
}

/// Desktop Floorp-style navigation bar with back/forward/reload buttons and URL field
class BrowserNavigationBar: UIView {
    
    weak var delegate: BrowserNavigationBarDelegate?
    
    // MARK: - UI Components
    
    private lazy var containerStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .secondaryLabel
        button.isEnabled = false
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 36).isActive = true
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return button
    }()
    
    private lazy var forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .secondaryLabel
        button.isEnabled = false
        button.addTarget(self, action: #selector(forwardTapped), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 36).isActive = true
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return button
    }()
    
    private lazy var reloadStopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.tintColor = .secondaryLabel
        button.addTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 36).isActive = true
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return button
    }()
    
    private lazy var urlContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(white: 0.15, alpha: 1.0)
                : UIColor(white: 0.95, alpha: 1.0)
        }
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var searchIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var urlTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Search with Google or enter address"
        field.font = .systemFont(ofSize: 14)
        field.textColor = .label
        field.returnKeyType = .go
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.keyboardType = .webSearch
        field.clearButtonMode = .whileEditing
        field.delegate = self
        return field
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
        
        addSubview(containerStack)
        
        // Add navigation buttons
        containerStack.addArrangedSubview(backButton)
        containerStack.addArrangedSubview(forwardButton)
        containerStack.addArrangedSubview(reloadStopButton)
        
        // Add URL container
        containerStack.addArrangedSubview(urlContainer)
        
        // Setup URL container internals
        urlContainer.addSubview(searchIcon)
        urlContainer.addSubview(urlTextField)
        
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            urlContainer.heightAnchor.constraint(equalToConstant: 36),
            
            searchIcon.leadingAnchor.constraint(equalTo: urlContainer.leadingAnchor, constant: 10),
            searchIcon.centerYAnchor.constraint(equalTo: urlContainer.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 16),
            searchIcon.heightAnchor.constraint(equalToConstant: 16),
            
            urlTextField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 8),
            urlTextField.trailingAnchor.constraint(equalTo: urlContainer.trailingAnchor, constant: -10),
            urlTextField.centerYAnchor.constraint(equalTo: urlContainer.centerYAnchor),
        ])
    }
    
    // MARK: - Public Methods
    
    func setURL(_ url: String?) {
        urlTextField.text = url
    }
    
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
        
        if isLoading {
            reloadStopButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            reloadStopButton.removeTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
            reloadStopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
        } else {
            reloadStopButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
            reloadStopButton.removeTarget(self, action: #selector(stopTapped), for: .touchUpInside)
            reloadStopButton.addTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
        }
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        urlTextField.resignFirstResponder()
        return super.resignFirstResponder()
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
    
    // MARK: - URL Handling
    
    private func isURL(_ input: String) -> Bool {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            return true
        }
        if trimmed.hasPrefix("about:") || trimmed.hasPrefix("file://") {
            return true
        }
        if trimmed.contains(".") && !trimmed.contains(" ") {
            return true
        }
        return false
    }
    
    private func inputToURL(_ input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        if isURL(trimmed) {
            if !trimmed.contains("://") {
                return "https://\(trimmed)"
            }
            return trimmed
        } else {
            let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "https://www.google.com/search?q=\(encoded)"
        }
    }
}

// MARK: - UITextFieldDelegate
extension BrowserNavigationBar: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return true }
        
        textField.resignFirstResponder()
        
        if let url = inputToURL(text) {
            delegate?.urlSubmitted(url)
        }
        return true
    }
}

