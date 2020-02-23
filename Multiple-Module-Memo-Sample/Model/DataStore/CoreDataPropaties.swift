//
// Created by kawaharadai on 2020/02/23.
// Copyright (c) 2020 kawaharadai. All rights reserved.
//

import CoreData

final class CoreDataPropaties {

    private init() {}

    static let shared = CoreDataPropaties()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Multiple_Module_Memo_Sample")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
