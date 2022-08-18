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
    
    init() {
        
    }
}

// MARK: - Method
extension SettingViewModel {
    func configure() {
        // MARK: - 설정
        sections.append(SettingSection(sectionTitle: "설정", settingCells: [
            .navigationCell(model: SettingNavigationModel(
                title: "폰트",
                Accessory: UIImage(systemName: "chevron.right")) {
                    print("폰트")
                }
            )
        ]))
        
        // MARK: - 보안
        sections.append(SettingSection(sectionTitle: "보안", settingCells: [
            .switchCell(model: SettingSwitchModel(
                title: "비밀번호",
                Accessory: nil,
                isOn: false) {
                    print("비밀번호")
                }
            )
        ]))
        
        updateSetting.send()
    }
}
