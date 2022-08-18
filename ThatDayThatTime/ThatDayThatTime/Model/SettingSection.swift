//
//  SettingSection.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/18.
//

import UIKit

struct SettingSection {
    let sectionTitle: String
    var settingCells: [SettingCellType]
}

enum SettingCellType {
    case accessoryCell(model: SettingAccessoryModel)
    case switchCell(model: SettingSwitchModel)
}

struct SettingAccessoryModel {
    let title: String
    let accessory: UIImage?
    let handler: (() -> Void)?
}

struct SettingSwitchModel {
    let title: String
    let Accessory: UIImage?
    let isOn: Bool
    let handler: ((Bool) -> Void)?
}
