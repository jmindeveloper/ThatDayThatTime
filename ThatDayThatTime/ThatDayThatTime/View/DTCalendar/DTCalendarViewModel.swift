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
    let manager = DTCalendarManager()
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
    
    func updateNextDay() {
        manager.plusDay { date in
            if !selectedDay(date: date) {
                updateNextMonth()
                selectedDay(date: date)
            }
        }
    }
    
    func updateBeforeDay() {
        manager.minusDay { date in
            if !selectedDay(date: date) {
                updateBeforeMonth()
                selectedDay(date: date)
            }
        }
            
    }
    
    private func mapCalendarCellComponentIsToday(_ component: CalendarCellComponents) -> CalendarCellComponents {
        if component.date == String.getDate() {
            var day = component
            day.dayColor = .red
            return day
        }
        return component
    }
    
    private func mapCalendarCellComponentIsSelected(_ component: CalendarCellComponents) -> CalendarCellComponents {
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
    private func bindingManager() {
        manager.updateDay
            .map(mapCalendarCellComponentIsToday(_:))
            .map(mapCalendarCellComponentIsSelected(_:))
            .collect(daysCount)
            .sink { [weak self] days in
                self?.days = days
            }.store(in: &subscriptions)
    }
    
    func selectedDay(index: Int) {
        var days = days
        for i in 0..<days.count {
            if i == index {
                days[index].cellColor = .daySelectedColor
                updateCurrentDate.send(days[index].date)
            } else {
                days[i].cellColor = .clear
            }
        }
        manager.updateSelectedCalendarDate(with: days[index].date)
        self.days = days
    }
    
    @discardableResult
    private func selectedDay(date: String) -> Bool {
        if let index = days.firstIndex(where: { component in
            component.date == date
        }) {
            selectedDay(index: index)
            return true
        }
        return false
    }
}
