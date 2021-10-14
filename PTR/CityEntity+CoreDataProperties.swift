//
//  CityEntity+CoreDataProperties.swift
//  PTR
//
//
//

import Foundation
import CoreData


extension CityEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CityEntity> {
        return NSFetchRequest<CityEntity>(entityName: "CityEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var values: [Date:Float]?

}

extension CityEntity : Identifiable {

}
