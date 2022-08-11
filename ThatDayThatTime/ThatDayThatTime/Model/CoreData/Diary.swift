//
//  Diary.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import Foundation

protocol Diary {
    var content: String? { get set }
    var date: String? { get set }
    var id: String? { get }
    var image: Data? { get set }
}

struct DiaryEntity: Diary {
    var content: String?
    var date: String?
    var id: String?
    var image: Data?
    var time: String?
}

enum DiaryType {
    case day, time
    
    var entityName: String {
        switch self {
        case .day:
            return "DayDiary"
        case .time:
            return "TimeDiary"
        }
    }
}
