//
//  GatherDiaryViewController.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/15.
//

import UIKit
import SnapKit
import Combine
import CombineCocoa

final class GatherDiaryViewController: UIViewController {
    
    // MARK: - ViewProperties
    private lazy var dateLineView: DateLineView = {
        let dateLineView = DateLineView()
        dateLineView.configureDateLabel(date: viewModel.selectedDate())
        
        return dateLineView
    }()
    
    private lazy var diaryCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionView.diaryLayout(supplementaryItems: [UICollectionView.diaryHeader()]))
        collectionView.backgroundColor = .viewBackgroundColor
        collectionView.dataSource = self
        collectionView.register(TimeDiaryCollectionViewCell.self, forCellWithReuseIdentifier: TimeDiaryCollectionViewCell.identifier)
        collectionView.register(DiaryCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DiaryCollectionViewHeader.identifier)
        
        return collectionView
    }()
    
    private lazy var segmentCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionView.segmentedLayout())
        collectionView.backgroundColor = .viewBackgroundColor
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.register(SegmentedCollectionViewCell.self, forCellWithReuseIdentifier: SegmentedCollectionViewCell.identifier)
        
        return collectionView
    }()
    
    // MARK: - Properties
    private let viewModel: GatherDiaryViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    init(viewModel: GatherDiaryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        configureSubViews()
        setConstraintsOfDateLineView()
        setConstraintsOfSegmentedCollectionView()
        setConstraintsOfDiaryCollectionView()
        
        configureDiaryCollectionViewGesture()
        
        bindingViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        viewModel.changeMonth(month: String.getMonth())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.getSelectedSegmentIndex()
    }
}

// MARK: - ConfigureGesture
extension GatherDiaryViewController {
    private func configureDiaryCollectionViewGesture() {
        let leftSwipeGesture = UISwipeGestureRecognizer()
        leftSwipeGesture.direction = .left
        leftSwipeGesture.swipePublisher
            .sink { [weak self] gesture in
                self?.viewModel.moveNextMonth()
            }.store(in: &subscriptions)
        
        let rightSwipeGesture = UISwipeGestureRecognizer()
        rightSwipeGesture.direction = .right
        rightSwipeGesture.swipePublisher
            .sink { [weak self] gesture in
                self?.viewModel.moveBeforeMonth()
            }.store(in: &subscriptions)
        
        diaryCollectionView.addGestureRecognizer(leftSwipeGesture)
        diaryCollectionView.addGestureRecognizer(rightSwipeGesture)
    }
}

// MARK: - Binding
extension GatherDiaryViewController {
    private func bindingViewModel() {
        viewModel.updateDiary
            .sink { [weak self] in
                guard let self = self else { return }
                self.diaryCollectionView.reloadData()
                self.segmentCollectionView.reloadData()
                let date = self.viewModel.selectedDate()
                self.dateLineView.configureDateLabel(date: date)
            }.store(in: &subscriptions)
        
        viewModel.selectedSegment
            .sink { [weak self] index in
                self?.segmentCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
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
extension GatherDiaryViewController {
    private func configureSubViews() {
        [dateLineView, diaryCollectionView, segmentCollectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setConstraintsOfDateLineView() {
        dateLineView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(30)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setConstraintsOfDiaryCollectionView() {
        diaryCollectionView.snp.makeConstraints {
            $0.top.equalTo(dateLineView.snp.bottom).offset(14)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(segmentCollectionView.snp.top)
        }
    }
    
    private func setConstraintsOfSegmentedCollectionView() {
        segmentCollectionView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(60)
        }
    }
}


// MARK: - UICollectionViewDataSource
extension GatherDiaryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView === diaryCollectionView {
            return viewModel.timeDiary.count
        } else if collectionView === segmentCollectionView {
            return 1
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === diaryCollectionView {
            return viewModel.timeDiary[section].count
        } else if collectionView === segmentCollectionView {
            return 12
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === diaryCollectionView {
            guard let diaryCell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeDiaryCollectionViewCell.identifier, for: indexPath) as? TimeDiaryCollectionViewCell else { return UICollectionViewCell() }
            
            let diary = viewModel.timeDiary[indexPath.section][indexPath.row]
            diaryCell.configureCell(with: diary, isFirst: indexPath.row == 0, isLast: indexPath.row == viewModel.timeDiary[indexPath.section].count - 1)
            
            bindingTimeDiaryImage(cell: diaryCell, section: indexPath.section, index: indexPath.row)
            
            return diaryCell
        } else if collectionView === segmentCollectionView {
            guard let segmentedCell = collectionView.dequeueReusableCell(withReuseIdentifier: SegmentedCollectionViewCell.identifier, for: indexPath) as? SegmentedCollectionViewCell else { return UICollectionViewCell() }
            
            segmentedCell.selectedCell(isSelected: viewModel.segmentItems[indexPath.row].1)
            segmentedCell.configureCell(month: viewModel.segmentItems[indexPath.row].0)
            
            return segmentedCell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView === diaryCollectionView {
            if kind == UICollectionView.elementKindSectionHeader {
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DiaryCollectionViewHeader.identifier, for: indexPath) as? DiaryCollectionViewHeader else { return UICollectionReusableView() }
                
                guard var date = viewModel.timeDiary[indexPath.section].first?.date else { return UICollectionReusableView() }
                date = viewModel.sliceDate(date: date)
                header.configureHeader(date: date)
                
                return header
            } else {
                return UICollectionReusableView()
            }
        } else {
            return UICollectionReusableView()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension GatherDiaryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === segmentCollectionView {
            viewModel.changeMonth(month: viewModel.segmentItems[indexPath.row].0)
        }
    }
}
