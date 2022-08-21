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
    let updateFont = PassthroughSubject<Void, Never>()
    private var selectedFontIndex = UserSettingManager.shared.getFont().index
    
    private func configure() -> [SettingCellType] {
        var models = [SettingCellType]()
        fonts.enumerated().forEach { index, font in
            let model = SettingCellType.accessoryCell(
                model: SettingAccessoryModel(
                    title: font.fontName,
                    accessory: index == selectedFontIndex ?
                    UIImage(systemName: "checkmark") : nil) { [weak self] in
                        guard let self = self else { return }
                        self.fontModels.settingCells = self.configure()
                    })
            models.append(model)
        }
        return models
    }
    
    func changeFont(fontIndex: Int) {
        let fontModel = fontModels.settingCells[fontIndex]
        if case .accessoryCell(model: let model) = fontModel {
            selectedFontIndex = fontIndex
            model.handler?()
            UserSettingManager.shared.setFont(fontIndex: fontIndex)
            updateFont.send()
        }
    }
}

