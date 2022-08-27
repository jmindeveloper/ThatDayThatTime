//
//  UserNotificationManager+Extension.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/27.
//

import Foundation

extension UserNotificationManager {
    enum UNCategory {
        case defaultNoti
        
        var identifier: String {
            switch self {
            case .defaultNoti:
                return "defaultNoti"
            }
        }
    }
    
    enum UNAction {
        case textInput
        
        var identifier: String {
            switch self {
            case .textInput:
                return "textInput"
            }
        }
    }
}
