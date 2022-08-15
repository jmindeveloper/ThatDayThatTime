//
//  CalendarCellComponents.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import Foundation
import UIKit

enum WeekDay: Int {
    case sun = 0, mon, tue, wed, thu, fri, sat
    
    var weekday: String {
        switch self {
        case .sun:
            return "일요일"
        case .mon:
            return "월요일"
        case .tue:
            return "화요일"
        case .wed:
            return "수요일"
        case .thu:
            return "목요일"
        case .fri:
            return "금요일"
        case .sat:
            return "토요일"
        }
    }
}

struct CalendarCellComponents {
    let year: String
    let month: String
    let day: String
    let week: Int
    var dayColor: UIColor?
    var cellColor: UIColor? = .clear
    var isCurrentMonth: Bool
    
    var weekday: String {
        WeekDay(rawValue: week)?.weekday ?? "월요일"
    }
    
    var date: String {
        String.getDate(components: self)
    }
}
