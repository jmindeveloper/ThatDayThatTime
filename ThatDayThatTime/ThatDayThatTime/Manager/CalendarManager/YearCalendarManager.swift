//
//  YearCalendarManager.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/17.
//

import Foundation
import Combine

final class YearCalendarManager {
    private let calendar = Calendar.current
    private var date = Date()
    let updateYear = PassthroughSubject<[String], Never>()
    
    func updateCalendar() {
        var date = date
        var years = [String]()
        for _ in 0..<3 {
            var year  = String.getYear(date: date)
            year.removeLast()
            years.append(year)
            date = calendar.date(byAdding: DateComponents(year: 1), to: date) ?? Date()
        }
        updateYear.send(years)
    }
    
    func afterThreeYear() {
        date = calendar.date(byAdding: DateComponents(year: 3), to: date) ?? Date()
        updateCalendar()
    }
    
    func beforeThreeYear() {
        date = calendar.date(byAdding: DateComponents(year: -3), to: date) ?? Date()
        updateCalendar()
    }
}
