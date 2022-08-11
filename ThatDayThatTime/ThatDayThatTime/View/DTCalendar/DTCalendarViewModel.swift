//
//  DTCalendarViewModel.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/09.
//

import Foundation
import Combine

final class DTCalendarViewModel {
    
    // MARK: - Properties
    let manager = CalendarManager()
    let week = ["일", "월", "화", "수", "목", "금", "토"]
    var days = [CalendarCellComponents]() {
        didSet {
            updateCalendar.send()
        }
    }
    let updateCalendar = PassthroughSubject<Void, Never>()
    let updateCurrentDate = CurrentValueSubject<String, Never>(String.getDate())
    
    private var subscriptions = Set<AnyCancellable>()
    
    var daysCount = 42
    
    init() {
        bindingManager()
    }
    
    // MARK: - Method
    func updateCalendarRequest() {
        manager.updateCalendar()
    }
    
    func updateNextMonth() {
        manager.plusMonth()
    }
    
    func updateBeforeMonth() {
        manager.minusMonth()
    }
    
    func mapCalendarCellComponentIsToday(_ component: CalendarCellComponents) -> CalendarCellComponents {
        if component.date == String.getDate() {
            var day = component
            day.dayColor = .red
            return day
        }
        return component
    }
    
    func mapCalendarCellComponentIsSelected(_ component: CalendarCellComponents) -> CalendarCellComponents {
        var day = updateCurrentDate.value.components(separatedBy: " ")[2]
        day.removeLast()
        
        if component.day == day, component.isCurrentMonth {
            var day = component
            day.cellColor = .daySelectedColor
            updateCurrentDate.send(component.date)
            return day
        }
        return component
    }
    
    // MARK: - Binding
    func bindingManager() {
        manager.sendNewDay
            .map(mapCalendarCellComponentIsToday(_:))
            .map(mapCalendarCellComponentIsSelected(_:))
            .collect(daysCount)
            .sink { [weak self] days in
                self?.days = days
            }.store(in: &subscriptions)
    }
    
    func selectedDay(index: Int) {
        var dayss = days
        for i in 0..<dayss.count {
            if i == index {
                dayss[index].cellColor = .daySelectedColor
                updateCurrentDate.send(dayss[index].date)
            } else {
                dayss[i].cellColor = .clear
            }
        }
        
        days = dayss
    }
}
