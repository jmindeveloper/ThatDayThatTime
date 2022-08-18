//
//  UserSettingManager.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/17.
//

import UIKit

final class UserSettingManager {
    
    enum UserDefaultsKey {
        case isFirstPractice, font
        
        var key: String {
            switch self {
            case .isFirstPractice:
                return "isFirstPractice"
            case .font:
                return "font"
            }
        }
    }
    
    static let shared = UserSettingManager()
    let userDefaults = UserDefaults.standard
    
    private init() { }
    
    /// 앱 첫 실행 여부
    func isFirstPractice() -> Bool {
        if userDefaults.object(forKey: UserDefaultsKey.isFirstPractice.key) == nil {
            userDefaults.set("x", forKey: UserDefaultsKey.isFirstPractice.key)
            return true
        } else {
            return false
        }
    }
    
    /// font
    func setFont(fontIndex: Int) {
        userDefaults.set(fontIndex, forKey: UserDefaultsKey.font.key)
    }
    
    func getFont() -> (font: UIFont, index: Int) {
        let fontIndex = userDefaults.integer(forKey: UserDefaultsKey.font.key)
        let font = Font(rawValue: fontIndex)?.font ?? UIFont.leeSeoyun
        
        return (font, fontIndex)
    }
}
