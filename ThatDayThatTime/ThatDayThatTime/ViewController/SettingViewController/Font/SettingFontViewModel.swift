//
//  SettingFontViewModel.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/18.
//

import UIKit
import Combine

final class SettingFontViewModel {
    private let fonts = Font.allCases
    lazy var fontModels = SettingSection(sectionTitle: "폰트", settingCells: configure())
    lazy var updateFont = PassthroughSubject<Void, Never>()
    
    private func configure() -> [SettingCellType] {
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
    
    private func updateSelectedCell(index: Int) {
        
    }
    
    func changeFont(fontIndex: Int) {
        let fontModel = fontModels.settingCells[fontIndex]
        if case .accessoryCell(model: let model) = fontModel {
            model.handler?()
            UserSettingManager.shared.setFont(fontIndex: fontIndex)
            updateFont.send()
        }
    }
}

