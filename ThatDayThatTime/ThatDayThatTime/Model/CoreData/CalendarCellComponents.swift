//
//  CalendarCellComponents.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import Foundation
import UIKit

struct CalendarCellComponents {
    let year: String
    let month: String
    let day: String
    let weekday: Int
    var dayColor: UIColor?
    var cellColor: UIColor? = .clear
    let date: Date
}
