//
//  MemoItem+CoreDataProperties.swift
//  Data
//
//  Created by kawaharadai on 2020/02/29.
//  Copyright © 2020 kawaharadai. All rights reserved.
//
//

import Foundation
import CoreData


extension MemoItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MemoItem> {
        return NSFetchRequest<MemoItem>(entityName: "MemoItem")
    }

    @NSManaged public var uniqueId: String?
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var editDate: Date?

}
