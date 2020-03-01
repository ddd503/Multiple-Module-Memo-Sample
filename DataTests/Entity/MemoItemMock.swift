//
//  MemoItemMock.swift
//  DataTests
//
//  Created by kawaharadai on 2020/03/01.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import Foundation
import CoreData
@testable import Data

class MemoItemMock: MemoItem {
    var id = ""
    var titleText: String?
    var contentText: String?
    var editMemoDate: Date?

    convenience init(uniqueId: String = "", title: String?,
                     content: String?, editDate: Date?) {
        self.init()
        self.id = uniqueId
        self.titleText = title
        self.contentText = content
        self.editMemoDate = editDate
    }

    override var uniqueId: String? {
        set { id = newValue ?? "" }
        get { return self.id }
    }

    override var title: String? {
        set { self.titleText = newValue ?? "" }
        get { return self.titleText }
    }

    override var content: String? {
        set { self.contentText = newValue ?? "" }
        get { return self.contentText }
    }

    override var editDate: Date? {
        set { self.editMemoDate = newValue }
        get { return self.editMemoDate }
    }

    override var managedObjectContext: NSManagedObjectContext? {
        set {}
        get { return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType) }
    }
}
