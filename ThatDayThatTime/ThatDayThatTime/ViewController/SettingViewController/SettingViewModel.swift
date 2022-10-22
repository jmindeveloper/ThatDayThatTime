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
    let failUserNotificationAuthorization = PassthroughSubject<Void, Never>()
    let onboarding = PassthroughSubject<Void, Never>()
    private let userNotiManager = UserNotificationManager()
    
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
                description: "폰트를 변경할 수 있습니다",
                accessory: UIImage(systemName: "chevron.right")) {
                    self.settingFont.send()
                }
            ),
            .switchCell(model: SettingSwitchModel(
                title: "알림",
                description: "기록을 까먹지 않게 하루 3번 알림이 옵니다",
                accessory:  nil,
                isOn: setting.getUSerNotificationSetting()) { isOn in
                    if isOn {
                        UserNotificationManager.authorization() { success in
                            if success {
                                self.switchOn(section: 0, item: 1)
                                self.setting.setUserNotificationSetting(state: true)
                                self.userNotiManager.addDefaultNotification()
                            } else {
                                self.failUserNotificationAuthorization.send()
                            }
                        }
                    } else {
                        self.switchOff(section: 0, item: 1)
                        self.setting.setUserNotificationSetting(state: false)
                        self.userNotiManager.removeDefaultNotification()
                    }
                }
            ),
            .switchCell(model: SettingSwitchModel(
                title: "미리알림",
                description: "이후의 시간에 작성된 시간일기의 알림을 보내드립니다",
                accessory: nil,
                isOn: setting.getReminder()) { isOn in
                    if isOn {
                        self.switchOn(section: 0, item: 2)
                        self.setting.setReminder(state: true)
                    } else {
                        self.setting.setReminder(state: false)
                        self.switchOff(section: 0, item: 2)
                    }
                }
            ),
            .accessoryCell(model: SettingAccessoryModel(
                title: "그날 그시간 사용법",
                accessory: UIImage(systemName: "chevron.right"),
                handler: {
                    self.onboarding.send()
                }))
        ]))
        
        // MARK: - 보안
        sections.append(SettingSection(sectionTitle: "보안", settingCells: [
            .switchCell(model: SettingSwitchModel(
                title: "비밀번호",
                description: "비밀번호 분실시 복구가 불가능합니다",
                accessory: nil,
                isOn: setting.getSecurityStateSetting()) { isOn in
                    if isOn {
                        self.settingPassword.send()
                    } else {
                        self.setting.setSecurityStateSetting(securityState: isOn)
                        self.setting.setLocalAuthSetting(state: isOn)
                        self.switchOff(section: 1, item: 0)
                    }
                }
            ),
            .switchCell(model: SettingSwitchModel(
                title: "생체인증",
                description: "비밀번호가 설정돼 있어야 사용이 가능합니다",
                accessory: nil,
                isOn: setting.getLocalAuthSetting()) { isOn in
                    if isOn {
                        let securityState = self.setting.getSecurityStateSetting()
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
                description: "첫 설정시 오래걸릴 수 있습니다",
                accessory: nil,
                isOn: setting.getICloudSyncSetting()) { isOn in
                    if isOn {
                        self.switchOn(section: 2, item: 0)
                    } else {
                        self.switchOff(section: 2, item: 0)
                    }
                    self.setting.setICloudSyncSetting(sync: isOn)
                }
            )
        ]))
        
        updateSetting.send()
    }
    
    func setLocalAuth(state: Bool) {
        setting.setLocalAuthSetting(state: state)
    }
    
    func switchOn(section: Int, item: Int) {
        let model = sections[section].settingCells[item]
        if case .switchCell(model: var model) = model {
            model.isOn = true
            let cell = SettingCellType.switchCell(
                model: SettingSwitchModel(
                    title: model.title,
                    description: model.description,
                    accessory: model.accessory,
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
                    description: model.description,
                    accessory: model.accessory,
                    isOn: model.isOn,
                    handler: model.handler
                )
            )
            sections[section].settingCells[item] = cell
            updateSetting.send()
        }
    }
}
