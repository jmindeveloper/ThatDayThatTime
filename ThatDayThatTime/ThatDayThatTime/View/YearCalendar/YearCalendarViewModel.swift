//
//  YearCalendarViewModel.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/17.
//

import Foundation
import Combine

final class YearCalendarViewModel {
    
    var years = [(String, Bool)]() {
        didSet {
            updateYears.send()
        }
    }
    private let manager = YearCalendarManager()
    private var subscriptions = Set<AnyCancellable>()
    let updateYears = PassthroughSubject<Void, Never>()
    lazy var updateCurrentYear = CurrentValueSubject<String, Never>(selectedYear)
    private var selectedYear: String
    var calendarAction: Bool = false
    
    init() {
        var year = String.getYear()
        year.removeLast()
        selectedYear = year
        bindingManager()
        manager.updateCalendar()
    }
    
    func getAfterThreeYear() {
        manager.afterThreeYear()
    }
    
    func getBeforeThreeYear() {
        manager.beforeThreeYear()
    }
    
    func selectedYear(year: String) {
        if selectedYear != year {
            selectedYear = year
            manager.updateCalendar()
            updateCurrentYear.send(year)
        }
    }
    
    private func updateSelectedYear(years: [String]) -> [(String, Bool)] {
        if !calendarAction {
            if !years.contains(selectedYear) {
                if years.last ?? "" < selectedYear {
                    getAfterThreeYear()
                } else {
                    getBeforeThreeYear()
                }
            }
        }
        calendarAction = false
        
        return years.map { [weak self] year -> (String, Bool) in
            if year == self?.selectedYear {
                return (year, true)
            } else {
                return (year, false)
            }
        }
    }
    
    private func bindingManager() {
        manager.updateYear
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .map(updateSelectedYear(years:))
            .sink { [weak self] years in
                self?.years = years
            }.store(in: &subscriptions)
    }
}

