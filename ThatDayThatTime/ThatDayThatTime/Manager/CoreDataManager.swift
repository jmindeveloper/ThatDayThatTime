//
//  CoreDataManager.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import Foundation
import CoreData

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

final class CoreDataManager {
    
    private let containerName = "ThatDayThatTime"
    private let persistentContainer: NSPersistentContainer
    
    init() {
        self.persistentContainer = NSPersistentContainer(name: containerName)
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                print(String(describing: error))
            }
        }
    }
    
    
    
}
