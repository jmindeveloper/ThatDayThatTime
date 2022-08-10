//
//  UITextView+Extension.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/10.
//

import UIKit

extension UITextView {
    func configure() {
        self.autocapitalizationType = .sentences
        self.autocorrectionType = .no
        self.spellCheckingType = .no
        self.returnKeyType = .default
    }
}
