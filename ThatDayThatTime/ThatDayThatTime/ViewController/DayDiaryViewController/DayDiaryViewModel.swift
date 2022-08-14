//
//  DayDiaryViewModel.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/14.
//

import Foundation
import Combine

final class DayDiaryViewModel {
    
    // MARK: - Properties
    private var dayDiary: DayDiary?
    private var date: String
    private var coreDataManager: CoreDataManager
    private var subscriptions = Set<AnyCancellable>()
    let notExistDayDiary = PassthroughSubject<Void, Never>()
    
    // MARK: - LifeCycle
    init(coreDataManager: CoreDataManager, date: String) {
        self.coreDataManager = coreDataManager
        self.date = date
        coreDataManager.getDiary(type: .day, date: date)
        bindingCoreDataManager()
    }
}

// MARK: - Binding
extension DayDiaryViewModel {
    private func bindingCoreDataManager() {
        coreDataManager.fetchDayDiary
            .map {
                $0.first as? DayDiary
            }
            .sink { [weak self] diary in
                if diary == nil {
                    self?.notExistDayDiary.send()
                } else {
                    self?.dayDiary = diary
                }
            }.store(in: &subscriptions)
    }
}
