// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

// MARK: - TabCardCellDelegate

protocol TabCardCellDelegate: AnyObject {
    func tabCardCellDidTapClose(_ cell: TabCardCell)
}

// MARK: - TabCardCell

/// A card cell representing a tab with screenshot and title
final class TabCardCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    
    static let reuseIdentifier = "TabCardCell"
    
    // MARK: - Properties
    
    weak var delegate: TabCardCellDelegate?
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.Colors.secondaryBackground
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.layer.borderWidth = 0
        view.layer.borderColor = Theme.Colors.selected.cgColor
        return view
    }()
    
    private lazy var screenshotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = Theme.Colors.tertiaryBackground
        return imageView
    }()
    
    private lazy var titleContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.Colors.tertiaryBackground
        return view
    }()
    
    private lazy var faviconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "globe")
        imageView.tintColor = .secondaryLabel
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.Fonts.small
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark", withConfiguration: Theme.Symbols.small), for: .normal)
        button.tintColor = .secondaryLabel
        button.backgroundColor = Theme.Colors.tertiaryBackground.withAlphaComponent(0.8)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
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
        contentView.addSubview(containerView)
        containerView.addSubview(screenshotImageView)
        containerView.addSubview(titleContainer)
        containerView.addSubview(closeButton)
        
        titleContainer.addSubview(faviconImageView)
        titleContainer.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            screenshotImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            screenshotImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            screenshotImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            screenshotImageView.bottomAnchor.constraint(equalTo: titleContainer.topAnchor),
            
            titleContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            titleContainer.heightAnchor.constraint(equalToConstant: 36),
            
            faviconImageView.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 8),
            faviconImageView.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor),
            faviconImageView.widthAnchor.constraint(equalToConstant: 16),
            faviconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: faviconImageView.trailingAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -8),
            titleLabel.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor),
            
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -6),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with tab: Tab, isSelected: Bool) {
        titleLabel.text = tab.displayTitle
        screenshotImageView.image = tab.screenshot
        containerView.layer.borderWidth = isSelected ? 2 : 0
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        delegate?.tabCardCellDidTapClose(self)
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        screenshotImageView.image = nil
        titleLabel.text = nil
        containerView.layer.borderWidth = 0
    }
}
