//
//  UserSettingManager.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/17.
//

import UIKit
import Combine

final class UserSettingManager {
    
    enum UserDefaultsKey {
        case isFirstPractice, font, security, password
        case icloud, localAuth, userNotification
        
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
            case .icloud:
                return "icloud"
            case .localAuth:
                return "localAuth"
            case .userNotification:
                return "userNotification"
            }
        }
    }
    
    static let shared = UserSettingManager()
    let userDefaults = UserDefaults.standard
    let changeICloudSync = PassthroughSubject<Void, Never>()
    
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
    func setFontSetting(fontIndex: Int) {
        userDefaults.set(fontIndex, forKey: UserDefaultsKey.font.key)
    }
    
    /// getFont
    func getFontSetting() -> (font: UIFont, index: Int) {
        let fontIndex = userDefaults.integer(forKey: UserDefaultsKey.font.key)
        let font = Font(rawValue: fontIndex)?.font ?? UIFont()
        
        return (font, fontIndex)
    }
    
    /// 보안모드 설정
    func setSecurityStateSetting(securityState: Bool) {
        userDefaults.set(securityState, forKey: UserDefaultsKey.security.key)
    }
    
    /// 보안모드 가져오기
    func getSecurityStateSetting() -> Bool {
        let security = userDefaults.bool(forKey: UserDefaultsKey.security.key)
        
        return security
    }
    
    /// 생체인증 설정
    func setLocalAuthSetting(state: Bool) {
        userDefaults.set(state, forKey: UserDefaultsKey.localAuth.key)
    }
    
    /// 생체인증 가져오기
    func getLocalAuthSetting() -> Bool {
        let localAuth = userDefaults.bool(forKey: UserDefaultsKey.localAuth.key)
        
        return localAuth
    }
    
    /// 비밀번호 설정
    func setPasswordSetting(password: String) {
        userDefaults.set(password, forKey: UserDefaultsKey.password.key)
    }
    
    /// 비밀번호 가져오기
    func getPasswordSetting() -> String {
        let password = userDefaults.string(forKey: UserDefaultsKey.password.key)
        
        return password ?? ""
    }
    
    /// icloud 백업 설정
    func setICloudSyncSetting(sync: Bool) {
        userDefaults.set(sync, forKey: UserDefaultsKey.icloud.key)
        changeICloudSync.send()
    }
    
    /// icloud 백업 가져오기
    func getICloudSyncSetting() -> Bool {
        let iCloudBackUp = userDefaults.bool(forKey: UserDefaultsKey.icloud.key)
        
        return iCloudBackUp
    }
    
    func setUserNotificationSetting(state: Bool) {
        userDefaults.set(state, forKey: UserDefaultsKey.userNotification.key)
    }
    
    func getUSerNotificationSetting() -> Bool {
        let userNoti = userDefaults.bool(forKey: UserDefaultsKey.userNotification.key)
        
        return userNoti
    }
}
