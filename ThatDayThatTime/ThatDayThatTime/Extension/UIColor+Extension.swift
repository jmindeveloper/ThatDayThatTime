//
//  UIColor+Extension.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/09.
//

import UIKit

extension UIColor {
    static var daySelectedColor: UIColor {
        return UIColor(named: "DaySelectedColor") ?? UIColor.clear
    }
    
    static var viewBackgroundColor: UIColor {
        return UIColor(named: "ViewBackgroundColor") ?? UIColor.clear
    }
    
    static var segmentedSelectedColor: UIColor {
        return UIColor(named: "SegmentedSelectedColor") ?? UIColor.clear
    }
    
    static var segmentedNonSelectedColor: UIColor {
        return UIColor(named: "SegmentedNonSelectedColor") ?? UIColor.clear
    }
    
    static var settingCellBackgroundColor: UIColor {
        return UIColor(named: "SettingCellBackgroundColor") ?? UIColor.clear
    }
}
