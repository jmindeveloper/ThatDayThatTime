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
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        
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
    
    func configureCell(weak: String) {
        self.dateLabel.text = weak
        self.dateLabel.backgroundColor = .clear
        self.dateLabel.textColor = .darkGray
    }
    
    func configureCell(day: CalendarCellComponents) {
        self.dateLabel.text = day.day
        self.dateLabel.textColor = day.dayColor
        self.dateLabel.backgroundColor = day.cellColor
    }
    
    func configureCell(year: String, isSelected: Bool) {
        self.dateLabel.text = year
        self.dateLabel.font = .systemFont(ofSize: 16)
        self.contentView.backgroundColor = isSelected ? .daySelectedColor : .clear
        self.dateLabel.textColor = .darkGray
        contentView.layer.cornerRadius = 5
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
            $0.height.equalToSuperview().multipliedBy(1)
            $0.width.equalTo(dateLabel.snp.height)
        }
    }
}
