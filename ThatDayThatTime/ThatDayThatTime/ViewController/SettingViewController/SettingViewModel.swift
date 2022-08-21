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
    let settingLocalAuth = PassthroughSubject<Bool, Never>()
    
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
                        self.setting.setLocalAuth(state: isOn)
                        self.switchOff(section: 1, item: 0)
                    }
                }
            ),
            .switchCell(model: SettingSwitchModel(
                title: "생체인증",
                Accessory: nil,
                isOn: setting.getLocalAuth()) { isOn in
                    if isOn {
                        let securityState = self.setting.getSecurityState()
                        self.settingLocalAuth.send(securityState)
                    } else {
                        self.setLocalAuth(state: false)
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
                    if isOn {
                        self.switchOn(section: 2, item: 0)
                    } else {
                        self.switchOff(section: 2, item: 0)
                    }
                    self.setting.setICloudSync(sync: isOn)
                }
            )
        ]))
        
        updateSetting.send()
    }
    
    func setLocalAuth(state: Bool) {
        setting.setLocalAuth(state: state)
    }
    
    func switchOn(section: Int, item: Int) {
        let model = sections[section].settingCells[item]
        if case .switchCell(model: var model) = model {
            model.isOn = true
            let cell = SettingCellType.switchCell(
                model: SettingSwitchModel(
                    title: model.title,
                    Accessory: model.Accessory,
                    isOn: model.isOn,
                    handler: model.handler
                )
            )
            sections[section].settingCells[item] = cell
        }
    }
    
    func switchOff(section: Int, item: Int) {
        let model = sections[section].settingCells[item]
        if case .switchCell(model: var model) = model {
            model.isOn = false
            if model.title == "비밀번호" {
                switchOff(section: section, item: item + 1)
            }
            let cell = SettingCellType.switchCell(
                model: SettingSwitchModel(
                    title: model.title,
                    Accessory: model.Accessory,
                    isOn: model.isOn,
                    handler: model.handler
                )
            )
            sections[section].settingCells[item] = cell
            updateSetting.send()
        }
    }
}
