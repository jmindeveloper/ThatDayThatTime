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
        calendarDate = calendar.date(byAdding: DateComponents(day: -8), to: calendarDate) ?? Date()
        updateDays()
    }
    
    private func createCalendarCellComponents(color: UIColor, date: Date) -> CalendarCellComponents {
        let date = calendar.dateComponents([.year, .month, .day, .weekday], from: calendarDate)
                          
        let components = CalendarCellComponents(
            year: String(date.year ?? 2022),
            month: String(date.month ?? 1),
            day: String(date.day ?? 1),
            week: (date.weekday ?? 1) - 1,
            dayColor: color
        )
        
        return components
    }
    
    private func updateDays() {
        days.removeAll()
        let startDayOfTheWeek = startDateOfMonth(from: calendarDate)
        let currentEndDate = endDate(from: calendarDate)
        var beforeDayOffset = 0 - startDayOfTheWeek
        var afterDayOffset = 1
        calendarDate = calendar.date(byAdding: DateComponents(day: beforeDayOffset), to: calendarDate) ?? Date()
        
        for i in 0..<49 {
            if i < startDayOfTheWeek {
                days.append(createCalendarCellComponents(color: .lightGray, date: calendarDate))
                beforeDayOffset += 1
                calendarDate = calendar.date(byAdding: DateComponents(day: 1), to: calendarDate) ?? Date()
                continue
            }
            if i > currentEndDate + startDayOfTheWeek - 1 {
                days.append(createCalendarCellComponents(color: .lightGray, date: calendarDate))
                afterDayOffset += 1
                calendarDate = calendar.date(byAdding: DateComponents(day: 1), to: calendarDate) ?? Date()
                continue
            }
            days.append(createCalendarCellComponents(color: .darkGray, date: calendarDate))
            calendarDate = calendar.date(byAdding: DateComponents(day: 1), to: calendarDate) ?? Date()
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
