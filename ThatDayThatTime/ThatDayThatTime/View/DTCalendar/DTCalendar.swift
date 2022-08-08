//
//  DTCalendar.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import UIKit

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
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        return collectionView
    }()
    
    // MARK: - Properties
    let week = ["일", "월", "화", "수", "목", "금", "토"]
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureSubViews()
        setConstraintsOfDateLabel()
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
}

// MARK: - UI
extension DTCalendar {
    private func configureSubViews() {
        [calendarCollectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }
    
    private func setConstraintsOfDateLabel() {
        calendarCollectionView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
}



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
            cell.configureCell(date: week[indexPath.row])
        case 1:
            cell.configureCell(date: "10")
        default: break
        }
        
        
        return cell
    }
}

extension DTCalendar: UICollectionViewDelegate {
    
}

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
