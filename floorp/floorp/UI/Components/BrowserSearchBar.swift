// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

protocol BrowserSearchBarDelegate: AnyObject {
    func searchBarDidSubmit(text: String)
}

class BrowserSearchBar: UIView {
    private weak var delegate: BrowserSearchBarDelegate?

    private lazy var searchBar: UISearchBar = .build { bar in
        bar.searchBarStyle = .minimal
        bar.backgroundColor = .systemBackground
        bar.placeholder = "URLまたは検索語を入力"
    }

    // Be lenient about what is classified as potentially a URL.
    // Matches patterns like: example.com, http://example.com, about:config, etc.
    private lazy var isURLPattern = try! Regex(
        "^\\s*(\\w+-+)*[\\w\\[]+(://[/]*|:|\\.)(\\w+-+)*[\\w\\[:]+([\\S&&[^\\w-]]\\S*)?\\s*$"
    )

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSearchBar()
        backgroundColor = .systemBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(delegate: BrowserSearchBarDelegate) {
        self.delegate = delegate
        self.searchBar.delegate = self
    }

    func setSearchBarText(_ text: String?) {
        searchBar.text = text
    }

    func getSearchBarText() -> String? {
        return searchBar.text
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        searchBar.becomeFirstResponder()
        return super.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        searchBar.resignFirstResponder()
        return super.resignFirstResponder()
    }

    // MARK: - URL Detection

    /// Returns true if the input looks like a URL
    func isURL(_ input: String) -> Bool {
        return (try? isURLPattern.wholeMatch(in: input)) != nil
    }

    /// Converts input to a URL string (either directly if URL, or as a search query)
    func inputToURL(_ input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if isURL(trimmed) {
            // Add https:// if no scheme is present
            if !trimmed.contains("://") && !trimmed.contains(":") {
                return "https://\(trimmed)"
            }
            return trimmed
        } else {
            // Convert to search query
            let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "https://www.google.com/search?q=\(encoded)"
        }
    }

    // MARK: - Private

    private func setupSearchBar() {
        addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

// MARK: - UISearchBarDelegate
extension BrowserSearchBar: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else { return }
        delegate?.searchBarDidSubmit(text: text)
    }
}

