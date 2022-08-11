//
//  AlertManager.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/11.
//

import Foundation
import UIKit

struct AlertManager {
    let title: String?
    let message: String?
    let style: UIAlertController.Style
    
    init(
        title: String? = nil,
        message: String? = nil,
        style: UIAlertController.Style = .alert
    ) {
        self.title = title
        self.message = message
        self.style = style
    }
    
    func createAlert() -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        return alert
    }
}
