//
//  GatherDiaryViewModel.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/16.
//

import Foundation
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
    private var month = String.getMonth()
    private var year = String.getYear()
    
    // MARK: - LifeCycle
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        changeSegmenteItemsSelected()
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
        updateDiary.send()
    }
    
    func changeMonth(month: String) {
        self.month = month
        changeSegmenteItemsSelected()
    }
    
    func selectedDate() -> String {
        return "\(year) \(month)"
    }
}
