// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

// MARK: - BrowserURLBarDelegate

protocol BrowserURLBarDelegate: AnyObject {
    func urlSubmitted(_ url: String)
}

// MARK: - BrowserURLBar

/// Desktop Floorp-style URL bar
final class BrowserURLBar: UIView {
    
    // MARK: - Properties
    
    weak var delegate: BrowserURLBarDelegate?
    
    // MARK: - UI Components
    
    private lazy var urlContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.Colors.secondaryBackground
        view.layer.cornerRadius = Constants.Layout.cornerRadius
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
        field.font = Theme.Fonts.body
        field.textColor = .label
        field.returnKeyType = .go
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.keyboardType = .webSearch
        field.clearButtonMode = .whileEditing
        field.delegate = self
        return field
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
        
        addSubview(urlContainer)
        urlContainer.addSubview(searchIcon)
        urlContainer.addSubview(urlTextField)
        
        NSLayoutConstraint.activate([
            urlContainer.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Layout.verticalPadding),
            urlContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Layout.horizontalPadding),
            urlContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Layout.horizontalPadding),
            urlContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.Layout.verticalPadding),
            
            searchIcon.leadingAnchor.constraint(equalTo: urlContainer.leadingAnchor, constant: 12),
            searchIcon.centerYAnchor.constraint(equalTo: urlContainer.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 16),
            searchIcon.heightAnchor.constraint(equalToConstant: 16),
            
            urlTextField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 8),
            urlTextField.trailingAnchor.constraint(equalTo: urlContainer.trailingAnchor, constant: -12),
            urlTextField.centerYAnchor.constraint(equalTo: urlContainer.centerYAnchor),
        ])
    }
    
    // MARK: - Public Methods
    
    func setURL(_ url: String?) {
        urlTextField.text = url
    }
    
    func getURL() -> String? {
        urlTextField.text
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        urlTextField.resignFirstResponder()
        return super.resignFirstResponder()
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        urlTextField.becomeFirstResponder()
        return super.becomeFirstResponder()
    }
}

// MARK: - URL Handling

private extension BrowserURLBar {
    
    func isURL(_ input: String) -> Bool {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Check for explicit protocols
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") ||
           trimmed.hasPrefix("about:") || trimmed.hasPrefix("file://") {
            return true
        }
        
        // Check for domain-like patterns
        if trimmed.contains(".") && !trimmed.contains(" ") {
            return true
        }
        
        return false
    }
    
    func inputToURL(_ input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        if isURL(trimmed) {
            return trimmed.contains("://") ? trimmed : "https://\(trimmed)"
        } else {
            let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return Constants.URLs.searchEngine + encoded
        }
    }
}

// MARK: - UITextFieldDelegate

extension BrowserURLBar: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return true }
        
        textField.resignFirstResponder()
        
        if let url = inputToURL(text) {
            delegate?.urlSubmitted(url)
        }
        
        return true
    }
}
