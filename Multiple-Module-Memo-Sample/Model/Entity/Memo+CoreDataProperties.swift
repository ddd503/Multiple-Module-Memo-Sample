//
//  Memo+CoreDataProperties.swift
//  Multiple-Module-Memo-Sample
//
//  Created by kawaharadai on 2020/02/23.
//  Copyright © 2020 kawaharadai. All rights reserved.
//
//

import Foundation
import CoreData


extension Memo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Memo> {
        return NSFetchRequest<Memo>(entityName: "Memo")
    }

    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var editDate: Date?
    @NSManaged public var uniqueId: String?

}
