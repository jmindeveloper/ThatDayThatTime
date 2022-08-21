//
//  ToastMessageManager.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/21.
//

import Toast
import Combine
import Foundation

final class ToastMessageManager {
    
    static let toast = PassthroughSubject<String, Never>()
    static func requestToast(message: String) {
        ToastMessageManager.toast.send(message)
    }
    
}
