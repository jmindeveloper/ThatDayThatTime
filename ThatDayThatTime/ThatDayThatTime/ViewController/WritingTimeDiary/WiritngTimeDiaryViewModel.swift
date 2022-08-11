//
//  WiritngTimeDiaryViewModel.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/11.
//

import UIKit
import Combine

final class WritingTimeDiaryViewModel {
    
    var time: CurrentValueSubject<String, Never>
    var diary: String
    var image: CurrentValueSubject<UIImage?, Never>
    var date: CurrentValueSubject<String, Never>
    private let coreDataManager = CoreDataManager()
    
    init(timeDiary: TimeDiary?) {
        self.time = CurrentValueSubject<String, Never>(timeDiary?.time ?? String.getTime())
        self.diary = timeDiary?.content ?? ""
        self.image = CurrentValueSubject<UIImage?, Never>(UIImage.getImage(to: timeDiary?.image))
        self.date = CurrentValueSubject<String, Never>(timeDiary?.date ?? String.getDate())
    }
    
    func saveTimeDiary(completion: @escaping () -> Void) {
        let newDiary = DiaryEntity(
            content: diary,
            date: date.value,
            id: UUID().uuidString,
            image: image.value?.pngData(),
            time: time.value
        )
        coreDataManager.saveDiary(type: .time, diary: newDiary)
        completion()
    }
    
    func getDiaryStringCount() -> Int {
        return diary.count
    }
}
