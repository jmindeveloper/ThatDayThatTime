//
//  Image+CoreDataProperties.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/13.
//
//

import Foundation
import CoreData

@objc(Image)
public class Image: NSManagedObject {

}

extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var id: String?
    @NSManaged public var image: Data?

}

extension Image : Identifiable {

}
