//
//  DTCalendarManager.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import Foundation
import Combine
import UIKit


final class DTCalendarManager {
    
    private let calendar = Calendar.current
    private var calendarDate = Date()
    private var currentCalendarMonthDate = Date()
    private var selectedCalendarDate = Date()
    let updateDay = PassthroughSubject<CalendarCellComponents, Never>()
    
    private func startDateOfMonth(from date: Date) -> Int {
        return calendar.component(.weekday, from: date) - 1
    }
    
    private func endDate(from date: Date) -> Int {
        return calendar.range(of: .day, in: .month, for: date)?.count ?? 0
    }
    
    func updateCalendar() {
        let date = calendar.component(.day, from: calendarDate) - 1
        calendarDate = calendar.date(byAdding: DateComponents(day: -date), to: calendarDate) ?? Date()
        currentCalendarMonthDate = calendarDate
        updateDays()
    }
    
    private func createCalendarCellComponents(color: UIColor, date: Date, isCurrentMonth: Bool) -> CalendarCellComponents {
        let date = calendar.dateComponents([.year, .month, .day, .weekday], from: calendarDate)
                          
        let components = CalendarCellComponents(
            year: String(date.year ?? 2022),
            month: String(date.month ?? 1),
            day: String(date.day ?? 1),
            week: (date.weekday ?? 1) - 1,
            dayColor: color,
            isCurrentMonth: isCurrentMonth
        )
        
        return components
    }
    
    private func updateDays() {
        let startDayOfTheWeek = startDateOfMonth(from: calendarDate)
        let currentEndDate = endDate(from: calendarDate)
        var beforeDayOffset = 0 - startDayOfTheWeek
        var afterDayOffset = 1
        calendarDate = calendar.date(byAdding: DateComponents(day: beforeDayOffset), to: calendarDate) ?? Date()
        
        for i in 0..<42 {
            if i < startDayOfTheWeek {
                updateDay.send(createCalendarCellComponents(color: .lightGray, date: calendarDate, isCurrentMonth: false))
                beforeDayOffset += 1
                calendarDate = calendar.date(byAdding: DateComponents(day: 1), to: calendarDate) ?? Date()
                continue
            }
            if i > currentEndDate + startDayOfTheWeek - 1 {
                updateDay.send(createCalendarCellComponents(color: .lightGray, date: calendarDate, isCurrentMonth: false))
                afterDayOffset += 1
                calendarDate = calendar.date(byAdding: DateComponents(day: 1), to: calendarDate) ?? Date()
                continue
            }
            updateDay.send(createCalendarCellComponents(color: .darkGray, date: calendarDate, isCurrentMonth: true))
            calendarDate = calendar.date(byAdding: DateComponents(day: 1), to: calendarDate) ?? Date()
        }
    }
    
    func minusMonth() {
        calendarDate = calendar.date(byAdding: DateComponents(month: -1), to: currentCalendarMonthDate) ?? Date()
        updateCalendar()
    }
    
    func minusDay(completion: (String) -> Void) {
        selectedCalendarDate = calendar.date(byAdding: DateComponents(day: -1), to: selectedCalendarDate) ?? Date()
        completion(String.getDate(date: selectedCalendarDate))
    }
    
    func plusMonth() {
        calendarDate = calendar.date(byAdding: DateComponents(month: 1), to: currentCalendarMonthDate) ?? Date()
        
        updateCalendar()
    }
    
    func plusDay(completion: (String) -> Void) {
        selectedCalendarDate = calendar.date(byAdding: DateComponents(day: 1), to: selectedCalendarDate) ?? Date()
        completion(String.getDate(date: selectedCalendarDate))
    }
    
    func updateSelectedCalendarDate(with selectedDate: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        
        selectedCalendarDate = formatter.date(from: selectedDate) ?? Date()
    }
}
