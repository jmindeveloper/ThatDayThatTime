//
//  SettingViewModel.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/18.
//

import UIKit
import Combine

final class SettingViewModel {
    
    var sections = [SettingSection]()
    let updateSetting = PassthroughSubject<Void, Never>()
    private let setting = UserSettingManager.shared
    let settingFont = PassthroughSubject<Void, Never>()
    let settingPassword = PassthroughSubject<Void, Never>()
    let settingLocalAuth = PassthroughSubject<Void, Never>()
    
    init() {
        
    }
}

// MARK: - Method
extension SettingViewModel {
    func configure() {
        // MARK: - 설정
        sections.append(SettingSection(sectionTitle: "설정", settingCells: [
            .accessoryCell(model: SettingAccessoryModel(
                title: "폰트",
                accessory: UIImage(systemName: "chevron.right")) {
                    self.settingFont.send()
                }
            )
        ]))
        
        // MARK: - 보안
        sections.append(SettingSection(sectionTitle: "보안", settingCells: [
            .switchCell(model: SettingSwitchModel(
                title: "비밀번호",
                Accessory: nil,
                isOn: setting.getSecurityState()) { isOn in
                    if isOn {
                        self.settingPassword.send()
                    } else {
                        self.setting.setSecurityState(securityState: isOn)
                    }
                }
            ),
            .switchCell(model: SettingSwitchModel(
                title: "생체인증",
                Accessory: nil,
                isOn: false) { isOn in
                    if isOn {
                        self.settingLocalAuth.send()
                    } else {
                        print("off localauth")
                    }
                }
            )
        ]))
        
        // MARK: - 백업
        sections.append(SettingSection(sectionTitle: "백업", settingCells: [
            .switchCell(model: SettingSwitchModel(
                title: "iCloud 백업",
                Accessory: nil,
                isOn: setting.getICloudSync()) { isOn in
                    self.setting.setICloudSync(sync: isOn)
                }
            )
        ]))
        
        updateSetting.send()
    }
}
