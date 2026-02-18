//
//  CDPerson+CoreDataProperties.swift
//  CoreData_Swift
//
//  Created by Krishna Nampally on 18/02/26.
//
//

import Foundation
import CoreData


extension CDPerson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPerson> {
        return NSFetchRequest<CDPerson>(entityName: "CDPerson")
    }

    @NSManaged public var name: String?
    @NSManaged public var age: Int16

}

extension CDPerson : Identifiable {

}
