//
//  UIAlertController+Extension.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/11.
//

import UIKit

extension UIAlertController {
    func addAction(
        actionTytle: String,
        style: UIAlertAction.Style,
        handler: (() -> Void)? = nil
    ) -> UIAlertController {
        
        let action = UIAlertAction(title: actionTytle, style: style) { _ in
            handler?()
        }
        self.addAction(action)
        
        return self
    }
}
