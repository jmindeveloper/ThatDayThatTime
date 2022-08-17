//
//  YearCalendar.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/17.
//

import UIKit
import Combine
import CombineCocoa

final class YearCalendar: UIView {
    private lazy var calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .viewBackgroundColor
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DTCalendarCell.self, forCellWithReuseIdentifier: DTCalendarCell.identifier)
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        return collectionView
    }()
    
    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.isHidden = true
        
        return view
    }()
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    private let viewModel = YearCalendarViewModel()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureSubViews()
        setConstraintsOfCalendarCollectionView()
        setConstraintsOfBottomLine()
        
        bindingCalendarViewModel()
        
        configureCalendarGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Method
extension YearCalendar {
    func bottomLineHidden() {
        bottomLine.isHidden.toggle()
    }
    
    func updateAfterYear() {
        viewModel.getAfterThreeYear()
    }

    func updateBeforeYear() {
        viewModel.getBeforeThreeYear()
    }
    
    func updateCalendarYear(year: String) {
        var year = year
        year.removeLast()
        viewModel.selectedYear(year: year)
    }
}

// MARK: - Binding
extension YearCalendar {
    private func bindingCalendarViewModel() {
        viewModel.updateYears
            .sink { [weak self] in
                self?.calendarCollectionView.reloadData()
            }.store(in: &subscriptions)
    }
    
    func bindingSelectedYear(completion: @escaping ((String) -> Void)) {
        viewModel.updateCurrentYear
            .sink { date in
                completion(date)
            }.store(in: &subscriptions)
    }
}

// MARK: - ConfigureGesture
extension YearCalendar {
    private func configureCalendarGesture() {
        let leftSwipeGesture = UISwipeGestureRecognizer()
        leftSwipeGesture.direction = .left
        leftSwipeGesture.swipePublisher
            .sink { [weak self] gesture in
                self?.updateAfterYear()
                self?.viewModel.calendarAction = true
            }.store(in: &subscriptions)
        
        let rightSwipeGesture = UISwipeGestureRecognizer()
        rightSwipeGesture.direction = .right
        rightSwipeGesture.swipePublisher
            .sink { [weak self] gesture in
                self?.updateBeforeYear()
                self?.viewModel.calendarAction = true
            }.store(in: &subscriptions)
        
        calendarCollectionView.addGestureRecognizer(leftSwipeGesture)
        calendarCollectionView.addGestureRecognizer(rightSwipeGesture)
    }
}

// MARK: - UI
extension YearCalendar {
    private func configureSubViews() {
        [calendarCollectionView, bottomLine].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }
    
    private func setConstraintsOfCalendarCollectionView() {
        calendarCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setConstraintsOfBottomLine() {
        bottomLine.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(calendarCollectionView.snp.bottom)
            $0.width.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension YearCalendar: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DTCalendarCell.identifier, for: indexPath) as? DTCalendarCell else { return UICollectionViewCell() }
        
        let item = viewModel.years[indexPath.row]
        cell.configureCell(year: item.0, isSelected: item.1)

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension YearCalendar: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectedYear(year: viewModel.years[indexPath.row].0)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension YearCalendar: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset = collectionView.contentInset
        let frame = collectionView.frame
        let width = (frame.width - (inset.left + inset.right)) / 3 - 3
        
        return CGSize(width: width, height: 40)
    }
}
