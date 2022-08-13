//
//  TimeDiaryViewController.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import UIKit
import SnapKit
import Combine
import CombineCocoa

final class TimeDiaryViewController: UIViewController {
    
    // MARK: - ViewProperties
    private lazy var dateLineView: DateLineView = {
        let view = DateLineView()
        
        return view
    }()
    
    private lazy var calendar: DTCalendar = {
        let calendar = DTCalendar()
        calendar.bindingSelectedDate { [weak self] date in
            self?.dateLineView.configureDateLabel(date: date)
            self?.viewModel.changeDate(date: date)
        }
        
        return calendar
    }()
    
    private lazy var timeDiaryCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: timeDiaryCollectionViewLayout())
        collectionView.backgroundColor = .viewBackgroundColor
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TimeDiaryCollectionViewCell.self, forCellWithReuseIdentifier: TimeDiaryCollectionViewCell.identifier)
        
        return collectionView
    }()
    
    private let noTimeDiaryLabel: UILabel = {
        let label = UILabel()
        label.text = "작성된 시간일기가 없습니다."
        label.textColor = .darkGray
        label.textAlignment = .center
        
        return label
    }()
    
    // MARK: - Properties
    private var calendarHidden = true
    private var subscriptions = Set<AnyCancellable>()
    private let viewModel: TimeDiaryViewModel
    
    // MARK: - LifeCycle
    init(viewModel: TimeDiaryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindingViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        configureNavigation()
        configureSubViews()
        setConstraintsOfDateLineView()
        setConstraintsOfCalendar()
        setConstraintsOfTimeDiaryCollectionView()
        setConstraintsOfNoTimeDiaryLabel()
        
        configureDateLineViewGesture()
        configureTimeDiaryCollectionViewGesture()
    }
}

// MARK: - Method
extension TimeDiaryViewController {
    private func configureNavigation() {
        let addTimeDiaryButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: nil
         )
        addTimeDiaryButton.tapPublisher
            .sink { [weak self] in
                self?.pushWritingTimeDiaryViewController()
            }.store(in: &subscriptions)
        
        navigationItem.rightBarButtonItem = addTimeDiaryButton
    }
    
    private func pushWritingTimeDiaryViewController() {
        let writingTimeDiaryViewModel = WritingTimeDiaryViewModel(
            date: viewModel.date,
            coreDataManager: viewModel.coreDataManager
        )
        
        let vc = WritingTimeDiaryViewController(viewModel: writingTimeDiaryViewModel)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        
        self.present(vc, animated: true)
    }
    
    private func pushWritingTimeDiaryViewController(with diary: TimeDiary) {
        let writingTimeDiaryViewModel = WritingTimeDiaryViewModel(
            timeDiary: diary,
            coreDataManager: viewModel.coreDataManager
        )
        
        let vc = WritingTimeDiaryViewController(viewModel: writingTimeDiaryViewModel)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        
        self.present(vc, animated: true)
    }
    
    private func presentDeleteAlert(_ index: Int) {
        let alert = AlertManager(message: "일기를 정말 삭제하시겠습니까?").createAlert()
            .addAction(actionTytle: "확인", style: .default) { [weak self] in
                self?.viewModel.deleteDiary(index: index)
            }
            .addAction(actionTytle: "취소", style: .cancel)
        
        present(alert, animated: true)
    }
}

// MARK: - ConfigureGesture
extension TimeDiaryViewController {
    private func configureDateLineViewGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.tapPublisher
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.calendarHidden.toggle()
                self.calendar.snp.updateConstraints {
                    $0.height.equalTo(self.calendarHidden ? 0 : 300)
                }
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                    self.view.layoutIfNeeded()
                } completion: { _ in
                    self.calendar.bottomLineHidden()
                }
            }.store(in: &subscriptions)
        
        dateLineView.addGestureRecognizer(tapGesture)
    }
    
    private func configureTimeDiaryCollectionViewGesture() {
        let leftSwipeGesture = UISwipeGestureRecognizer()
        leftSwipeGesture.direction = .left
        leftSwipeGesture.swipePublisher
            .sink { [weak self] gesture in
                self?.calendar.updateNextDay()
            }.store(in: &subscriptions)
        
        let rightSwipeGesture = UISwipeGestureRecognizer()
        rightSwipeGesture.direction = .right
        rightSwipeGesture.swipePublisher
            .sink { [weak self] gesture in
                self?.calendar.updateBeforeDay()
            }.store(in: &subscriptions)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: nil)
        longPressGesture.minimumPressDuration = 0.35
        longPressGesture.longPressPublisher
            .sink { [weak self] gesture in
                guard let self = self else { return }
                if gesture.state == .began {
                    let pressPoint = gesture.location(in: self.timeDiaryCollectionView)
                    guard let indexPath = self.timeDiaryCollectionView.indexPathForItem(
                        at: pressPoint
                    ) else { return }
                    self.presentDeleteAlert(indexPath.row)
                }
            }.store(in: &subscriptions)
        
        timeDiaryCollectionView.addGestureRecognizer(leftSwipeGesture)
        timeDiaryCollectionView.addGestureRecognizer(rightSwipeGesture)
        timeDiaryCollectionView.addGestureRecognizer(longPressGesture)
    }
}

// MARK: - Binding
extension TimeDiaryViewController {
    private func bindingViewModel() {
        viewModel.updateDiarys
            .sink { [weak self] in
                guard let self = self else { return }
                self.noTimeDiaryLabel.isHidden =
                self.viewModel.diarys.isEmpty ? false : true
                self.timeDiaryCollectionView.reloadSections(IndexSet(0...0))
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
        index: Int
    ) {
        cell.tapImage = { [weak self] in
            guard let self = self else { return }
            let id = self.viewModel.diarys[index].id
            self.viewModel.getFullSizeImage(id: id)
        }
    }
}

// MARK: - UI
extension TimeDiaryViewController {
    private func configureSubViews() {
        [dateLineView, calendar, timeDiaryCollectionView,
         noTimeDiaryLabel].forEach {
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
    
    private func setConstraintsOfCalendar() {
        calendar.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.top.equalTo(dateLineView.snp.bottom)
            $0.leading.equalToSuperview()
            $0.height.equalTo(0)
        }
    }
    
    private func setConstraintsOfTimeDiaryCollectionView() {
        timeDiaryCollectionView.snp.makeConstraints {
            $0.top.equalTo(calendar.snp.bottom).offset(3)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func setConstraintsOfNoTimeDiaryLabel() {
        noTimeDiaryLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(calendar.snp.bottom).offset(15)
            $0.width.equalToSuperview()
        }
    }
}

// MARK: - CompositionalLayout
extension TimeDiaryViewController {
    private func timeDiaryCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - UICollectionViewDataSource
extension TimeDiaryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.diarys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeDiaryCollectionViewCell.identifier, for: indexPath) as? TimeDiaryCollectionViewCell else { return UICollectionViewCell() }
        
        let timeDiary = viewModel.diarys[indexPath.row]
        
        cell.configureCell(
            with: timeDiary,
            isFirst: indexPath.row == 0,
            isLast: indexPath.row == viewModel.diarys.count - 1
        )
        bindingTimeDiaryImage(cell: cell, index: indexPath.row)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TimeDiaryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let diary = viewModel.diarys[indexPath.row]
        pushWritingTimeDiaryViewController(with: diary)
    }
}
