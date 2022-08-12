//
//  TimeDiaryViewModel.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/11.
//

import Foundation
import Combine

final class TimeDiaryViewModel {
    
    // MARK: - Properteis
    private var allDiary = [Diary]()
    var diarys = [TimeDiary]() {
        didSet {
            diarys.sort {
                $0.time ?? "" < $1.time ?? ""
            }
            updateDiarys.send()
        }
    }
    var date = String.getDate()
    let updateDiarys = PassthroughSubject<Void, Never>()
    let coreDataManager: CoreDataManager
    private var subscriptions = Set<AnyCancellable>()
    private let filterDiary = PassthroughSubject<Void, Never>()
        
    // MARK: - LifeCycle
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        bindingCoreDataManager()
        bindingSelf()
        coreDataManager.getDiary(type: .time)
    }
}

// MARK: - Method
extension TimeDiaryViewModel {
    func changeDate(date: String) {
        self.date = date
        filterDiary.send()
    }
}

// MARK: - Binding
extension TimeDiaryViewModel {
    private func bindingCoreDataManager() {
        coreDataManager.fetchDiary
            .sink { [weak self] diarys in
                self?.allDiary = diarys
                self?.filterDiary.send()
            }.store(in: &subscriptions)
    }
    
    private func bindingSelf() {
        filterDiary
            .flatMap { [unowned self] in
                filterDiarys()
            }
            .sink { [weak self] diarys in
                self?.diarys = diarys
            }.store(in: &subscriptions)
    }
    
    private func filterDiarys() -> AnyPublisher<[TimeDiary], Never> {
        allDiary.publisher
            .compactMap {
                $0 as? TimeDiary
            }
            .filter {
                $0.date == date
            }
            .collect()
            .eraseToAnyPublisher()
    }
}
