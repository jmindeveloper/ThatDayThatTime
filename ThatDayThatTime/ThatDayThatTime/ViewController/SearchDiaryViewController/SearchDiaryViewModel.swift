//
//  SearchDiaryViewModel.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/15.
//

import Foundation
import Combine

final class SearchDiaryViewModel {
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    private let coreDataManager: CoreDataManager
    let searchDiary = PassthroughSubject<String, Never>()
    private let doneFetchDiary = PassthroughSubject<Void, Never>()
    var timeDiary = [TimeDiary]()
    var dayDiary = [DayDiary]()
    
    // MARK: - LifeCycle
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        bindingSelf()
    }
}

// MARK: - Method
extension SearchDiaryViewModel {
    private func getSearchTimeDiary(search query: String) {
        coreDataManager.getDiary(type: .time, filterType: .content, query: query)
    }
    
    private func fetchTimeDiaryToPublisher() -> AnyPublisher<[TimeDiary], Never> {
        return coreDataManager.fetchTimeDiary
            .flatMap { [unowned self] in
                castingToTimeDiary(diary: $0)
            }
            .eraseToAnyPublisher()
    }
    
    private func castingToTimeDiary(diary: [Diary]) -> AnyPublisher<[TimeDiary], Never> {
        diary.publisher
            .compactMap {
                $0 as? TimeDiary
            }
            .collect()
            .eraseToAnyPublisher()
    }
    
    private func getSearchDayDiary(search query: String) {
        coreDataManager.getDiary(type: .day, filterType: .content, query: query)
    }
    
    private func fetchDayDiaryToPublisher() -> AnyPublisher<[DayDiary], Never> {
        return coreDataManager.fetchDayDiary
            .flatMap { [unowned self] in
                castingToDayDiary(diary: $0)
            }
            .eraseToAnyPublisher()
    }
    
    private func castingToDayDiary(diary: [Diary]) -> AnyPublisher<[DayDiary], Never> {
        diary.publisher
            .compactMap {
                $0 as? DayDiary
            }
            .collect()
            .eraseToAnyPublisher()
    }
    
    private func getSearchDiary(search query: String) {
        getSearchTimeDiary(search: query)
        getSearchDayDiary(search: query)
    }
}

// MARK: - Binding
extension SearchDiaryViewModel {
    private func bindingSelf() {
        searchDiary
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.getSearchDiary(search: query)
                self?.doneFetchDiary.send()
            }.store(in: &subscriptions)
        
        fetchTimeDiaryToPublisher()
            .zip(fetchDayDiaryToPublisher())
            .sink { [weak self] time, day in
                self?.timeDiary = time
                self?.dayDiary = day
            }.store(in: &subscriptions)
    }
}
