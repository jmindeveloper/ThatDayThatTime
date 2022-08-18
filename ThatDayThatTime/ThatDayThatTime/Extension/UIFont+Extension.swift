//
//  UIFont+Extension.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/18.
//

import UIKit

enum Font: Int {
    case leaSeoyun, jeonHwaseon, simKyungha
    case yeongdo, misaeng
    
    var font: UIFont {
        switch self {
        case .leaSeoyun:
            return UIFont.leeSeoyun
        case .jeonHwaseon:
            return UIFont.jeonHwaseon
        case .simKyungha:
            return UIFont.simKyungha
        case .yeongdo:
            return UIFont.yeongdo
        case .misaeng:
            return UIFont.misaeng
        }
    }
}

extension UIFont {
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
    
    static var leeSeoyun: UIFont {
        return UIFont(name: "LeeSeoyun", size: FontSize.medium.size) ?? UIFont()
    }
    
    static var jeonHwaseon: UIFont {
        return UIFont(name: "JeonHwaseon", size: FontSize.large.size) ?? UIFont()
    }
    
    static var simKyungha: UIFont {
        return UIFont(name: "SimKyungha", size: FontSize.medium.size) ?? UIFont()
    }
    
    static var yeongdo: UIFont {
        return UIFont(name: "Yeongdo", size: FontSize.medium.size) ?? UIFont()
    }
    
    static var misaeng: UIFont {
        return UIFont(name: "SDMiSaeng", size: FontSize.large.size) ?? UIFont()
    }
}
