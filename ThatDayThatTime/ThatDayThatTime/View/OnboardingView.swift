//
//  OnboardingView.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/28.
//

import UIKit

final class OnboardingView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.removeFromSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
