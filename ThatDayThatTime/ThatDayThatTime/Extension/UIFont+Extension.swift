//
//  UIFont+Extension.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/18.
//

import UIKit

enum Font: Int, CaseIterable {
    
    enum FontSize {
        case small, medium, large
        
        var size: CGFloat {
            switch self {
            case .small:
                return 12
            case .medium:
                return 20
            case .large:
                return 25
            }
        }
    }
    
    case leaSeoyun, jeonHwaseon, simKyungha
    case yeongdo, misaeng
    
    var font: UIFont {
        switch self {
        case .leaSeoyun:
            return UIFont(name: "LeeSeoyun", size: FontSize.medium.size) ?? UIFont()
        case .jeonHwaseon:
            return UIFont(name: "JeonHwaseon", size: FontSize.large.size) ?? UIFont()
        case .simKyungha:
            return UIFont(name: "SimKyungha", size: FontSize.medium.size) ?? UIFont()
        case .yeongdo:
            return UIFont(name: "Yeongdo", size: FontSize.medium.size) ?? UIFont()
        case .misaeng:
            return UIFont(name: "SDMiSaeng", size: FontSize.large.size) ?? UIFont()
        }
    }
    
    var fontName: String {
        switch self {
        case .leaSeoyun:
            return "이서윤체"
        case .jeonHwaseon:
            return "전화선체"
        case .simKyungha:
            return "심경화체"
        case .yeongdo:
            return "영도체"
        case .misaeng:
            return "미생체"
        }
    }
}

extension UIFont {
    static var customFont: UIFont {
        let font = UserSettingManager.shared.getFontSetting()
        
        return font.font
    }
}
