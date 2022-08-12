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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateLineViewTapped))
        view.addGestureRecognizer(tapGesture)
        
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
    
    // MARK: - Properties
    private var calendarHidden = true
    private var subscriptions = Set<AnyCancellable>()
    private let viewModel = TimeDiaryViewModel()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        configureNavigation()
        configureSubViews()
        setConstraintsOfDateLineView()
        setConstraintsOfCalendar()
        setConstraintsOfTimeDiaryCollectionView()
        
        bindingViewModel()
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
        let vc = WritingTimeDiaryViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        
        self.present(vc, animated: true)
    }
}

// MARK: - TargetMethod
extension TimeDiaryViewController {
    @objc private func dateLineViewTapped() {
        calendarHidden.toggle()
        calendar.snp.updateConstraints {
            $0.height.equalTo(calendarHidden ? 0 : 300)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.calendar.bottomLineHidden()
        }
    }
}

// MARK: - Binding
extension TimeDiaryViewController {
    private func bindingViewModel() {
        viewModel.updateDiarys
            .sink { [weak self] in
                self?.timeDiaryCollectionView.reloadData()
            }.store(in: &subscriptions)
    }
}

// MARK: - UI
extension TimeDiaryViewController {
    private func configureSubViews() {
        [dateLineView, calendar, timeDiaryCollectionView].forEach {
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
        let image = UIImage.getImage(with: timeDiary)
        cell.configureCell(with: timeDiary, image: image)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TimeDiaryViewController: UICollectionViewDelegate {
    
}