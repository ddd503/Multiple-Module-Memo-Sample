//
//  CoreDataManager.swift
//  Data
//
//  Created by kawaharadai on 2020/02/29.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import CoreData

final class CoreDataManager {

    private init() {}

    static let shared = CoreDataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Data")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
