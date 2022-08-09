//
//  DTCalendar.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import UIKit
import Combine

// TODO: - ViewModel
final class DTCalendar: UIView {
    
    private lazy var calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
    let viewModel = DTCalendarViewModel()
    private var subscriptios = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureSubViews()
        setConstraintsOfCalendarCollectionView()
        setConstraintsOfBottomLine()
        viewModel.updateCalendarRequest()
        bindingCalendarViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Method
extension DTCalendar {
    func reloadCalendar() {
        calendarCollectionView.reloadData()
    }
    
    func bottomLineHidden() {
        bottomLine.isHidden.toggle()
    }
}

// MARK: - Binding
extension DTCalendar {
    private func bindingCalendarViewModel() {
        viewModel.updateCalendar
            .sink { [weak self] in
                self?.calendarCollectionView.reloadData()
            }.store(in: &subscriptios)
    }
    
    func bindingSelectedDate(completion: @escaping ((String) -> Void)) {
        viewModel.updateCurrentDate
            .sink { date in
                completion(date)
            }.store(in: &subscriptios)
    }
}

// MARK: - UI
extension DTCalendar {
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
            $0.bottom.equalTo(calendarCollectionView.snp.bottom)
            $0.width.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension DTCalendar: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 7
        case 1: return 42
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DTCalendarCell.identifier, for: indexPath) as? DTCalendarCell else { return UICollectionViewCell() }
        
        switch indexPath.section {
        case 0:
            cell.configureCell(weak: viewModel.week[indexPath.row])
        case 1:
            cell.configureCell(day: viewModel.days[indexPath.row])
        default: break
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension DTCalendar: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {        
            viewModel.selectedDay(index: indexPath.row)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DTCalendar: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset = collectionView.contentInset
        let frame = collectionView.frame
        let width = (frame.width - (inset.left + inset.right)) / 7 - 3
        // TODO: - 300 동적으로 바꾸기
        let height = (300 - (inset.top + inset.bottom)) / 7 - 3
        
        return CGSize(width: width, height: height)
    }
}
