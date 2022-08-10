//
//  TimeDiaryCollectionViewCell.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/10.
//

import UIKit

final class TimeDiaryCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TimeDiaryCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .yellow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
