//
//  UserSettingManager.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/17.
//

import UIKit

final class UserSettingManager {
    
    enum UserDefaultsKey {
        case isFirstPractice, font, security, password
        
        var key: String {
            switch self {
            case .isFirstPractice:
                return "isFirstPractice"
            case .font:
                return "font"
            case .security:
                return "security"
            case .password:
                return "password"
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
    
    /// setFont
    func setFont(fontIndex: Int) {
        userDefaults.set(fontIndex, forKey: UserDefaultsKey.font.key)
    }
    
    /// getFont
    func getFont() -> (font: UIFont, index: Int) {
        let fontIndex = userDefaults.integer(forKey: UserDefaultsKey.font.key)
        let font = Font(rawValue: fontIndex)?.font ?? UIFont.leeSeoyun
        
        return (font, fontIndex)
    }
    
    func setSecurityState(securityState: Bool) {
        userDefaults.set(securityState, forKey: UserDefaultsKey.security.key)
    }
    
    func getSecurityState() -> Bool {
        let security = userDefaults.bool(forKey: UserDefaultsKey.security.key)
        
        return security
    }
    
    func setPassword(password: String) {
        userDefaults.set(password, forKey: UserDefaultsKey.password.key)
    }
    
    func getPassword() -> String {
        let password = userDefaults.string(forKey: UserDefaultsKey.password.key)
        
        return password ?? ""
    }
}
