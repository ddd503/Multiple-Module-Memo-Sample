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
    func create<T: NSManagedObject>(entityName: String, _ completion: (Result<T, Error>) -> ())

    @discardableResult
    func save(context: NSManagedObjectContext) -> Result<Void, Error>

    func fetchArray<T: NSManagedObject>(predicates: [NSPredicate],
                                        sortKey: String,
                                        ascending: Bool,
                                        logicalType: NSCompoundPredicate.LogicalType,
                                        _ completion: (Result<[T], Error>) -> ())

    func execute<R: NSPersistentStoreRequest>(request: R, _ completion: (Result<Void, Error>) -> ())

    func delete<T: NSManagedObject>(object: T, _ completion: () -> ())
}

struct MemoItemDataStoreImpl: MemoItemDataStore {
    func create<T>(entityName: String, _ completion: (Result<T, Error>) -> ()) where T : NSManagedObject {
        let context = CoreDataPropaties.shared.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        guard let memoEntity = entity else {
            completion(.failure(CoreDataError.failedCreateEntity))
            return
        }
        guard let object = NSManagedObject(entity: memoEntity, insertInto: context) as? T else {
            completion(.failure(CoreDataError.failedGetManagedObject))
            return
        }
        return completion(.success(object))
    }

    @discardableResult
    func save(context: NSManagedObjectContext) -> Result<Void, Error> {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                return .failure(error)
            }
        }
        return .success(())
    }

    func fetchArray<T>(predicates: [NSPredicate],
                       sortKey: String, ascending: Bool,
                       logicalType: NSCompoundPredicate.LogicalType,
                       _ completion: (Result<[T], Error>) -> ()) where T : NSManagedObject {
        let context = CoreDataPropaties.shared.persistentContainer.viewContext
        guard let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as? NSFetchRequest<T> else {
            completion(.failure(CoreDataError.failedPrepareRequest))
            return
        }
        let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: ascending)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSCompoundPredicate(type: logicalType, subpredicates: predicates)

        let resultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                           managedObjectContext: context,
                                                           sectionNameKeyPath: nil,
                                                           cacheName: nil)

        do {
            try resultsController.performFetch()
            completion(.success(resultsController.fetchedObjects ?? []))
        } catch {
            completion(.failure(CoreDataError.failedFetchRequest))
        }
    }

    func execute<R: NSPersistentStoreRequest>(request: R, _ completion: (Result<Void, Error>) -> ()) {
        let context = CoreDataPropaties.shared.persistentContainer.viewContext
        do {
            try context.execute(request)
            return completion(.success(()))
        } catch {
            return completion(.failure(CoreDataError.failedExecuteStoreRequest))
        }
    }

    func delete<T>(object: T, _ completion: () -> ()) where T : NSManagedObject {
        let context = CoreDataPropaties.shared.persistentContainer.viewContext
        context.performAndWait {
            context.delete(object)
            completion()
        }
    }
}
