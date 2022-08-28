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
    let description: String?
    let accessory: UIImage?
    let handler: (() -> Void)?
    
    init(title: String, description: String?, accessory: UIImage?, handler: (() -> Void)?) {
        self.title = title
        self.description = description
        self.accessory = accessory
        self.handler = handler
    }
    
    init(title: String, accessory: UIImage?, handler: (() -> Void)?) {
        self.init(title: title, description: nil, accessory: accessory, handler: handler)
    }
}

struct SettingSwitchModel {
    let title: String
    let description: String?
    let accessory: UIImage?
    var isOn: Bool
    let handler: ((Bool) -> Void)?
    
    init(title: String, description: String?, accessory: UIImage?, isOn: Bool, handler: ((Bool) -> Void)?) {
        self.title = title
        self.description = description
        self.isOn = isOn
        self.accessory = accessory
        self.handler = handler
    }
    
    init(title: String, accessory: UIImage?, isOn: Bool, handler: ((Bool) -> Void)?) {
        self.init(title: title, description: nil, accessory: accessory, isOn: isOn, handler: handler)
    }
}
