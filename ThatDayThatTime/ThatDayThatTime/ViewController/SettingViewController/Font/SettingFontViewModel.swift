//
//  SettingFontViewModel.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/18.
//

import UIKit

final class SettingFontViewModel {
    private let fonts = Font.allCases
    lazy var fontModels = SettingSection(sectionTitle: "폰트", settingCells: configure())
    
    func configure() -> [SettingCellType] {
        var models = [SettingCellType]()
        fonts.forEach {
            let model = SettingCellType.accessoryCell(
                model: SettingAccessoryModel(
                    title: $0.fontName,
                    accessory: UIImage(systemName: "checkmark")) {
                        print("폰트")
                    })
            models.append(model)
        }
        return models

    }
}

