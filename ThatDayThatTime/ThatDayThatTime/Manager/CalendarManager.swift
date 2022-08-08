//
//  CalendarManager.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import Foundation
import Combine
import UIKit


final class CalendarManager {
    
    let calendar = Calendar.current
    var calendarDate = Date()
    var days = [CalendarCellComponents]()
    let updateCalendarDone = PassthroughSubject<Void, Never>()
    
    private func startDateOfMonth(from date: Date) -> Int {
        return calendar.component(.weekday, from: date) - 1
    }
    
    private func endDate(from date: Date) -> Int {
        return calendar.range(of: .day, in: .month, for: date)?.count ?? 0
    }
    
    func updateCalendar() {
        updateDays()
    }
    
    private func createCalendarCellComponents(day: String, color: UIColor) -> CalendarCellComponents {
        let components = CalendarCellComponents(
            day: day,
            dayColor: color
        )
        
        return components
    }
    
    private func updateDays() {
        days.removeAll()
        let startDayOfTheWeek = startDateOfMonth(from: calendarDate)
        let currentEndDate = endDate(from: calendarDate)
        let beforeMonth = calendar.date(byAdding: DateComponents(month: -1), to: calendarDate) ?? Date()
        let beforeMonthEndDate = endDate(from: beforeMonth)
        var beforeDayOffset = 0 - startDayOfTheWeek + 1
        var afterDayOffset = 1
        
        for i in 0..<49 {
            if i < startDayOfTheWeek {
                let day = String(beforeMonthEndDate + beforeDayOffset)
                days.append(createCalendarCellComponents(day: day, color: .lightGray))
                beforeDayOffset += 1
                continue
            }
            if i > currentEndDate + startDayOfTheWeek - 1 {
                days.append(createCalendarCellComponents(day: String(afterDayOffset), color: .lightGray))
                afterDayOffset += 1
                continue
            }
            let day = String(i - startDayOfTheWeek + 1)
            days.append(createCalendarCellComponents(day: day, color: .darkGray))
        }
        updateCalendarDone.send()
    }
    
    func minusMonth() {
        calendarDate = calendar.date(byAdding: DateComponents(month: -1), to: calendarDate) ?? Date()
        updateCalendar()
    }
    
    func plusMonth() {
        calendarDate = calendar.date(byAdding: DateComponents(month: 1), to: calendarDate) ?? Date()
        updateCalendar()
    }
}
