//
//  Item+CoreDataProperties.swift
//  ClassifiedAlbum
//
//  Created by Kohei Ikeda on 2022/05/24.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var timestamp: Date?
    @NSManaged public var image: Data?
    @NSManaged public var classLabel_1: String?
    @NSManaged public var classLabel_2: String?
}

extension Item : Identifiable {

}
