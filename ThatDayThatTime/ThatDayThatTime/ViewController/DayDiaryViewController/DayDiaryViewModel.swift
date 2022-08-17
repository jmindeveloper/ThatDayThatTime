//
//  DayDiaryViewModel.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/14.
//

import UIKit
import Combine

final class DayDiaryViewModel {
    
    // MARK: - Properties
    var dayDiary: DayDiary?
    var date: String
    var coreDataManager: CoreDataManager
    private var subscriptions = Set<AnyCancellable>()
    let notExistDayDiary = PassthroughSubject<Void, Never>()
    let existDayDiary = PassthroughSubject<DayDiary, Never>()
    let updateFullSizeImage = PassthroughSubject<UIImage?, Never>()
    
    // MARK: - LifeCycle
    init(coreDataManager: CoreDataManager, date: String) {
        self.coreDataManager = coreDataManager
        self.date = date
        bindingCoreDataManager()
    }
    
    convenience init(diary: DayDiary) {
        self.init(coreDataManager: CoreDataManager(), date: diary.date ?? String.getDate())
        dayDiary = diary
    }
}

// MARK: - Method
extension DayDiaryViewModel {
    func getDiary() {
        coreDataManager.getDiary(type: .day, filterType: .date, query: date)
    }
    
    func getFullSizeImage(id: String) {
        coreDataManager.getFullSizeImage(id: id)
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
                if let diary = diary {
                    self?.existDayDiary.send(diary)
                    self?.dayDiary = diary
                } else {
                    self?.notExistDayDiary.send()
                }
            }.store(in: &subscriptions)
        
        coreDataManager.fetchFullSizeImage
            .map {
                UIImage.getImage(data: $0)
            }
            .sink { [weak self] image in
                self?.updateFullSizeImage.send(image)
            }.store(in: &subscriptions)
    }
}
