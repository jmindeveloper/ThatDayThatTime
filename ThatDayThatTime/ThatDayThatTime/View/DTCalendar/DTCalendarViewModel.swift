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
            updateCalendarDone.send()
        }
    }
    let updateCalendarDone = PassthroughSubject<Void, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    var daysCount = 42
    
    init() {
        bindingManager()
    }
    
    // MARK: - Method
    func updateCalendar() {
        manager.updateCalendar()
    }
    
    // MARK: - Binding
    func bindingManager() {
        manager.sendNewDay
            .map { day -> CalendarCellComponents in
                if day.date == String.getDate(date: Date()) {
                    var day = day
                    day.dayColor = .red
                    return day
                }
                return day
            }
            .collect(daysCount)
            .sink { days in
                self.days = days
            }.store(in: &subscriptions)
    }
    
}
