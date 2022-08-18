//
//  SettingSection.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/18.
//

import UIKit

struct SettingSection {
    let sectionTitle: String
    let settingCells: [SettingCellType]
}

enum SettingCellType {
    case navigationCell(model: SettingNavigationModel)
    case switchCell(model: SettingSwitchModel)
}

struct SettingNavigationModel {
    let title: String
    let accessory: UIImage?
    let handler: (() -> Void)?
}

struct SettingSwitchModel {
    let title: String
    let Accessory: UIImage?
    let isOn: Bool
    let handler: (() -> Void)?
}
