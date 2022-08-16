//
//  SegmentedCollectionViewCell.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/16.
//

import UIKit
import SnapKit

final class SegmentedCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "SegmentedCollectionViewCell"
    
    // MARK: - ViewProperteis
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        label.textAlignment = .center
        label.text = "1월"
        
        return label
    }()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubViews()
        setConstraintsOfMonthLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.frame.height / 2
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowRadius = 1
        contentView.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
}

// MARK: - Method
extension SegmentedCollectionViewCell {
    func selectedCell(isSelected: Bool) {
        contentView.backgroundColor = isSelected ? .segmentedSelectedColor : .segmentedNonSelectedColor
    }
    
    func configureCell(month: String) {
        monthLabel.text = month
    }
}

// MARK: - UI
extension SegmentedCollectionViewCell {
    private func configureSubViews() {
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(monthLabel)
    }
    
    private func setConstraintsOfMonthLabel() {
        monthLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

