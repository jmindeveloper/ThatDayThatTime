//
//  TimeDiaryViewModel.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/11.
//

import Foundation
import Combine
import UIKit

final class TimeDiaryViewModel {
    
    // MARK: - Properteis
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
    let updateFullSizeImage = PassthroughSubject<UIImage?, Never>()
    let coreDataManager: CoreDataManager
    private var subscriptions = Set<AnyCancellable>()
        
    // MARK: - LifeCycle
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        bindingCoreDataManager()
    }
}

// MARK: - Method
extension TimeDiaryViewModel {
    func changeDate(date: String) {
        self.date = date
        coreDataManager.getDiary(type: .time, filterType: .date, query: date)
    }
    
    func deleteDiary(index: Int) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let diary = self.diarys[index]
            self.coreDataManager.deleteDiary(diary: diary, type: .time)
        }
    }
    
    func getFullSizeImage(id: String) {
        coreDataManager.getFullSizeImage(id: id)
    }
}

// MARK: - Binding
extension TimeDiaryViewModel {
    private func bindingCoreDataManager() {
        coreDataManager.fetchTimeDiary
            .flatMap { [unowned self] in
                filterDiarys(diarys: $0)
            }
            .sink { [weak self] diarys in
                self?.diarys = diarys
            }.store(in: &subscriptions)
        
        coreDataManager.fetchFullSizeImage
            .map {
                UIImage.getImage(data: $0)
            }
            .sink { [weak self] image in
                self?.updateFullSizeImage.send(image)
            }.store(in: &subscriptions)
        
        coreDataManager.changePersistentContainer
            .sink { [weak self] in
                guard let self = self else { return }
                self.changeDate(date: self.date)
            }.store(in: &subscriptions)
    }
    
    private func filterDiarys(diarys: [Diary]) -> AnyPublisher<[TimeDiary], Never> {
        diarys.publisher
            .compactMap {
                $0 as? TimeDiary
            }
            .collect()
            .eraseToAnyPublisher()
    }
}
