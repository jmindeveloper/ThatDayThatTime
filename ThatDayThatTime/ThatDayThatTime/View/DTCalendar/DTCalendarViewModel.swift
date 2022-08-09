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
        willSet {
            updateCalendar.send()
        }
    }
    let updateCalendar = PassthroughSubject<Void, Never>()
    let updateCurrentDate = CurrentValueSubject<String, Never>(String.getDate(date: Date()))
    
    private var subscriptions = Set<AnyCancellable>()
    
    var daysCount = 42
    
    init() {
        bindingManager()
    }
    
    // MARK: - Method
    func updateCalendarRequest() {
        manager.updateCalendar()
    }
    
    // MARK: - Binding
    func bindingManager() {
        manager.sendNewDay
            .map { day -> CalendarCellComponents in
                if day.date == String.getDate(date: Date()) {
                    var day = day
                    day.dayColor = .red
                    day.cellColor = .daySelectedColor
                    return day
                }
                return day
            }
            .collect(daysCount)
            .sink { days in
                self.days = days
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
