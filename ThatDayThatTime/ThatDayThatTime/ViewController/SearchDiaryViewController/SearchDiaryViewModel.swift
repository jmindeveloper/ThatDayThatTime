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
    var timeDiary = [[TimeDiary]]()
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
    
    private func fetchTimeDiaryToPublisher() -> AnyPublisher<[[TimeDiary]], Never> {
        return coreDataManager.fetchTimeDiary
            .flatMap { [unowned self] in
                castingToTimeDiary(diary: $0)
            }
            .eraseToAnyPublisher()
    }
    
    private func castingToTimeDiary(diary: [Diary]) -> AnyPublisher<[[TimeDiary]], Never> {
        diary.publisher
            .compactMap {
                $0 as? TimeDiary
            }
            .collect()
            .map(sliceTimeDiaryToDate(diary:))
            .eraseToAnyPublisher()
    }
    
    private func sliceTimeDiaryToDate(diary: [TimeDiary]) -> [[TimeDiary]] {
        guard diary.count > 0 else {
            return []
        }
        let diary = diary.sorted {
            $0.date ?? "" < $1.date ?? ""
        }
        var diarys = [[TimeDiary]]()
        var filterDiary = [TimeDiary]()
        var date: String? = ""
        
        for i in 0..<diary.count {
            if diary[i].date == date {
                filterDiary.append(diary[i])
            } else {
                filterDiary.sort {
                    $0.time ?? "" < $1.time ?? ""
                }
                diarys.append(filterDiary)
                date = diary[i].date
                filterDiary = [diary[i]]
            }
        }
        diarys.append(filterDiary)
        
        diarys.removeFirst()
        return diarys
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
            .map {
                $0.sorted {
                    $0.date ?? "" < $1.date ?? ""
                }
            }
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
