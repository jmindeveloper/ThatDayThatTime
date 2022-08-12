//
//  DayDiary+CoreDataProperties.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//
//

import Foundation
import CoreData

@objc(DayDiary)
public class DayDiary: NSManagedObject {

}

extension DayDiary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DayDiary> {
        return NSFetchRequest<DayDiary>(entityName: "DayDiary")
    }

    @NSManaged public var content: String?
    @NSManaged public var date: String?
    @NSManaged public var id: String
    @NSManaged public var image: Data?

}

extension DayDiary : Identifiable, Diary {

}
