//
//  Diary.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import UIKit

protocol Diary {
    var id: String { get }
    var image: Data? { get }
    var date: String? { get }
}

struct DiaryEntity {
    var content: String?
    var date: String?
    var id: String
    var image: UIImage?
    var time: String?
}

enum DiaryType {
    case day, time, image
    
    var entityName: String {
        switch self {
        case .day:
            return "DayDiary"
        case .time:
            return "TimeDiary"
        case .image:
            return "Image"
        }
    }
}
