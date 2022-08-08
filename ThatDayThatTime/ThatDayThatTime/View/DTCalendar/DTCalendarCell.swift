//
//  DTCalendarCell.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import UIKit
import SnapKit

final class DTCalendarCell: UICollectionViewCell {
    
    static let identifier = "DTCalendarCell"
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubViews()
        setConstraintsOfDateLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(date: String) {
        self.dateLabel.text = date
    }
}

// MARK: - UI
extension DTCalendarCell {
    private func configureSubViews() {
        [dateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setConstraintsOfDateLabel() {
        dateLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalToSuperview().multipliedBy(0.8)
        }
    }
}
