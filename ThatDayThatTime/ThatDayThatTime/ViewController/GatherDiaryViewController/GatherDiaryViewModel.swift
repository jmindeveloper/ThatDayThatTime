//
//  GatherDiaryViewModel.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/16.
//

import UIKit
import Combine

final class GatherDiaryViewModel {
    
    // MARK: - Properties
    private let coreDataManager: CoreDataManager
    var segmentItems = [
        ("1월", false), ("2월", false),
        ("3월", false), ("4월", false),
        ("5월", false), ("6월", false),
        ("7월", false), ("8월", false),
        ("9월", false), ("10월", false),
        ("11월", false), ("12월", false)
    ]
    let updateDiary = PassthroughSubject<Void, Never>()
    let updateFullSizeImage = PassthroughSubject<UIImage?, Never>()
    let selectedSegment = PassthroughSubject<Int, Never>()
    let updateCalendarYear = PassthroughSubject<String, Never>()
    private var month = String.getMonth()
    private var year = String.getYear()
    private var date = Date()
    private var subscriptions = Set<AnyCancellable>()
    var diarys = [[Diary]]()
    var selectedSegmentIndex = 0
    
    // MARK: - LifeCycle
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        bindingSelf()
        bindingCoreDataManager()
    }
}

// MARK: - Method
extension GatherDiaryViewModel {
    private func changeSegmenteItemsSelected() {
        let index = segmentItems.firstIndex {
            return $0.0 == month
        }
        for i in 0..<segmentItems.count {
            segmentItems[i].1 = false
        }
        
        segmentItems[index ?? 0].1 = true
        selectedSegmentIndex = index ?? 0
    }
    
    func changeYear(year: String) {
        self.year = year
        let date = selectedDate()
        let month = date.components(separatedBy: " ").last
        changeMonth(month: month ?? "1월")
        updateSelectedDate(with: selectedDate())
    }
    
    func changeMonth(month: String) {
        self.month = month
        let date = selectedDate()
        getDiary(date: date)
        updateSelectedDate(with: selectedDate())
        changeSegmenteItemsSelected()
    }
    
    private func updateSelectedDate(with date: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        formatter.locale = Locale(identifier: "ko_KR")
        
        self.date = formatter.date(from: date) ?? Date()
    }
    
    func selectedDate() -> String {
        let date = "\(year) \(month)"
        return date
    }
    
    func getSelectedSegmentIndex() {
        selectedSegment.send(selectedSegmentIndex)
    }
    
    func getFullSizeImage(id: String) {
        coreDataManager.getFullSizeImage(id: id)
    }
    
    private func getTimeDiary(date: String) {
        coreDataManager.getDiary(type: .time, filterType: .date, query: date)
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
            .map(sliceTimeDiaryToDate(diary:))
            .eraseToAnyPublisher()
    }
    
    private func stringToDate(_ str: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월d일 E요일"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        return dateFormatter.date(from: str) ?? Date()
    }
    
    private func sliceTimeDiaryToDate(diary: [TimeDiary]) -> [TimeDiary] {
        guard diary.count > 0 else {
            return []
        }
        
        let diary = diary.sorted {
            stringToDate($0.date ?? "") < stringToDate($1.date ?? "")
        }
        var diarys = [TimeDiary]()
        var filterDiary = [TimeDiary]()
        var date: String? = ""
        
        for i in 0..<diary.count {
            if diary[i].date == date {
                filterDiary.append(diary[i])
            } else {
                filterDiary.sort {
                    $0.time ?? "" < $1.time ?? ""
                }
                diarys.append(contentsOf: filterDiary)
                date = diary[i].date
                filterDiary = [diary[i]]
            }
        }
        filterDiary.sort {
            $0.time ?? "" < $1.time ?? ""
        }
        diarys.append(contentsOf: filterDiary)
        
        return diarys
    }
    
    private func joinDiayrsToDate(timeDiary: [Diary], dayDiary: [Diary]) -> [[Diary]] {
        let diarys = timeDiary + dayDiary
        let diary = diarys.sorted {
            stringToDate($0.date ?? "") < stringToDate($1.date ?? "")
        }
        
        var joinDiary = [[Diary]]()
        var filterDiary = [Diary]()
        var date: String? = ""
        
        for i in 0..<diary.count {
            if diary[i].date == date {
                filterDiary.append(diary[i])
            } else {
                joinDiary.append(filterDiary)
                date = diary[i].date
                filterDiary = [diary[i]]
            }
        }
        joinDiary.append(filterDiary)
        joinDiary.removeFirst()
        return joinDiary
    }
    
    private func getDayDiary(date: String) {
        coreDataManager.getDiary(type: .day, filterType: .date, query: date)
    }
    
    private func fetchDayDiaryToPublisher() -> AnyPublisher<[Diary], Never> {
        return coreDataManager.fetchDayDiary
            .flatMap { [unowned self] in
                castingToDayDiary(diary: $0)
            }
            .eraseToAnyPublisher()
    }
    
    private func castingToDayDiary(diary: [Diary]) -> AnyPublisher<[Diary], Never> {
        diary.publisher
            .collect()
            .map {
                $0.sorted {
                    stringToDate($0.date ?? "") < stringToDate($1.date ?? "")
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func getDiary(date: String) {
        getTimeDiary(date: date)
        getDayDiary(date: date)
    }
    
    func sliceDate(date: String) -> String {
        var sliceDiayrDate = date.components(separatedBy: " ")
        sliceDiayrDate.removeFirst()
        
        return sliceDiayrDate.joined(separator: " ")
    }
    
    func moveNextMonth() {
        date = Calendar.current.date(byAdding: DateComponents(month: 1), to: date) ?? Date()
        year = String.getYear(date: date)
        month = String.getMonth(date: date)
        
        updateCalendarYear.send(year)
        changeMonth(month: month)
        getSelectedSegmentIndex()
    }
    
    func moveBeforeMonth() {
        date = Calendar.current.date(byAdding: DateComponents(month: -1), to: date) ?? Date()
        year = String.getYear(date: date)
        month = String.getMonth(date: date)
        
        updateCalendarYear.send(year)
        changeMonth(month: month)
        getSelectedSegmentIndex()
    }
}

// MARK: - Binding
extension GatherDiaryViewModel {
    
    private func bindingSelf() {
        fetchTimeDiaryToPublisher()
            .zip(fetchDayDiaryToPublisher())
            .map(joinDiayrsToDate(timeDiary:dayDiary:))
            .sink { [weak self] diarys in
                self?.diarys = diarys
                self?.updateDiary.send()
            }.store(in: &subscriptions)
    }
    
    private func bindingCoreDataManager() {
        coreDataManager.fetchFullSizeImage
            .map {
                UIImage.getImage(data: $0)
            }
            .sink { [weak self] image in
                self?.updateFullSizeImage.send(image)
            }.store(in: &subscriptions)
    }
    
}
