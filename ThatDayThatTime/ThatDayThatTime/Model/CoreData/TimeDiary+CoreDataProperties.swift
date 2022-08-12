//
//  TimeDiary+CoreDataProperties.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//
//

import Foundation
import CoreData

@objc(TimeDiary)
public class TimeDiary: NSManagedObject {

}

extension TimeDiary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TimeDiary> {
        return NSFetchRequest<TimeDiary>(entityName: "TimeDiary")
    }

    @NSManaged public var content: String?
    @NSManaged public var date: String?
    @NSManaged public var id: String
    @NSManaged public var image: Data?
    @NSManaged public var time: String?

}

extension TimeDiary : Identifiable, Diary {

}
