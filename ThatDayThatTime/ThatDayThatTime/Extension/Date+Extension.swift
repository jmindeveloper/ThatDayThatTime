//
//  Date+Extension.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import Foundation

extension Date {
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    var firstDayOfMonth: Self {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
}
