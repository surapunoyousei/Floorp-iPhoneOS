// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

protocol BrowserToolbarDelegate: AnyObject {
    func backButtonClicked()
    func forwardButtonClicked()
    func reloadButtonClicked()
    func stopButtonClicked()
}

class BrowserToolbar: UIToolbar {
    weak var toolbarDelegate: BrowserToolbarDelegate?
    private var reloadStopButton: UIBarButtonItem!
    private var backButton: UIBarButtonItem!
    private var forwardButton: UIBarButtonItem!

    // By default the state is set to reload. We save the state to avoid setting the toolbar
    // button multiple times when a page load is in progress
    private var isLoading: Bool = false

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupToolbar()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupToolbar() {
        // Configure toolbar appearance
        isTranslucent = false
        barTintColor = .systemBackground
        backgroundColor = .systemBackground
        
        // Set standard appearance
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        standardAppearance = appearance
        if #available(iOS 15.0, *) {
            scrollEdgeAppearance = appearance
        }
        
        backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonClicked))
        backButton.isEnabled = false
        backButton.tintColor = .label

        forwardButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.right"),
            style: .plain,
            target: self,
            action: #selector(forwardButtonClicked))
        forwardButton.isEnabled = false
        forwardButton.tintColor = .label

        reloadStopButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(reloadButtonClicked))
        reloadStopButton.tintColor = .label

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let items: [UIBarButtonItem] = [
            flexibleSpace,
            backButton,
            flexibleSpace,
            forwardButton,
            flexibleSpace,
            reloadStopButton,
            flexibleSpace
        ]
        setItems(items, animated: false)
    }

    // MARK: - Button states

    func updateReloadStopButton(isLoading: Bool) {
        guard isLoading != self.isLoading else { return }
        self.isLoading = isLoading
        
        if isLoading {
            reloadStopButton.image = UIImage(systemName: "xmark")
            reloadStopButton.action = #selector(stopButtonClicked)
        } else {
            reloadStopButton.image = UIImage(systemName: "arrow.clockwise")
            reloadStopButton.action = #selector(reloadButtonClicked)
        }
    }

    func updateBackButton(canGoBack: Bool) {
        backButton.isEnabled = canGoBack
    }

    func updateForwardButton(canGoForward: Bool) {
        forwardButton.isEnabled = canGoForward
    }

    // MARK: - Actions

    @objc private func backButtonClicked() {
        toolbarDelegate?.backButtonClicked()
    }

    @objc private func forwardButtonClicked() {
        toolbarDelegate?.forwardButtonClicked()
    }

    @objc private func reloadButtonClicked() {
        toolbarDelegate?.reloadButtonClicked()
    }

    @objc private func stopButtonClicked() {
        toolbarDelegate?.stopButtonClicked()
    }
}

