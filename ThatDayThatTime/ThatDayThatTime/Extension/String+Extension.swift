//
//  String+Extension.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import Foundation

extension String {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()
    
    var date: Date? {
        return Self.dateFormatter.date(from: self)
    }
}
