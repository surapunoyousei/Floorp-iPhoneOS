// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

protocol BrowserURLBarDelegate: AnyObject {
    func urlSubmitted(_ url: String)
}

/// Desktop Floorp-style URL bar
class BrowserURLBar: UIView {
    
    weak var delegate: BrowserURLBarDelegate?
    
    // MARK: - UI Components
    
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
        field.font = .systemFont(ofSize: 15)
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
        backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(white: 0.1, alpha: 1.0)
                : .systemBackground
        }
        
        addSubview(urlContainer)
        urlContainer.addSubview(searchIcon)
        urlContainer.addSubview(urlTextField)
        
        NSLayoutConstraint.activate([
            urlContainer.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            urlContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            urlContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            urlContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
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
        return urlTextField.text
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
    
    func inputToURL(_ input: String) -> String? {
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

