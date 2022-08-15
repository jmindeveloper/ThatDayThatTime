//
//  SearchDiaryViewController.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/15.
//

import UIKit
import SnapKit
import Combine
import CombineCocoa

final class SearchDiaryViewController: UIViewController {
    
    // MARK: - ViewProperties
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchTextField.leftView = nil
        searchBar.placeholder = "기록을 검색하세요"
        searchBar.autocapitalizationType = .sentences
        searchBar.autocorrectionType = .no
        searchBar.spellCheckingType = .no
        searchBar.returnKeyType = .default
        searchBar.searchTextField.borderStyle = .none
        searchBar.searchTextField.backgroundColor = .viewBackgroundColor
        searchBar.searchTextField.textColor = .black
        
        return searchBar
    }()
    
    private lazy var searchResultCollectionView: UICollectionView = {
        let layout = UICollectionView.diaryLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .viewBackgroundColor
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        configureNavigation()
        configureSubViews()
        setConstraintsOfSearchResultCollectionView()
    }
}

// MARK: - Method
extension SearchDiaryViewController {
    private func configureNavigation() {
        navigationItem.titleView = searchBar
    }
}

// MARK: - UI
extension SearchDiaryViewController {
    private func configureSubViews() {
        searchResultCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchResultCollectionView)
    }
    
    private func setConstraintsOfSearchResultCollectionView() {
        searchResultCollectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension SearchDiaryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate
extension SearchDiaryViewController: UICollectionViewDelegate {
    
}
