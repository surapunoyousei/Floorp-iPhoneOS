// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

protocol TabSwitcherDelegate: AnyObject {
    func tabSwitcher(_ switcher: TabSwitcherViewController, didSelectTab tab: Tab)
    func tabSwitcher(_ switcher: TabSwitcherViewController, didCloseTab tab: Tab)
    func tabSwitcherDidRequestNewTab(_ switcher: TabSwitcherViewController)
    func tabSwitcherDidRequestDismiss(_ switcher: TabSwitcherViewController)
}

/// Tab switcher with 2x2 grid layout showing tab cards with screenshots
class TabSwitcherViewController: UIViewController {
    
    weak var delegate: TabSwitcherDelegate?
    
    private let tabManager = TabManager.shared
    
    // MARK: - UI Components
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tabs"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private lazy var tabCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var newTabButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(newTabTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(TabCardCell.self, forCellWithReuseIdentifier: TabCardCell.reuseIdentifier)
        cv.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        return cv
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = UIColor(white: 0.08, alpha: 1.0)
        
        setupUI()
        updateTabCount()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        updateTabCount()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(headerView)
        view.addSubview(collectionView)
        
        headerView.addSubview(newTabButton)
        headerView.addSubview(titleLabel)
        headerView.addSubview(tabCountLabel)
        headerView.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),
            
            newTabButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            newTabButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            newTabButton.widthAnchor.constraint(equalToConstant: 44),
            newTabButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: -8),
            
            tabCountLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            tabCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            
            doneButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            doneButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        // 2x2 grid layout
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.65) // Aspect ratio for cards
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func updateTabCount() {
        let count = tabManager.tabCount
        tabCountLabel.text = "\(count) tab\(count == 1 ? "" : "s")"
    }
    
    // MARK: - Actions
    
    @objc private func doneTapped() {
        delegate?.tabSwitcherDidRequestDismiss(self)
    }
    
    @objc private func newTabTapped() {
        delegate?.tabSwitcherDidRequestNewTab(self)
    }
}

// MARK: - UICollectionViewDataSource
extension TabSwitcherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabManager.tabs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TabCardCell.reuseIdentifier,
            for: indexPath
        ) as! TabCardCell
        
        let tab = tabManager.tabs[indexPath.item]
        let isSelected = tabManager.selectedTab?.id == tab.id
        cell.configure(with: tab, isSelected: isSelected)
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TabSwitcherViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tab = tabManager.tabs[indexPath.item]
        delegate?.tabSwitcher(self, didSelectTab: tab)
    }
}

// MARK: - TabCardCellDelegate
extension TabSwitcherViewController: TabCardCellDelegate {
    func tabCardCellDidTapClose(_ cell: TabCardCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        // Get tab before any modifications
        guard indexPath.item < tabManager.tabs.count else { return }
        let tab = tabManager.tabs[indexPath.item]
        
        // First close the tab (updates data source)
        delegate?.tabSwitcher(self, didCloseTab: tab)
        
        // Then reload collection view to sync with data source
        collectionView.reloadData()
        updateTabCount()
    }
}

