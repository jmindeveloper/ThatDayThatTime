//
//  OnboardingCollectionViewCell.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/28.
//

import UIKit

final class OnboardingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "OnboardingCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = [.red, .blue, .green, .orange, .cyan, .darkGray, .purple, .systemPink].randomElement()!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
