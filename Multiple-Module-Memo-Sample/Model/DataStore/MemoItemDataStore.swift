//
//  MemoItemDataStore.swift
//  Multiple-Module-Memo-Sample
//
//  Created by kawaharadai on 2020/02/23.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import Foundation
import CoreData

protocol MemoItemDataStore {
    func create<T: NSManagedObject>(entityName: String, _ completion: (Result<T, Error>) -> (Void))

    @discardableResult
    func save(context: NSManagedObjectContext) -> Result<Void, Error>

    func fetchArray<T: NSManagedObject>(predicates: [NSPredicate],
                                        sortKey: String,
                                        ascending: Bool,
                                        logicalType: NSCompoundPredicate.LogicalType,
                                        _ completion: (Result<[T], Error>) -> (Void))

    func excute<R: NSPersistentStoreRequest>(request: R, _ completion: () -> ())

    func delete<T: NSManagedObject>(object: T, _ completion: () -> ())
}
