//
//  DayDiaryCollectionViewCell.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/15.
//

import UIKit
import SnapKit

final class DayDiaryCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "DayDiaryCollectionViewCell"
    
    // MARK: - ViewProperties
    private let moveDayDiaryView = MoveDayDiaryView()
    
    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        
        return view
    }()
    
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubViews()
        setConstraintsOfMoveDayDiaryView()
        setConstraintsOfBottomLine()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Method
extension DayDiaryCollectionViewCell {
    func configureCell(with diary: DayDiary) {
        moveDayDiaryView.cofigureDateLabel(date: diary.date ?? "")
    }
}

// MARK: - UI
extension DayDiaryCollectionViewCell {
    private func configureSubViews() {
        [moveDayDiaryView, bottomLine].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setConstraintsOfMoveDayDiaryView() {
        moveDayDiaryView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(bottomLine.snp.top).offset(-3)
            
        }
    }
    
    private func setConstraintsOfBottomLine() {
        bottomLine.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(7)
            $0.height.equalTo(1)
        }
    }
}
