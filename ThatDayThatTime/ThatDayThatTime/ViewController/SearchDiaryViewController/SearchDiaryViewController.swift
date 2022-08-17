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
        let layout = UICollectionView.diaryLayout(supplementaryItems: [UICollectionView.diaryHeader()])
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .viewBackgroundColor
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TimeDiaryCollectionViewCell.self, forCellWithReuseIdentifier: TimeDiaryCollectionViewCell.identifier)
        collectionView.register(DayDiaryCollectionViewCell.self, forCellWithReuseIdentifier: DayDiaryCollectionViewCell.identifier)
        collectionView.register(DiaryCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DiaryCollectionViewHeader.identifier)
        
        return collectionView
    }()
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    private let viewModel: SearchDiaryViewModel
    
    // MARK: - LifeCycle
    init(viewModel: SearchDiaryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        configureNavigation()
        configureSubViews()
        setConstraintsOfSearchResultCollectionView()
        
        bindingSelf()
        bindingViewModel()
    }
}

// MARK: - Method
extension SearchDiaryViewController {
    private func configureNavigation() {
        navigationItem.titleView = searchBar
    }
    
    private func pushDayDiaryViewController(diary: DayDiary) {
        let viewModel = DayDiaryViewModel(diary: diary)
        let vc = DayDiaryViewController(viewModel: viewModel, isCanEdit: false)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Binding
extension SearchDiaryViewController {
    private func bindingSelf() {
        searchBar.searchTextField.textPublisher
            .sink { [weak self] searchText in
                guard let searchText = searchText else { return }
                self?.viewModel.searchDiary.send(searchText)
            }.store(in: &subscriptions)
    }
    
    private func bindingViewModel() {
        viewModel.updateDiary
            .sink { [weak self] in
                self?.searchResultCollectionView.reloadData()
            }.store(in: &subscriptions)
        
        viewModel.updateFullSizeImage
            .sink { [weak self] image in
                let vc = FullPhotoViewController(image: image)
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true)
            }.store(in: &subscriptions)
    }
    
    private func bindingTimeDiaryImage(
        cell: TimeDiaryCollectionViewCell,
        section: Int,
        index: Int
    ) {
        cell.tapImage = { [weak self] in
            guard let self = self else { return }
            let id = self.viewModel.timeDiary[section][index].id
            self.viewModel.getFullSizeImage(id: id)
        }
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.timeDiary.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section < viewModel.timeDiary.count {
            return viewModel.timeDiary[section].count
        } else {
            return viewModel.dayDiary.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let timeDiaryCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TimeDiaryCollectionViewCell.identifier,
            for: indexPath
        ) as? TimeDiaryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        guard let dayDiaryCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DayDiaryCollectionViewCell.identifier,
            for: indexPath
        ) as? DayDiaryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.section < viewModel.timeDiary.count {
            let diary = viewModel.timeDiary[indexPath.section][indexPath.row]
            
            timeDiaryCell.configureCell(with: diary, isFirst: indexPath.row == 0, isLast: indexPath.row == viewModel.timeDiary[indexPath.section].count - 1)
            
            bindingTimeDiaryImage(cell: timeDiaryCell, section: indexPath.section, index: indexPath.row)
            
            return timeDiaryCell
        } else {
            let diary = viewModel.dayDiary[indexPath.row]
            dayDiaryCell.configureCell(with: diary)
            return dayDiaryCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DiaryCollectionViewHeader.identifier, for: indexPath) as? DiaryCollectionViewHeader else { return UICollectionReusableView() }
            
            if indexPath.section < viewModel.timeDiary.count {
                guard let diary = viewModel.timeDiary[indexPath.section].first else {
                    return header 
                }
                header.configureHeader(diary: diary, section: indexPath.section)
            } else {
                guard let diary = viewModel.dayDiary.first else {
                    return header
                }
                header.configureHeader(diary: diary, section: indexPath.section)
            }
            
            return header
        } else {
            return UICollectionReusableView()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension SearchDiaryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section < viewModel.timeDiary.count {
            return
        } else {
            let diary = viewModel.dayDiary[indexPath.row]
            pushDayDiaryViewController(diary: diary)
        }
    }
}
