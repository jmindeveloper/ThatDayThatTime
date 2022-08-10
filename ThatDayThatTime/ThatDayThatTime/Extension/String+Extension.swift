//
//  String+Extension.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import Foundation

extension String {
    static func getDate(date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    static func getDate(components: CalendarCellComponents) -> String {
        return "\(components.year)년 \(components.month)월 \(components.day)일 \(components.weekday)"
    }
}
