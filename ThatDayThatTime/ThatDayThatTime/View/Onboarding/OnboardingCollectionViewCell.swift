//
//  OnboardingCollectionViewCell.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/28.
//

import UIKit
import SnapKit

final class OnboardingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "OnboardingCollectionViewCell"
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
